============================
Propulsion System Management
============================

Overview
=========
The purpose of this document is to detail the Propulsion Controller Subsystem of 
Flight Software. The Propulsion System is responsible for generating thrust in order to accelerate
the satellite. 

The software components of the Propulsion System consists of the Propulsion System driver,
the Propulsion System Controller, and the Propulsion System Fault Handler. 

The hardware components of the Propulsion System consists of the inner tank, the outer tank,
the inner tank temperature sensor, the outer tank temperature sensor, the 
outer tank pressure sensor, the two intertank valves, and the four outer tank valves.  


CONOPS
======
The propulsion system hardware consists of an inner tank, 
``Tank1``, and an outer tank, ``Tank2``. 

Tank1
------
Tank1 is responsible for pressurizing Tank2. At the start of the mission,
Tank1 is filled with liquid propellant. The propellant is released into ``Tank2`` through
one of the two intertank valves, which causes pressure to build up in Tank2. The two 
valves on Tank1 are referred to as the ``primary valve`` and the ``backup valve``.
Tank1 also has a temperature sensor. 

Tank2
-----
``Tank2`` is responsible for accelerating the satellite. It consists of four valves 
arranged tetrahedrally: ``valve1``, ``valve2``, ``valve3``, ``valve4``. 
Each valve is assigned a schedule, and the four valve schedules 
along with a firing time consist of a firing schedule. The direction of acceleration 
is, therefore, determined by the firing schedule.

Firing Schedules
-----------------
The firing time is the number of control cycles from the current control cycle
at which the valves shall fire. For example, if the current control cycle is
13, then a firing time of 8 means that the valves shall fire when the satellite
is in control cycle 21. 

The valve schedules are in units of milliseconds with a maximum value of 1000. When
the satellite enters the control cycle specified by the firing time, the valves will
open for the duration of their assigned schedules. 

The Propulsion System Controller will only execute what it considers a valid firing
schedule. Any schedule considered invalid will be ignored. 

If any valve is assigned a schedule greater than 1000, then that schedule is invalid. 
If the Propulsion System Controller believes that it will not have enough time to
pressurize ``Tank2`` by the desired firing time cycle, then this schedule will also
be considered invalid. 

Propulsion Controller State Machine
====================================
This section details the Propulsion System Controller state machine. The state machine
interacts with the propulsion system through the propulsion system driver (documented
in the next section). 

The Propulsion Controller State Machine is defined in ``PropulsionSystem.hpp`` and
implemented in ``PropulsionSystem.cpp``. 

The firing time is determined by ``prop.cycles_until_firing``. It is time to fire, when 
``prop.cycles_until_firing`` is 0. 

There are techncially two copies of the firing schedule: the state machine schedule and the driver schedule. 
The state machine schedule may be manipulated by any subsystem. The values in this schedule are copied to the driver
schedule one cycle prior to the firing time. 

Public Interface
----------------
prop_state_f
    The current state of the state machine. 
prop.cycles_until_firing
    Determines the firing time relative to the current control cycle count


Propulsion Controller States
----------------------------
This section details state transitions and entry conditions. 

Disabled
    - In this state, propulsion system will defer decisions to the ground (or other subsystems) and will only read the sensor values
    - No transitions are possible from this state
    - No entry conditions; any state may enter enter this state. 

Idle
    - In this state, propulsion system is ready to process and execute firing schedules
    - Transitions to **handling fault** if any fault is faulted
    - Transitions to **await pressurizing** or **pressurizing** upon reading a valid schedule
    - To enter this state, ``DCDC::SpikeDockDCDC_EN`` pin must be ``HIGH``

Await Pressurizing
    - In this state, propulsion system has decided to wait until it is closer to the firing time before starting to pressurize
    - Transitions to **handling fault** if any fault is faulted. 
    - Transitions to **pressurizing** if it meets the entry conditions for **pressurizing**
    - To enter this state, the current state must be **idle**, the schedule must be valid, and there is more than enough time to pressurize

Pressurizing
    - In this state, propulsion system is currently pressurizing
    - To enter this state, the current state must be either  **await pressurizing** or **idle** and there must be exactly ``min_cycles_needed()-1`` cycles until it is time to fire
    - Transitions to **handling fault** if any fault is faulted. 
    - If ``Tank2`` pressure reaches ``prop.threshold_firing_pressure``, then transition to  **await firing**
    - If ``Tank2`` pressure fails to reach the ``prop.threshold_firing_pressure`` within ``prop.max_pressurizing_cycles`` and the ``prop.pressurize_fail`` has not been suppressed, then transition to **handling fault**. 
    - If ``Tank2`` pressure fails to reach the ``prop.threshold_firing_pressure`` within ``prop.max_pressurizing_cycles`` and the ``prop.pressurize_fail`` has not been suppressed, then transition to **await firing**. 
    - If the schedule is no longer valid, transition to **disabled**

Await Firing
    - In this state, propulsion system has reached threshold pressure and will remain in this state until it is time to fire
    - Transitions to **handling fault** if any fault is faulted
    - Transitions to **firing** when ``prop.cycles_until_firing`` is 0. On this cycle, the values of the firing schedule will be copied to schedule in the propulsion system driver. 
    - To enter this state, the current state must be **pressurizing** and the schedule must be valid

Firing
    - Transitions to **handling fault** if any fault is faulted
    - On each cycle, copies the values of the driver firing schedule into the state machine firing schedule. 
    - Transitions to **idle** when all values of the firing schedule is 0.
    - To enter this state, the current state must be **await firing** and ``prop.cycles_until_firing`` must be 0

