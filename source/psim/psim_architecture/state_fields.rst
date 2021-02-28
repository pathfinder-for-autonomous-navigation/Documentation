
.. _psim-psim-architecture-state-fields:

==============================
State Fields
==============================

All data sharing between :ref:`models <psim-psim-architecture-models>` within a :ref:`simulation <psim-psim-architecture-simulations>` as well as transactions to and from Python happen via state field reads and writes.
Here, the two main types of supported state fields will be described along with their intended use cases.


.. _psim-psim-architecture-state-fields-lazy-state-field:

Lazy State Field
------------------------------

Lazy state fields, as suggested by their name, are lazily evaluated when accessed given the current state of the simulation - i.e. the value of other state fields.
The result of a lazy evaluation is cached for the remainder of the simulation step to allow for low-overhead duplicate accesses and reset when the simulation is stepped forward again.

The main motivation for supporting lazily evaluated fields is two fold:

* Improved performance.
  The end user shouldn't pay for the computation of fields that aren't strictly required by their use case.
  Most lazy fields implement convenience coordinate transformations, calculate sensor error calculations, estimator performance metrics, et cetera that aren't required by most use cases.

* Convenience. While not paying to computational overhead that you don't need is nice, having the ability to at anytime query the value of some lazily evaluated field for debugging purposes is invaluable.
  Furthermore, it reduces potential code duplication for particular use cases if the simulation can already provide a large swath of information via lazy evaluation.

The implementation of a lazy state fields can be found in `include/psim/core/state_field_lazy.hpp`__.
Please refer the documentation describing :ref:`models <psim-psim-architecture-models>` for more information on how lazy state fields are implemented and used with a simulation.

__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/include/psim/core/state_field_lazy.hpp


.. _psim-psim-architecture-state-fields-valued-state-field:

Valued State Field
------------------------------

A valued state field is, again as the name suggests, backed directly by a value in memory.
There is no lazy evaluation and a valued field can be written too if marked as writable by the owning model.

Generally speaking, a valued state field is used to store fields integral to the current state of the spacecraft.
Something like each satellite's position and velocity can't really be lazy evaluated; on each simulation step the dynamics model must propagate the position and velocity forward in time.
Valued fields can also be used if the data is calculated on each step anyway even if it's not "integral" to the state of the simulation.
An example of this would be the gyroscope bias estimate determined by the attitude filter.

`include/psim/core/state_field_valued.hpp`__ contains the implementation of valued state fields.
Again, please refer the documentation describing :ref:`models <psim-psim-architecture-models>` for more information on how valued state fields are implemented and used with a simulation.

__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/include/psim/core/state_field_valued.hpp
