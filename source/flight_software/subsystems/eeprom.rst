================
Persistent State
================

In any computer system, it is important to keep track of persistent state that should survive
expected or unexpected reboots of the system. For our system, the EEPROM is the only reliable
means of state-saving, and we have an ``EEPROMController`` control task that manages the saving
of certain state fields to the EEPROM.

Fields written to the EEPROM are all unsigned ints. Below is a list of the fields we save, the
frequency at which we save them, and the rationale for why we save them to the EEPROM.

TODO fill out entire table

+--------------------------+-----------------------+-------------------------------------------------------------+
| State field name         | Period of Save        | Rational for saving field to EEPROM                         |
|                          | (# of control cycles) |                                                             |
+--------------------------+-----------------------+-------------------------------------------------------------+
| ``ClockManager``         | 0                     |                                                             |
+--------------------------+-----------------------+-------------------------------------------------------------+