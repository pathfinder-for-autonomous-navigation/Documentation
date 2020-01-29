
The propulsion system consists of an inner tank (Tank1) and the (outer) thrust tank (Tank2). 
There are two valves from Tank1 to Tank2 - the primary valve and the backup valve. We 
refer to these valves as the Tank1 valves. 
Tank2 has four valves that are arranged tetrahedrally. 
The purpose of the propulsion system is to pressurize Tank1 and then open the valves in Tank2
at a predetermined schedule. This will create a force in the opposite of direction. 
The remainder of this document describes the Propulsion System driver. 

The propulsion system (PropulsionSystem.hpp) driver provides functionality for:

1. opening and closing valves on both tanks
2. setting and enforcing the thrust schedule 
 
 It consists of a static Tank1 (inner tank) and Tank2 (thrust tank) data objects. 
 
 Specifications:
 Tank1 valves are at numbered 0, 1
 Tank2 valves are at numbered 0, 1, 2, 3
 mandatory_wait_time is the duration of time after opening a valve before 
 we can open another valve. Tank1 10*1000 ms. Tank2 is 3ms
 
 State Definitions:
 "enabled" means that the IntervalTimer for tank2 is on. This implies that:
      - either tank2 is "scheduled (to fire)" 
      - or tank2 has already fired
 "scheduled (to fire)" means that tank2 currently has a scheduled start time
 in the future
 
 "start time" refers to the time in micros at which tank2 will fire
 Prop controller is responsible for pressurizing tank1 before asking tank2 to fire
 
 Dependencies: 
 SpikeAndHold must be enabled in order to use this system
 
 Usage:
 - Call setup to setup this device
 - Use set_schedule to set a firing schedule for tank2. 
 - Use enable to turn on the schedule when we are close to the start_time.
 - Use disable to prematurely cancel the schedule.
 - Use clear_schedule to reset the schedule and start_time to 0.
 - Use is_tank2_ready to check if tank2 is scheduled to fire right now or in the future
 - Use is_firing to check if we are still executing the schedule
 - Use disable to stop the timer when is_firing() returns false
 
 Implementation Notes and Warnings:
 The only public methods that can change the states in tank1 or tank2 are the
 methods in PropulsionSystem.
 
 TimedLock enforces
  - tank2 scheduled start time and the 
  - tank1 10s mandatory wait time
 IntervalTimer (thrust_valve_loop_timer) enforces
  - tank2 3ms mandatory wait time
  - tank2 firing schedule
 
 Only tank2 has a schedule since only tank2 uses the IntervalTimer to fire.
 
 No mandatory wait time is enforced when opening valves from different tanks. For example,
 suppose we open a valve on tank1. Although we cannot open the other valve for another 10s,
 we can immediately open any valve on tank2. It is left to the controller to make sure
 that this does not happen. 
 