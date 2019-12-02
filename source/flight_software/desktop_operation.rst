====================================
Desktop Operation of Flight Software
====================================

See :doc:`../psim/testing_architecture` before reading this document.

One of the great things about PAN's flight software is that it can run both on a tiny ARM-based microcontroller
(the Teensy 3.5/3.6) and on any Linux or Mac platform. We call the latter version of flight software the
`native binary`, because our build system, `PlatformIO <http://platformio.org>`_, calls desktop platforms
the "native" platform.

Here we describe some of the pros and cons of using desktop vs. flight software and the implementation differences
between the two versions of flight software.

Pros and Cons
=============
Pros:

- Being able to run the spacecraft entirely on your computer enables faster development iteration time.
- Simulation software cannot tell a difference between a connected Teensy and a desktop executable version
  of the flight software, so this enables a greater guarantee that if the flight software is running
  correctly on the desktop, then it will also run fine on a Teensy.

Cons:

- Native execution of Flight Software can only happen on Linux or Mac because PTY connections, which are needed in 
  order to connect to the Flight Software binary, are not supported on Windows. This is not a huge development hurdle,
  given that most of the PAN Flight Software team works on one of these two systems.
- Flight Software runs 2 threads at 100% CPU utilization (see why below), so a minimum of 5 dedicated processor
  hyperthreads are required for running a full mission simulation:

  - One for the Python-MATLAB simulation interface
  - Two for each flight software binary. If running a leader and follower spacecraft, this amounts to 4 total
    threads for flight software.

  Additional processing power is still required for the following tasks, which individually consume low CPU
  bandwidth but require power on the order of ~1 hyperthread:

  - Background MATLAB execution
  - The downlink consumer helper process
  - The uplink producer helper process
  - The user-facing state command prompt
  - Datastores and loggers for simulation data

These requirements can be reduced by running the simulation in single-satellite mode, disabling the MATLAB simulation,
or switching out one of the flight software simulations for a Teensy. However, the above is still doable on
any hyperthreaded quad-core system, like most recent 15" versions of the MacBook Pro.

Implementation Differences
==========================

Clock Management
----------------
Microcontrollers have the benefit of a built-in system clock that ticks once per clock cycle, and thus ticks at a deterministic,
relatively reliable rate. Modern computers change their clock speeds all the time, so ensuring real-time control for processes
on these computers is either difficult or impossible.

On the Teensy, timing is provided via the Arduino functions ``micros``, ``millis``, and ``delay``. We achieve the same
with ``std::chrono`` on desktop compilations of flight software! In order to ensure real-time constraints, rather than
using ``this_thread::sleep`` for pausing the event loop execution, we simply busy-wait until the desired time. This allows
for relatively good control cycle timing, at the expense of requiring the main event loop to run with 100% CPU utilization.
This is not much of an expense at all, unless the system on which the flight software is running happens to be underpowered.

Communicating with Flight Software
----------------------------------
One key difference in how the desktop and Teensy flight software versions differ is how they manage communication
with the simulation server in a testing configuration.

When the simulation computer communicates with Flight Software on a Teensy in a TITL/HITL/VITL configuration, it does
so over a USB connection. In the HOOTL configuration, the USB connection is replaced by ``stdin``/``stdout``,
a PTY session to the running flight software process, and a Python-based serial connection to this PTY session.

This requires adding an additional thread to flight software that continuously manages ``stdin``/``stdout``, to mimic
how the microcontroller has an independent, parallel-executing serial controller that dumps incoming and outgoing
data into buffers. This thread runs at 100% CPU utilization because it is constantly buffering the ``stdin``/``stdout``
in order to meet real-time constraints.

Hardware Management
-------------------
Any I/O communications with flight hardware have been turned into no-ops, so by default hardware always returns 
dummy values as the result of any device interactions. The interactions are mocked just enough so that the flight
software does not go into a fault state because hardware is missing.
