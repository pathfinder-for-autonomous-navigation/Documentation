==============
Docking System
==============

The docking system has three components: the docking magnets, the docking motor, and the
docking switch. The latter two components are controllable and readable by flight software.

Our docking at a range of 1 m happens passively via 4 strong neodymium magnets stored in
the docking adapters of the two satellites. During nominal mission operation, the strong
fields created by these magnets would wreak havoc with the onboard magnetometers, so
they are nominally stowed in a quadrupole configuration so that they have very little
net magnetic field past the docking face. This is achieved by having two magnets point N-S,
and another, adjacent set of magnets point S-N.

The docking magnets are reconfigured from their quadrupole arrangement to a dipole arrangement
via the docking motor, which is a stepper motor that turns one of the magnet pairs in the
right direction for achieving the correct polarity.

During the docking operation, both satellites have a switch on their docking face that is depressed
when the satellites dock with one another. The switch is how we detect that the actual docking
operation occurred.

Operation of the Docking Motor
==============================
The magnets are initially in the docking configuration, and thus the docking motor is only necessary for undocking and redocking after the first successful docking of the two satellites has occured. There are four main statefields useful in checking and changing the state of the docking motor. These are *docksys.dock_config*, which is false when the magnets are in the undocked position and true when in docked position, *docksys.is_turning*, which is true if the motor is being signalled to step and false otherwise, *docksys.docked*, which is true if the docking switch is depressed and false otherwise, and *docksys.config_cmd*, the writeable state that tells the system what configuration the magnets should be in (true for docked, false for undocked). 

Two additional writeable statefields exist, *docksys.step_angle* and *docksys.step_delay*. The step angle of the motor is constant based on its setup, but since the motor data sheet did not match observed values this step angle was calculated from experimental trials and so we leave it adjustable. The step delay determines how fast the motor is turning. The load from the magnets can vary based on position and changes to the setup from shaking during the mission, as can power from the battery. Thus, the step delay can be changed if the system is not successfully changing configuration as longer delays will yield more torque and control, although they are slower. The *docksys.step_delay* is useful in troubleshooting issues if the system does not successfully turn with the initial values.

To operate the docking motor, the *docksys.config_cmd* should be sent from the ground and the motor should turn into the desired position within a minute. If that does not work automatically, the *docksys.step_delay* value should be increased and the process repeated. 
