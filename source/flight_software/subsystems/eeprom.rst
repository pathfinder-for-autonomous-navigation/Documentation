================
Persistent State
================

In any computer system, it is important to keep track of persistent state that should survive
expected or unexpected reboots of the system. For our system, the EEPROM is the only reliable
means of state-saving, and we have an ``EEPROMController`` control task that manages the saving
of certain state fields to the EEPROM.

Fields written to the EEPROM can either be signed/unsigned ints/chars, or booleans. This makes
it easy to serialize or deserialize their values in and out of EEPROM. The list of EEPROM-saved
fields can be found by running the Telemetry Info Generator (TIG); the "eeprom_saved_fields" key
inside the produced JSON file by the telemetry info generator lists the set of state fields and their
**saving period**, i.e. the number of cycles between queries of their value to save to the EEPROM.

The EEPROM is emulated in HOOTL via a JSON file that is stored on-disk.
