====================
PTest Cases
====================

PTest Cases are the special top-level testcases that can run multi-satellite, sim/no-sim HITLs/HOOTLs.
Obviously, they hold enormous importance in ensuring the safety and reliability of our satellite, because they
provide the highest-fidelity, most complex testing environment available to us besides the actual environment
of space.

TODO talk about structure, how to write one

See below for an inheritance diagram of the ptest case base classes:

.. figure:: testcase_inheritance.png
   :align: center
   :alt: PTestcase UML diagram

   Diagram depicting the relationship between the base classes of ptest cases.


Writing a PTest Case
--------------------

TODO:

FSWEnum

SingleSatOnlyCase
-----------------

Examples of writing a state field through a ptest case:

| ``self.ws("pan.state", self.mission_states.get_by_name("manual"))``
| ``self.ws("dcdc.ADCSMotor_cmd", True)``
| ``self.ws("adcs_cmd.rwa_speed_cmd", [0,0,0])``


``self.ws()`` accepts the statefield name and a int, float, bool, or a list of them.

Examples of a reading state field through a ptest case:

| ``self.rs("adcs_monitor.mag_vec")``
| ``self.rs("adcs_cmd.havt_reset0")``

| ``self.rs()`` returns the proper type of variable associated with each state field.
| ``self.rs("adcs_cmd.rwa_speed_cmd")`` returns a list of floats.

Running a Ptest Case
--------------------

Useful Commands:

| ``ws cycle.auto true``
| DebugTask will no longer wait for ``cycle.start`` to be true before finishing.

ADCSCheckoutCase
----------------

The ADCSCheckoutCase

Initialization
##############

1. Sets the mission state to ``manual``
2. Sets the ADCS state to ``point_manual``
3. Set the RWA mode to ``RWA_SPEED_CTRL``
4. Set the intial RWA speed command to ``[0,0,0]``
5. Turn on the ADCS Motor DCDC.

HAVT Checkout
#############

The HAVT checkout begins by resetting all devices on the ADCSC.

It then pattern matches the read HAVT table with existing cataloged test-beds. If no match is found,
the user is alerted.

Then all devices are disabled and reset, to make sure the devices are all properly cycled,
and returned to the initially read HAVT table.

IMU Checkout
############

The checkout case pulls ten readings from the mag, ``cycle()`` ing the FC between each reading.
It checks to make sure the readings change over time, 
and that the magnitude of the readings are reasonable 
(withim expected earth magnetic field strength expectations).

GYR Checkout
############

The checkout case pulls ten readings from the gyro, ``cycle()`` ing the FC between each reading.
It checks to make sure the readings change over time, and that the magnitude of the readings are reasonable.

TODO FURTHER CHECKOUTS
######################