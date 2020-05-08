============================
Propulsion System Management
============================

The purpose of this document is to detail the Propulsion Controller Subsystem of 
Flight Software. The Propulsion System is responsible for generating thrust in order to accelerate
the satellite. It is also responsible for monitoring the state of the propulsion system 
hardware and handling detected faults.

The software components of the Propulsion System consists of the Propulsion System driver,
the Propulsion System Controller, and the Propulsion System Fault Handler. 

The hardware components of the Propulsion System consists of the inner tank, the outer tank,
the inner tank temperature sensor, the outer tank temperature sensor, the 
outer tank pressure sensor, the two intertank valves, and the four outer tank valves.  

This document is split into four main sections. The first section gives a high-level overview
of the Propulsion System, its components, and the responsiblities of each component. 
The second section details the Propulsion System state machine. The third section 
details the Propulsion System driver. The last section consists of operational notes,
warnings, and known issues. 

Overview
==============
This section gives and overview of the components of the Propulsion System, their responsibilities, 
and defines terminology used in the rest of this document. 


Tank1
------
``Tank1``, the inner tank, is responsible for pressurizing ``Tank2``. At the start of the mission,
``Tank1`` is filled with liquid propellant. The propellant is released into ``Tank2`` through
one of the two intertank valves, which causes pressure to build up in Tank2. The two 
valves on ``Tank1`` are referred to as the ``primary valve`` and the ``backup valve``.
``Tank1`` also has a temperature sensor, which is used to detect and handle faults. 

Tank2
-----
``Tank2``, the outer tank, is responsible for accelerating the satellite. It consists of four valves 
arranged tetrahedrally: ``valve1``, ``valve2``, ``valve3``, ``valve4``. 
Each valve is assigned a schedule, and the four valve schedules 
along with a firing time consist of a `firing schedule`. The direction of acceleration 
is, therefore, determined by the firing schedule. ``Tank2`` has a temperature sensor
and a pressure sensor. The pressure sensor on ``Tank2`` is used to indicate when ``Tank1``
should stop pressurizing ``Tank2``. Both the pressure sensor and temperature sensor are used
to detect and handle faults. 

Firing Schedule
-----------------
The firing time is determined by ``cycles_until_firing``, which is the number of 
control cycles from the current control cycle
at which the valves shall fire. It is defined relative to the current control cycle.
For example, if the current control cycle is 13, then ``cycles_until_firing`` of 8 means 
that the valves shall fire when the satellite is in control cycle 21. 

The ``valve schedules`` are in units of milliseconds with a maximum value of 1000. When
the satellite enters the control cycle specified by the firing time, the valves will
open for the duration of their assigned schedules. 

The Propulsion System Controller will only execute what it considers a ``valid firing
schedule``. Any schedule considered invalid will be ignored. 

If any valve is assigned a schedule greater than 1000, then that entire firing schedule is invalid. 
If the Propulsion System Controller believes that it will not have enough time to
pressurize ``Tank2`` by the desired firing time cycle, then this schedule will also
be considered invalid. 
A valid firing schedule is, therefore, a firing schedule in which
all valve schedules are no greater than 1000 ms and the firing time is far enough
into the future that the Propulsion System has time to pressurize. 

Propulsion Controller State Machine
====================================
This section details the Propulsion Controller (``PropController``), which is implemented as a state machine. 
The state machine interacts with the propulsion system via the propulsion system driver.

The Propulsion Controller is defined in ``PropController.hpp`` and
implemented in ``PropController.cpp``. 

The firing time is determined by ``prop.cycles_until_firing``. It is time to fire, when 
``prop.cycles_until_firing`` is 0. 

There are techncially two copies of the firing schedule: the state machine schedule and the driver schedule. 
The state machine schedule consists of the following statefields:
``prop.sched_valve1``, ``prop.sched_valve2``, ``prop.sched_valve3``, and ``prop.sched_valve4``.
The values in this state field are copied to the driver's
schedule one cycle prior to the firing time. 

Propulsion Controller States
----------------------------
This section details state transitions and entry conditions (preconditions) of the
states in the Propulsion System state machine. 

Disabled
    - In this state, propulsion system will defer decisions to the ground (or other subsystems) and will only read the sensor values
    - No transitions are possible from this state
    - There are no entry conditions; any state may enter enter this state. 

