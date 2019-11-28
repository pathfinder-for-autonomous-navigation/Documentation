=======================================================
Flight Software Components
=======================================================

Control Tasks
=============
Type name: ``Serializer<bool>``

The core unit of work in PAN flight software is the `control task`. The control task
interface specifies one function, ``execute``, that can have any return type but
accepts no arguments.

How does ``execute`` know what data to act upon? Upon construction, the control task
is responsible for either creating or finding `state fields`. Created state fields correspond
to the outputs of the control task, and found state fields correspond to the inputs.

For example, the ``ClockManager`` control task creates a state field housing the current time,
and updates this value on every execution of the control cycle. A control task "finds" a state
field by querying the State Field Registry; see more about state fields and the state field
registry below.

State Fields
=============
A state field is nothing more than a wrapper around a simple type, along with a ``get``
and ``set`` function. All data representing important values on the spacecraft 
are stored in state fields, which are centrally indexed by the state field registry
(see below). The indexing is by string; all state fields have a unique name, accessible
by the function ``name``.

There are three kinds of state fields on the spacecraft:

- **Readable** state fields are fields whose values can be read from the ground but
  whose values cannot be modified from the ground.
- **Writable** state fields are fields whose values can both be read from and modified
  from the ground.
- **Internal** state fields are implementation details. This kind of state field exists
  so that control tasks can share data across each other without breaking
  the encapsulated design of a control task. We care about encapsulation because it
  enables unit testability.

Internal state fields can have any underlying data type, but since readable and writable
state fields need to be passable over the limited-bandwidth radio that we have onboard the
spacecraft, their types are restricted to the following list:

- ``bool``, ``unsigned int``, ``unsigned char``, ``signed int``, ``signed char``, ``float``, ``double``
- ``gps_time_t``: A GPS time class, which has the sub-members ``wn`` (week number), ``tow`` (time of week
  in milliseconds, and ``ns``, which is an offset of +/- 1000000 nanoseconds off of the time of week.
- ``f_vector_t``, ``d_vector_t``: Vectors, which are nothing more than a renaming of ``std::array<float, 3>``
  or ``std::array<double, 3>``.
- ``f_quat_t``, ``d_quat_t``: Quaternions, which are nothing more than a renaming of ``std::array<float, 4>``
  or ``std::array<double, 4>``.

In order to encode and decode state fields from a string representation so that they can
be transmitted over the radio, readable and writable state fields contain a ``Serializer`` object.
The control tasks that manage telemetry use the functions contained within the serializer
to manage the value of a readable/writable state field. Check out more info about :doc:`serializer`.

The State Field Registry
========================
The state field registry contains lists of pointers to readable, writable, and internal state fields,
along with functions to find and add state fields' pointers to the registry.

The purpose of the registry is to enable encapsulation. Upon construction, control tasks receive a reference
to a State Field Registry object that is shared across all control tasks. The control tasks can then
publish their outputs to other control tasks by adding state fields to the registry, and can find their
inputs (which would've been published by other control tasks) from the registry. This makes unit testing each
control task extremely simple.

Flight Software Cycle
=====================
In order to maintain determinism and reduce complexity in the behavior of Flight Software, the main event loop
of the Flight Software, which we call the `flight software cycle`, is single-threaded and deterministically runs
Control Tasks, one after the other. The general structure of this loop is read-compute-actuate, as in most robot
control loops, and consists of the following items:

TODO fill out entire table

+--------------------------+-----------+-------------------------------------------------------------+
| Item Name in Software    | Offset    | Description                                                 |
|                          | Time (ms) |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``ClockManager``         | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``EEPROMController``     | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``PiksiMonitor``         | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``OrbitEstimator``       | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``ADCSBoxMonitor``       | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``AttitudeEstimator``    | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``DockingMonitor``       | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``PropulsionMonitor``    | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``PowerMonitor``         | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``UplinkConsumer``       | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``MissionFaultMonitor``  | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``MissionController``    | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``PowerController``      | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``GNCNavigation``        | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``PropulsionController`` | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``AttitudeComputer``     | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``ADCSBoxController``    | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``DockingController``    | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``DownlinkProducer``     | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+
| ``QuakeManager``         | 0         |                                                             |
+--------------------------+-----------+-------------------------------------------------------------+

In order to maintain deterministic separation between consecutive executions of one control task, there's
an "offset" field, which describes the time at which the control task is expected to start, relative
to the start of the control cycle. 

This offset is enforced using a busy-wait before each control task that waits for the current time to 
be greater than the offset. If, for some reason, a control task's execution runs into the offset of the
next control task, the next control task will begin immediately. This is never expected to occur, though,
since we test the control cycle timing thoroughly.


Software Cycle in Flight Code vs HOOTL/HITL Code
------------------------------------------------
This is the flight version of the software cycle. In the HOOTL/HITL (hardware-out-of-the-loop/hardware-in-the-loop)
versions of the cycle, there is an additional ``DebugTask`` that runs after the ClockManager. Its purpose is to
exchange state field data with the simulation. The ``DebugTask`` is required to last at most 50 milliseconds.
