============================
Flight Software Build System
============================

Flight Software's build system is based on PlatformIO and provides the following set of environments:

- ``fsw_native_[leader|follower]`` : HOOTL environments. The leader/follower monikers exist because the
  two environments compile slightly different constants for the hardware-defined leader/follower
  spacecrafts (not to be confused with the software designation of leader/follower for each spacecraft.)
  In practice, we almost always use ``fsw_native_leader`` for HOOTLs as a matter of convention, since
  the hardware constants do not affect the HOOTL much.

- ``fsw_teensy3[5|6]_hitl_[leader|follower]`` : HITL environments for both Teensy 3.5 and Teensy 3.6.

- ``fsw_native_ci`` : Flightless environment that only exists so that symbol-based debugging of unit
  tests is possible.

- ``fsw_flight_[leader|follower]``: Flight code for leader and follower spacecraft.

- ``gsw_downlink_parser``: Parses the incoming binary data packets from the spacecraft telemetry into intelligible
  JSON for consumption by ground software systems.

- ``gsw_uplink_producer``: Produces a binary-encoded packet of uplink data based on a user-specified JSON list
  of state fields and values for those fields.

- ``gsw_telem_info_generator``: This purely informational environment produces a utility for listing the telemetry
  values and associated telemetry flows that exist on the spacecraft. This utility is useful for reviewing telemetry
  periodically for correctness.

The following compiler macros are used liberally across flight software to conditionally compile certain
parts of the codebase in certain environments:

- ``DESKTOP`` macro, when used, indicates a certain piece of code should only be compiled for ``fsw_native*`` environments
  or ``gsw*`` environments.

- ``FUNCTIONAL_TEST`` macro, when used, indicates a certain piece of code should only be compiled for HOOTL/HITL, but not flight.
- ``FLIGHT`` macro, when used, indicates a certain piece of code should only be compiled for flight, but not HOOTL/HITL.
- ``GSW`` macro, when used, indicates a certain piece of code should only be compiled for ``gsw*`` environments.


