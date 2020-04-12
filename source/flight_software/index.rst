=========================================
Flight Software and Systems Documentation
=========================================

This section of the documentation contains documentation on both the flight software and the
PAN satellite's subsystem architectures. The two ideas go hand-in-hand, which is why their
documentation is woven together. This section is primarily meant to be *design* documentation,
although there is some user documentation as well.

Installing Flight Software
==========================

The code for flight software is available `here <https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware/>`_.
Follow the instructions in the README under ``ptest`` to set up the code for development and testing.

FlightSoftware is dependent on a build system called `PlatformIO <https://platformio.org>`_. See :doc:`build_system` to
see how this system is set up for our use.

Structure of Flight Software Repository and Documentation
=========================================================

This repository is very monolithic and actually contains three separate products:

- FlightSoftware, which runs on the Flight Controller of our spacecraft
- ADCSSoftware, which runs on the Attitude Control subsystem of our spacecraft
- PTest, a hardware-out-of-the-loop (HOOTL) and hardware-in-the-loop (HITL) testing platform designed to
  provide mission-fidelity testing.

Unless otherwise specified, this documentation talks about the design of Flight Software, not the other
platforms. Documentation for ADCSSoftware may be forthcoming, but for now it suffices to know that it exists
to service the hardware described in :doc:`subsystems/adcs`. However, because PTest is an extensive platform that
is still being heavily developed, we are producing good documentation for it here (see the table of contents below.)

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   components
   desktop_operation
   serializer
   build_system
   mission_manager
   fault_management
   subsystems/index
   ptest/index
