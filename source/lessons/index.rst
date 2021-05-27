=========================================
Lessons From PAN
=========================================

This section of the documentation contains documentation on both the flight software and the
PAN satellite's subsystem architectures. The two ideas go hand-in-hand, which is why their
documentation is woven together. This section is primarily meant to be *design* documentation,
although there is some user documentation as well.

Mechanical
==========

Any power supply of a subsystem that we need to verify is "on" should have its own indicator LED light 
or it should have contacts on the exterior to check with a multimeter.

Every board that required a firmware upload, or is configurable, MUST have an connection available from the exterior satellite
in an assembled state.

The exterior should have better grips or handles to hold the satellite from if possible.

All buttons that need to be pressed, such as reset buttons should also be moved or easily accessable.

ECE
===

Magnets shall not be placed near motors. This prevents PAN's docking system from working reliably.

Magnetomers shall be placed far from motors because their readings will become noisier.

As much as possible step up voltage systems are to be avoided. Instead, if the battery voltage is 8.4V tops, 
try to find motors that operate on less than 8.4V. Sensor boards should have no reason to operate on 24V as well.

Avoid ground loops.

Make sure grounds are shared.

The spacecraft should be able to hook up a power supply in a way that mimicks the solar panels so that software
that permits charging or controls charging can be tested in a flight like manner.

Avoid long bus communication lines. These will act like antenna and put strain on signal quality.

For god sake. PLEASE PLEASE PLEASE. Avoid serial communication that is "dumb". The Piksi screams its data over 
whenever it feels like it. This makes getting any time guarentee about its data incredibly frustrating and unreliabe. When possbile use I2C, or two way master controlled Serial

Flight Software Layout
======================

Flight Software should be "single threaded". This means that control flow should be a linear decision process, 
and can be generally characterized by a single state machine. This prevents the headaches of multiple subsystems
each owning their own thread and making conflicting decisions.

Flight Software should be centered around a control task. Every given period, a control cycle passes, in which
every module of code is executed, and its decisions considersed. Each of these modules are called a control task.

Flight Software should be layered so that control task are bundled, and that decision authority first bubbles up to the
highest level control task called the Mission Manager.

The first layer is Monitors. These call driver functions and populate internal memory with the status of sensors
and actuator boards. Next are Estimators and Filters. Given previous state information, these perform math computations
to gain more information about the spacecaft state over time.

Then are FaultHandlers. These make deducations and conclusions about the spacecraft's health and best course of action
given the current and past sensor data.

Then is MissionManager. Using all information available, and the spacecraft's current state, it decides what the next best global
policy of the spacecraft should be.

Then are the Subsystem Controllers. Given all data, and the mission state, it decides the best policy for each subsystem.
This includes any mathematical calcuations of actuator impulses, torques, etc.

Then are the Commanders. These perform last minute calculations of all the specific settings for a subsystem.
This would include pin numbers, addresses to load into registers, thresholds to apply.

Then lastly are the Actuator Control Tasks, which take all those settings and actually dumpt them into subsystems through
driver calls.

Flight Software Implementation
==============================

Flight Software should abstract itself into all the layers outlined above so that simulation of its performance
can essentially be done by chopping off the Monitors and Actuators, and everything else can be fully verified
assuming that the Monitors and Actuators are sufficiently mocked.


As a further upgrade, if these ControlTasks could be simulatenously integrated within PSim, then GNC testing and development
need not be translated if PSim and FSW used the same control task architecture.

To minimize the manual linking pain that currently exists within FSW, where programmers have to find field names
and match then manually and create 6 different pointers across unit tests and FSW, and auto coder should be used to
prevent headaches and prevent errors

For god sake. PLEASE PLEASE PLEASE. The telemetry system of the spacecraft should be completely orthogonal to
each ControlTask. Currently internal statefields cannot be looked and or mutated in PTest because they do not have
a serializer for the telemtry system. This has caused significant pain.

The tight knit integration between serializers and statefields has made their seperation near impossible, and is incredibly
difficult to free. Instead, serailiers should have been specificed in some orthogonal lookup table between statefields 
and serializers. This way, if a certain test suite does not involve actual flight telemetry, its work is not
impeded.

Flight Software Testing
=======================

Testing infrastructure should invest in the capability to "walk" the spacecraft's statemachine
all the way to intended testing locations. While this is tough to support, it is aboslutely critical to
ensure that the testing conditions that are assumed are actually reachable by the Flight Software binary.

