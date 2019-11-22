Flight Software Components
=======================================================

Control Tasks
------------------------
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
------------------------
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
------------------------


Control Task Timing
------------------------


Flight Software Cycle
------------------------

