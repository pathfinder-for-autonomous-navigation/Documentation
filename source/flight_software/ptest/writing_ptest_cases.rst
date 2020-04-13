====================
PTest Cases
====================

Take a read at :doc:`testing_architecture` before looking at this page. Once you do, you know
that StateSession is the core of how a user interacts with flight software instances. The
state command prompt provides a manual way to read and write state from flight software; ptest
cases provide a powerful, Python-based, automated way to transact state fields. This allows
for the creation of automated simulations and testcases on our spacecraft.

See below for an inheritance diagram of the ptest case base classes:

.. figure:: testcase_inheritance.png
   :align: center
   :alt: PTestcase UML diagram

   Diagram depicting the relationship between the base classes of ptest cases.


Writing a PTest Case
====================
Is as simple as inheriting from either ``SingleSatOnlyCase`` or ``MissionCase``, as diagrammed above.
These base classes contain some utilities for reading and writing state to either 1 or 2 satellites,
respectively. 

The base ptest class also exposees a set of `FSWEnum` objects which create dual-indexing of common
flight software enums (like mission state, ADCS state, etc.) by both name and numerical value.
See the example below of how you can set the satellite mission state to "manual".


Examples of writing a state field through a ptest case derived from ``SingleSatOnlyCase``:

| ``self.ws("pan.state", self.mission_states.get_by_name("manual"))``
| ``self.ws("dcdc.ADCSMotor_cmd", True)``
| ``self.ws("adcs_cmd.rwa_speed_cmd", [0,0,0])``


``self.ws()`` accepts the statefield name and a int, float, bool, or a list of them.

Examples of a reading state field through a ptest case derived from ``SingleSatOnlyCase``:

| ``self.rs("adcs_monitor.mag_vec")``
| ``self.rs("adcs_cmd.havt_reset0")``

| ``self.rs()`` returns the proper type of variable associated with each state field.
| ``self.rs("adcs_cmd.rwa_speed_cmd")`` returns a list of floats.

Listing of Ptest Cases
======================

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

MAG Checkout
############

The checkout case pulls ten readings from the mag, ``cycle()`` ing the FC between each reading.
It checks to make sure the readings change over time, 
and that the magnitude of the readings are reasonable 
(within expected earth magnetic field strength expectations).

MAG Independence Checkout
############

If both magnetometers are functional, this test section will disable MAG1, and check that MAG2
still works. The same checkout is performed on MAG1 with MAG2 disabled. The independence checkouts 
re-run the same checkouts as above.

GYR Checkout
############

The checkout case pulls ten readings from the gyro, ``cycle()`` ing the FC between each reading.
It checks to make sure the readings change over time, and that the magnitude of the readings are reasonable.

TODO FURTHER CHECKOUTS
######################