Idle
    - In this state, the propulsion system is ready to process and execute firing schedules
    - Transitions to **handling fault** if any hardware fault is faulted (has persistently been signaled)
    - Transitions to **await pressurizing** or **pressurizing** upon reading a valid schedule
    - To enter this state, ``DCDC::SpikeDockDCDC_EN`` pin must be ``HIGH``

Await Pressurizing
    - In this state, the state machine has accepted the current schedule but has decided to wait until it is closer to the firing time before starting to pressurize
    - Transitions to **handling fault** if any hardware fault is faulted (has persistently been signaled)
    - Transitions to **pressurizing** if it meets the entry conditions for **pressurizing**
    - To enter this state, the current state must be **idle**, the schedule must be valid, and there must be more than enough time to pressurize

Pressurizing
    - In this state, propulsion system is currently pressurizing
    - Transitions to **handling fault** if any hardware fault is faulted (has persistently been signaled)
    - If ``Tank2`` pressure reaches ``prop.threshold_firing_pressure``, then transition to  **await firing**
    - If ``Tank2`` pressure fails to reach the ``prop.threshold_firing_pressure`` within ``prop.max_pressurizing_cycles`` and the ``prop.pressurize_fail`` has not been suppressed, then transition to **handling fault**. 
    - If ``Tank2`` pressure fails to reach the ``prop.threshold_firing_pressure`` within ``prop.max_pressurizing_cycles`` and the ``prop.pressurize_fail`` has not been suppressed, then transition to **await firing**. 
    - If the schedule is no longer valid, transition to **disabled**
    - To enter this state, the current state must be either  **await pressurizing** or **idle** and there must be exactly ``min_cycles_needed()-1`` cycles until it is time to fire

Await Firing
    - In this state, propulsion system has reached threshold pressure and will remain in this state until it is time to fire
    - Transitions to **handling fault** if any hardware fault is faulted (has persistently been signaled)
    - Transitions to **firing** when ``prop.cycles_until_firing`` is 0. On this cycle, the values of the firing schedule in the statefields will be copied to the schedule in the propulsion system driver. 
    - To enter this state, the current state must be **pressurizing** and the schedule must be valid

Firing
    - Transitions to **handling fault** if any hardware fault is faulted (has persistently been signaled)
    - On each cycle, copies the values of the driver firing schedule into the state machine firing schedule
    - Transitions to **idle** when all values of the firing schedule is 0
    - To enter this state, the current state must be **await firing** and ``prop.cycles_until_firing`` must be 0

Handling Fault
    - To enter this state, at least one of ``prop.pressurize_fail``, ``prop.overpressured``, ``prop.tank2_temp_high``, ``prop.tank1_temp_high`` is faulted 
    - Transitions to **venting** if the entry conditions of **venting** are meets
    - Transitions to **idle** if no fault is faulted

Venting
    - In this state, faults relating to overpressure or high temperatues have been detected for several consecutive control cycles
    - To enter this state, at least one of ``prop.overpressured``, ``prop.tank2_temp_high``, ``prop.tank1_temp_high`` is faulted
    - Transitions to **disabled** if after executing ``prop.max_venting_cycles`` number of venting cycles, the fault in question is still faulted 
    - If faults are faulted for both ``Tank1`` and ``Tank2`` at the same time, then the ``PropFaultHandler`` will coordinate the venting protocol to make the tanks take turn venting. 
    - If venting ``Tank1`` or ``Tank2`` due to high temperatures, transition to **idle** if the temperature falls below ``max_safe_temp`` (48 C)
    - If venting ``Tank2`` due to high pressure, transition to **idle** if pressure falls below ``max_safe_pressure`` (75 psi)
    - See the PropFaultHandler section below for details on the venting protocol

Pressurizing Protocol
---------------------
The pressurizing protocol consists of executing a sequence of `pressurizing cycles` up to a maximum 
of ``prop.max_pressurizing_cycles`` pressurizing cycles. 
A pressurizing cycle consists of `filling` period and a `cooling` period.  The filling period is given by
``prop.ctrl_cycles_per_filling`` and the cooling period is given by ``prop.ctrl_cycles_per_cooling``. 

