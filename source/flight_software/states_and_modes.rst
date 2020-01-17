================
States and Modes
================

The propulsion and radio subsystems of the spacecraft are state machines that move autonomously upon each control cycle.
Since the mission manager wants to assert these subsystems "ON" for some high-level spacecraft states and not others, we
can't just command these subsystem state machines into a particular state or the state machine will get stuck there. Instead,
we use the concept of a "mode" as an on/off switch for the autonomous operation of a state machine. If the mode of a state
machine is "disabled", then the state machine's transitions are shut off and it remains in the last state it entered. If the
mode of a state machine is "active", then it may autonomously step through state machine transitions.
