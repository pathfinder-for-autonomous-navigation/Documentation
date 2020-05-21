==================================
Attitude Determination and Control
==================================

The attitude determination and control subsystem (ADCS) box of the satellite is a
0.5U unit attached at the end of our spacecraft opposite its docking face. It has
its own microcontroller, a Teensy 3.6, that runs a specialized software and is connected
to the Flight Controller Teensy over I2C. The ADCS box provides fairly robust but slow pointing
control--the slowness is sufficient for PAN's purposes.

Attitude Determination System
=============================
The attitude on the spacecraft is determined using a combination of three sensors:
the sun sensors, the gyroscope, and the two magnetometers.

Sun Sensors
-----------
The sun sensors are 5 arrays of 4 sensors, with each array attached to one of the
faces of the ADCS box, and each sensor in the array angled off the surface of the box
in a different way. The sun sensors are nothing more than phototransistors attached
to an analog-to-digital converter. The five analog-to-digital converters (one for each
array) are connected via I2C to the Teensy.

The current through each phototransistor can be read as a voltage on the Teensy.
The currents on all twenty sensors are fed through a precomputed linear regression
to determine the vector to the sun relative to the spacecraft in its body frame. If
such a regression returns inconclusive results then the ADCS Teensy lets the Flight Controller
know (see `Interface with Flight Software`_ below).

Gyroscope and Heater
--------------------
The gyroscope is connected over I2C to the ADCS Teensy. To ensure the gyroscope measurement
does not drift due to thermal fluctuations, the gyroscope is embedded underneath a resistive
heating device that operates via a bang-bang controller. The setpoint of the controller is
managed by the Flight Controller.

Magnetometers
-------------
There are two magnetometers on the spacecraft.

MAG1:
Todo: details about MAG1

MAG2:
Todo: details about MAG2

Each magnetometer can be individually commanded between 
``IMU_MAG_NORMAL`` and ``IMU_MAG_CALIBRATION`` modes. Data is polled from both magnetometers
simultaneously.

Attitude Control System
=======================
We achieve attitude control via 3 reaction wheels and 3 magnetorquers, one for each
axis of the spacecraft. The wheels are controlled via "ramp command", which sets their
angular acceleration and thus provides torque-based control over the spacecraft's attitude.
The magnetorquers are provided a magnetic moment command, via which they can execute a torque
on the spacecraft.

The ADCS Software
=================
TODO explain ADCS Software functionality.

Interface with Flight Software
------------------------------
The interface of the ADCS box Teensy with the flight Teensy is over register-based I2C,
effectively SMBUS. In this relationship the ADCS Teensy is a slave and the flight Teensy
is a master.

**Reading from ADCS Controller**

The flight controller can read values off of the ADCS Teensy via a "point-and-read" interface.
The flight controller first sets the value of a read pointer, which specifies the register
address at which it wants to receive values. The ADCS Teensy then responds with a set of
values that begin at the register specified by the flight controller and run contiguously up
to some other register address. This allows the flight controller to read values off of the ADCS
controller in bulk, which reduces protocol overhead when accessing related values.

Below we list the "read registers" on the ADCS and where a read operation ends when the read
pointer is set to that register address. As an example for explaining the previous paragraph, note
that setting the read pointer to the X-value of the magnetometer causes the ADCS Teensy to report
back the X, Y, `and` Z values of the magnetometer. This is sensible since any control scheme would
want all three values off of the ADCS device.

TODO insert table from Kyle's document

**Writing to ADCS Controller**
In order to actuate attitude commands, the ADCS box provides registers that can be written to.
This list of registers is specified below.

TODO insert table from Kyle's document

ADCS Hardware Availability Table (HAVT)
---------------------------------------

For every ``Device`` connected to the ADCS Teensy, the Teensy tracks the "functionality" state
of the ``Device``. If it is disabled, then if the device is an actuator, no actuations will be performed.
If the ``Device`` is an ``I2CDevice``, then no I2C transactions will occur with that device.

Internally within ADCS Software, there is a Hardware Availablility Table that reports the funct ionality state 
of each device. I2C devices automatically disable (set their functionality state to false) themselves if 
too many consecutive I2C transactions fail. All devices are initially enabled ADCS Teensy boot, so if 
all ``setup()`` calls are succesful, the initial HAVT table will be represented by a bitset of all ``1``'s.

The ADCS Teensy has a read register dedicated to reading the state of the HAVT table.
There are two seperate command registers to intewith the HAVT table, one for commanding ``reset()``'s,
and another for commanding ``disable()``s. All three are represented as a 32 bit long ``std::bitset``'s.

On every ADCS cycle, the ADCS Teensy will actuate a ``reset()`` or ``disable()`` if the index of the 
command table corresponding to a device has a ``1`` in that position. 
Therefore, nominally the reset and disable command registers are all commanded as ``0``'s from the 
FSW Teensy. 

Flight Software Components for ADCS
===================================

Several control tasks manage the ADCS system. They are: the ADCS box monitor,
the ADCS attitude estimator, the ADCS computer, the ADCS commander, and the ADCS box controller.

- The ADCS Box Monitor and Controller are basic device-interface control tasks that do the
  simple job of reading sensor values and writing wheel and magnetometer commands to the ADCS peripheral.

    - ADCS Box Monitor-specific behaviors:

      - If a sensor reading is out of bounds, ADCSBoxMonitor will set a corresponding flag as true. Otherwise, it is set to false.
      - After reading the ADCS HAVT table, ADCSBoxMonitor will ``signal()`` a corresponding fault if
        any of the wheels, or the wheel potentiometer report as not functional. Otherwise, the flag is ``unsignal()``'ed.

    - ADCS Box Controller-specific behaviors:
     
      - Renews the calculation of the sun vector if **ADCSMonitor** reported that a previous calculation was no longer in progress.
      - Applies the desired HAVT reset or HAVT disable vectors to the ADCS box.

- The ADCS attitude estimator takes inputs from the box monitor to produce a filtered estimate of the
  spacecraft's attitude.

  TODO: What happens when inputs are NaN?

- The ADCS computer, using the high-level ADCS strategy dictated by the mission manager, creates a 
  desired attitude for the spacecraft.

  The desired attitude is provided via four vectors: a "primary" pointing objective; the body vector that should
  be aligned with the primary pointing objective; and the "second" pointing objective and body vector. 

- The ADCS commander implements a control law to convert the desired attitude and rate into wheel and
  magnetorquer commands for the spacecraft.

  - If the ``adcs_state`` is in startup, this control task sets the ADCS box to passive mode which disables
    all actuation (magnetorquers and wheels) regardless of the MTR and Wheel commands coming from **ADCSCommander**.
    In all other ``adcs_states`` ADCSController will dump all the desired commands from **ADCSCommander** into the
    ADCS box using the ADCS Driver.

TODO insert state field names