Therefore, in a single pressurizing cycle, a valve on ``Tank1``, given by ``prop.tank1.valve_choice`` is opened for
``prop.ctrl_cycles_per_filling`` number of control cycles and then closed for ``prop.ctrl_cycles_per_cooling`` number of control cycles.
At each control cycle, ``Tank2`` pressure, given by ``prop.tank2.pressure``, is compared with ``prop.threshold_firing_pressure``. If ``Tank2``
pressure reaches the threshold firing pressure, then the state machine transitions to **firing**. 

If after ``prop.max_pressurizing_cycles``, the pressure of ``Tank2`` has not reached the threshold firing pressure,
then the ``prop.pressurize_fail`` fault is signaled. This fault has a persistence of 0, so if it has
not been previously suppressed by the ground, the state machine will transition to **handling fault**. 

If it has been suppressed by the ground, the state machine will transition to **await firing**. 

Interface
-----------------
The only method that is particularly useful to other subsystems is ``min_cycles_needed()``. The rest are documented here
solely because they are public. 

``min_cycles_needed()`` 
    Returns the minimum number of control cycles needed for a schedule to be accepted. If a schedule is accepted, the state machine transitions from **idle** to **await firing**.
``is_at_threshold_pressure()``
    Returns true if ``Tank2`` pressure has reached the threshold firing pressure
``is_tank2_overpressured()``
    Returns true if ``Tank2`` pressure has exceeded ``max_safe_pressure``
``is_tank1_temp_high()``
    Returns true if ``Tank1`` temperature has exceeded ``max_safe_temp``
``is_tank2_temp_high()``
    Returns true if ``Tank2`` temperature has exceeded ``max_safe_temp``
``check_current_state(prop_state_t expected)``
    Returns true if the current state is the expected state
``can_enter_state(prop_state_t desired_state)``
    Returns true if the state machine can enter the desired state from its current state
``write_tank2_schedule()``
    Copies the state machine firing schedule from the statefields to the propulsion system driver schedule
    

State Fields
----------------
prop.state
    The current state of the state machine (values defined in ``prop_state_t.enum``)
prop.cycles_until_firing
    Determines the firing time relative to the current control cycle count
prop.sched_valve1
    The schedule for ``Tank2`` ``valve 1`` in milliseconds
prop.sched_valve2
    The schedule for ``Tank2`` ``valve 2`` in milliseconds
prop.sched_valve3
    The schedule for ``Tank2`` ``valve 3`` in milliseconds
prop.sched_valve4
    The schedule for ``Tank2`` ``valve 4`` in milliseconds
prop.max_venting_cycles
    The maximum number of venting cycles to attempt before disabling the propulsion system
prop.ctrl_cycles_per_closing
    The number of control cycles to wait between opening valves during a venting cycle (default 1 second worth of control cycles)
prop.max_pressurizing_cycles
    The maximum number of pressurizing cycles to attempt before transitioning to **handling fault**
prop.threshold_firing_pressure
    The minimum pressure needed in ``Tank2`` to execute a firing schedule
prop.ctrl_cycles_per_filling
    The number of control cycles to open the ``Tank1`` valve during a pressurizing cycle (default 1 second worth of control cycles)
prop.ctrl_cycles_per_cooling
    The number of control cycles to wait between opening a ``Tank1`` valve during a pressurizing cycle (default 10 seconds worth of control cycles)
prop.tank1.valve_choice
    Specifies the ``Tank1`` valve that will be opened during pressurizing or venting cycles (default is 0 for the ``primary valve``)
prop.tank2.pressure
    The current pressure of ``Tank2`` given by its pressure sensor
prop.tank2.temp
    The current pressure of ``Tank2`` given by its temperature sensor
prop.tank1.temp
    The current pressure of ``Tank1`` given by its temperature sensor
prop.pressurize_fail
    Fault field indicating that the state machine has executed ``prop.max_pressurizing_cycles`` and has still failed to reach ``prop.threshold_firing_pressure``
prop.overpressured
    Fault field indicating that the pressure in ``Tank2`` exceeds ``max_safe_pressure`` (75 psi)
prop.tank1_temp_high
    Fault field indicating that the temperature in ``Tank1`` exceeds ``max_safe_temp`` (48 C)
prop.tank2_temp_high
    Fault field indicating that the temperature in ``Tank2`` exceeds ``max_safe_temp`` (48 C)

