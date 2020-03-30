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

SingleSatOnlyCase
-----------------

ws rs

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