Handling Fault
    - To enter this state, at least one of ``prop.pressurize_fail``, ``prop.overpressured``, ``prop.tank2_temp_high``, ``prop.tank1_temp_high`` is faulted 
    - Transitions to **venting** if the entry conditions of **venting** are meets
    - Transitions to **idle** if no fault is faulted

Venting
    - To enter this state, at least one of ``prop.overpressured``, ``prop.tank2_temp_high``, ``prop.tank1_temp_high`` is faulted
    - Transitions to disabled if after executing ``prop.max_venting_cycles`` number of venting cycles, the fault in question is still faulted 
    - 

Operational Notes
====================
Manually setting `prop_state` to **firing** is counterproductive and will not cause
the schedule to be executed. This is so because the call to ``PropulsionSystem.start_firing()`` occurs in the
entrance protocol of the **firing** state, which can only be executed when transitioning from 
**await firing**. 

The Propulsion System requires that ``DCDC::SpikeDockDCDC_EN`` pin be high. If a 
subsystem decides to set the Propulsion System state to idle without checking that
this pin is high, then the state machine may still execute, but the
sensors will not work and the valves will not fire. 

The Propulsion System will close the valve when fewer than 10ms remains on its schedule.
For example, if a ``Tank2`` valve is scheduled to fire for 200 ms, then it is guaranteed to 
open for at least 190 ms but no more than 200 ms. Once firing, schedules are checked every 3 ms. 
Therefore, all schedules under 10ms will be considered valid by the state machine
but will not be executed by the Propulsion System driver. 

The preconditions for entering a state can be bypassed by setting prop_state
to the desired state since ``can_enter()`` is only evaluated when the state machine itself
is attempting to transition states. Be warned that it may be possible for the 
state machine to be indefinitely stuck in a state since it may only transition to a new state
if it meets that new state's preconditions. 

A schedule can technically be cancelled at any time before the scheduled firing time. 
The state machine does not provide any convenient way to accomplish this. If a subsystem
wishes to cancel a firing schedule, then the subsystem can set prop_state
to ``prop_state_t::idle`` and invalidate the schedule by clearing ``prop.cycles_until_firing``. 

Setting prop_state to ``prop_state_t::disabled`` will not clear the firing schedule. 
A subsystem can therefore pause or delay the schedule by setting prop_state to
``prop_state_t::disabled``. Since the firing time is relative to the current control
cycle, a valid firing schedule will still be valid should a subsystem set prop_state 
to a state other than ``prop_state_t::disabled``. 

Propulsion System Driver
========================
This section details the purpose of the propulsion system driver, its components, 
and its public interface. 

The driver is responsible for opening and closing valves on both
tanks and executing the firing schedule. The protocol for validating the firing schedule
and executing the pressurizing and venting operations are left to higher-level propulsion
controller state machine. 

The Propulsion System Driver is defined in ``PropulsionSystem.hpp`` and implemented
in ``PropulsionSystem.cpp``. It consists of three singleton (static) 
objects: ``PropulsionSystem``, ``Tank1``, and ``Tank2``. The objects are globally
accessible, but subsystems are advised to not directly interact with these objects. 
The public interface is documented here for completion. 

``Tank1`` has two valves indexed (``valve_idx``) at 0 and 1. ``Tank2`` has four valves indexed at 0, 1, 2, and 3. 

Interface
-----------------
``PropulsionSystem.is_functional()`` 
    returns ``true`` if the Propulsion System is operational (i.e. able to execute firing schedules and read sensors). 
``Tank1.get_temp()`` 
    returns the temperature sensor reading for ``Tank1`` in degrees Celcius. 
``Tank2.get_temp()`` 
    returns the temperature sensor reading for ``Tank2`` in degrees Celcius. 
``Tank2.get_pressure()`` 
    returns the pressure sensor reading for ``Tank2`` in psi. 
``Tank1.is_valve_open(valve_idx)``
    returns true if the Tank1 valve at ``valve_idx`` is opened
``Tank2.is_valve_open(valve_idx)``
    returns true if the ``Tank2`` valve at ``valve_idx`` is opened
``PropulsionSystem.set_schedule(valve1, valve2, valve3, valve4)``
    sets the firing schedule for the four ``Tank2`` valves
``PropulsionSystem.reset()``
    shuts off all the valves in both ``Tank1`` and ``Tank2`` and clears the firing schedule

``PropulsionSystem.start_firing()``
    executes the firing schedule immediately
``PropulsionSystem.disable()``
    ends the firing schedule regardless of whether the entirity of the firing schedule has been executed

``PropulsionSystem.open_valve(tank, valve_idx)``
    opens the valve at ``valve_idx`` for ``tank``
``PropulsionSystem.open_valve(tank, valve_idx)``
    closes the valve at ``valve_idx`` for ``tank``

Implementation Notes
----------------------------------

When ``start_firing()`` is called, an interrupt timer will cause an interrupt every 3ms. The interrupt handler
is responsible for opening the valves for the duration of the assigned schedules and closing
the valves when they are within 10ms of completing their schedules. The interrupt timer is disabled by
calling ``PropulsionSystem.disable()``. 

While the interrupt timer is enabled, the schedule may not be modified in any way.

Calling ``PropulsionSystem.reset()`` implicitly calls ``PropulsionSystem.disable()``. 


Known Issues and Enhancements
-----------------------------
When testing the Propulsion System and running multiple tests within a single process, 
it does not matter that the ``registry`` or the ``TestFixture`` is destroyed between tests. 
Since the objects are static, the results of previous tests will always persist, so
to avoid strange test results, the ``TestFixture`` should reset the fields of the static
objects. 