Propulsion System Fault Handler
================================
The Propulsion System Fault Handler is defined in ``PropFaultHandler.h`` and implemented in 
``PropFaultHandler.cpp``. It is only active when the ``prop_state`` is in **venting** or in **handling fault**. 

Four possible faults have been defined by the Propulsion Subsystem: ``prop.pressurize_fail``, ``prop.overpressured``, ``prop.tank2_temp_high``, ``prop.tank1_temp_high``.
Handling ``prop.pressurize_fail`` is deferred to the ground. The state machine will attempt to resolve the other three faults in the **venting** state. 


Venting Protocols
---------------------------
The protocol for venting one tank is similar to the the protocol for pressurizing.
The maximum number of venting cycles is given by ``prop.max_venting_cycles``. The number of control cycles 
to open a valve is given by ``prop.ctrl_cycles_per_filling``.

Venting ``Tank1`` is almost the same as pressurizing except that the period between
opening the valve has been shorten to ``prop.ctrl_cycles_per_closing`` instead of 
``prop.ctrl_cycles_per_cooling``. 

Venting ``Tank2`` is the same as venting ``Tank1`` except the state machine will 
open a different valve from ``Tank2`` after each venting cycle. Whereas ``Tank1`` 
always vents through ``prop.tank1.valve_choice``, ``Tank2`` will cycle through
its four valves. 

The state machine leaves the **venting** state when the fault(s) associated with the
tank that it is currently venting are no longer faulted. 

When faults are active from both tanks indicating that the state machine should
vent both tanks, the ``PropFaultHandler`` is responsible for making the tanks take
turns venting. ``PropFaultHandler`` will save the current value of ``prop.max_venting_cycles`` and
then set ``prop.max_venting_cycles`` to 1. This will cause the venting cycle to end after 1 cycle
and transition unconditionally to **handling fault**. ``PropFaultHandler`` will then
be responsible for counting the number of venting cycles executed. It will consider a single
venting cycle to consist of venting both ``Tank1`` and ``Tank2`` for one venting cycle each. 

Should one of the faults become unsignaled during this protocol, ``PropFaultHandler`` will
restore the old value of ``prop.max_venting_cycles`` and the continue to vent if
necessary.


Propulsion System Driver
========================
This section details the purpose of the propulsion system driver, its components, 
and its public interface. 

The driver is responsible for opening and closing valves on both
tanks and executing the firing schedule. The protocols for validating the firing schedule
and executing the pressurizing and venting operations are left to the ``PropController``. 

The Propulsion System Driver is defined in ``PropulsionSystem.hpp`` and implemented
in ``PropulsionSystem.cpp``. It consists of three singleton (static) 
objects: ``PropulsionSystem``, ``Tank1``, and ``Tank2``. The objects are globally
accessible, but subsystems are advised to not directly interact with these objects. 
The public interface is documented here for completion. 

The two ``Tank1`` valves are indexed (``valve_idx``) at 0 and 1. The four ``Tank2`` valves are indexed at 0, 1, 2, and 3. 

Interface
-----------------
``PropulsionSystem.is_functional()`` 
    Returns true if the Propulsion System is operational (i.e. able to execute firing schedules and read sensors). 
``Tank1.get_temp()`` 
    Returns the temperature sensor reading for ``Tank1`` in degrees Celcius. 
``Tank2.get_temp()`` 
    Returns the temperature sensor reading for ``Tank2`` in degrees Celcius. 
``Tank2.get_pressure()`` 
    Returns the pressure sensor reading for ``Tank2`` in psi. 
``Tank1.is_valve_open(valve_idx)``
    Returns true if the Tank1 valve at ``valve_idx`` is opened
``Tank2.is_valve_open(valve_idx)``
    Returns true if the ``Tank2`` valve at ``valve_idx`` is opened
``PropulsionSystem.set_schedule(valve1, valve2, valve3, valve4)``
    Sets the firing schedule for the four ``Tank2`` valves
``PropulsionSystem.reset()``
    Shuts off all the valves in both ``Tank1`` and ``Tank2`` and clears the firing schedule

``PropulsionSystem.start_firing()``
    Executes the firing schedule immediately
``PropulsionSystem.disable()``
    Ends the firing schedule regardless of whether the entirety of the firing schedule has been executed

``PropulsionSystem.open_valve(tank, valve_idx)``
    Opens the valve at ``valve_idx`` for ``tank``
``PropulsionSystem.open_valve(tank, valve_idx)``
    Closes the valve at ``valve_idx`` for ``tank``

Implementation Notes
----------------------------------

When ``start_firing()`` is called, an interrupt timer will cause an interrupt every 3ms. The interrupt handler
is responsible for opening the valves for the duration of the assigned schedules and closing
the valves when they are within 10ms of completing their schedules. The interrupt timer is disabled by
calling ``PropulsionSystem.disable()``. 

While the interrupt timer is enabled, the schedule may not be modified in any way.

Calling ``PropulsionSystem.reset()`` implicitly calls ``PropulsionSystem.disable()``. 


Operational Notes
====================

***The preconditions for entering a state can be bypassed by manually setting prop_state to the desired state.***

This is because ``can_enter()`` is only evaluated when the state machine itself
is attempting to transition states. Be warned that it may be possible for the 
state machine to be indefinitely stuck in a state since it may only transition to a new state
if it meets that new state's preconditions. 

***To make a firing occur immediately, set the firing schedule and transition to await_firing***

To force the state machine to immediately execute a schedule, set ``prop.cycles_until_firing`` to 0
and set ``prop_state`` to **await firing**. This will cause the firing schedule to immediately
be copied into the driver and executed on the next control cycle. Note that each of the
valve schedules must still be no greater than 1000 ms, otherwise, the driver will ignore the entire firing schedule. 

***Do not manually set prop_state to firing***. 

Manually setting ``prop_state`` to **firing** is counterproductive and will not cause
the schedule to be executed. This is so because the call to ``PropulsionSystem.start_firing()`` occurs in the
entrance protocol of the **firing** state, which can only be executed when transitioning from 
**await firing**. 

***Do not manually set prop_state to a state other than disabled while it is pressurizing or venting.*** 

Manually setting ``prop_state`` to **disabled** can be safely done from any state.  
It is, however, not advisable to manually set ``prop_state`` to a state other than **disabled** 
while it is in the **pressurizing** or the **venting** state. 
The reason for this is because valves are manually opened by the ``PropController``. If the state machine
is interrupted while the valves are opened, the ``PropController`` will not get the opportunity 
to close these valves.

***The Propulsion System does not work if DCDC Spike and Hold pin is not enabled.***

The Propulsion System requires that ``DCDC::SpikeDockDCDC_EN`` pin be high. 
The state machine will still execute if the pin is not high, but its behavior is undefined. 
The state machine will likely erroneously detect faults. 


***The Propulsion System will close the valve when fewer than 10ms remain on its schedule.***

For example, if a ``Tank2`` valve is scheduled to fire for 200 ms, then it is guaranteed to 
open for at least 190 ms but no more than 200 ms. Once firing, schedules are checked every 3 ms. 
Therefore, all schedules under 10ms will be considered valid by the state machine
but will not be executed by the Propulsion System driver. 


***A schedule can technically be cancelled at any time before the scheduled firing time.***

The state machine does not provide any convenient way to accomplish this. If a subsystem
wishes to cancel a firing schedule, then it may do so as long as ``prop.cycles_until_firing`` 
is not 0. The subsystem can set prop_state to **idle** 
and invalidate the schedule by clearing ``prop.cycles_until_firing``. Similarly, if the subsystem
would like to replace the schedule with a different schedule, then that subsystem should write the schedule 
to the appropriate state fields and then manually set ``prop_state`` to **idle**. 

***Setting prop_state to disabled will not clear the firing schedule.***

A subsystem can therefore pause or delay the schedule by setting ``prop_state`` to
**disabled**. Since the firing time is relative to the current control
cycle, a firing schedule that is valid prior to disabling the state machine will still be
valid should the subsystem set ``prop_state`` to the state it was in prior to being **disabled**. 

Known Issues
-------------
When testing the Propulsion System and running multiple tests within a single process, 
it does not matter that the ``registry`` or the ``TestFixture`` is destroyed between tests. 
Since the objects are static, the results of previous tests will always persist, so
to avoid strange test results, the ``TestFixture`` should reset the fields of the static
objects. 

