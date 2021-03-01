
.. _psim-psim-architecture-configuration:

==============================
Configuration
==============================

All initial conditions and :ref:`model <psim-psim-architecture-models>` parameters are sent to a :ref:`simulation <psim-psim-architecture-simulation>` upon initialization via a configuration.
This can include things like each satellite's initial position and velocity but also, for example, specify how noisy a particular sensor reading will be.

At its core, a configuration is simply a mapping from string key names to configuration parameters or values.
These values can take the form of an integer, float, two dimension float vector, three dimensional float vector, or a four dimensional float vector.

As alluded to by :ref:`psim-running-a-simulation`, the most common way to generate a configuration is by specifying a set of text-based configuration files to be parsed.
These files lives under the `config/parameters`__ directory and, like a configuration itself, are a simple mapping of string names to values.

__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/config/parameters

The basic file format is outlined below:

.. code-block:: text

   # Lines starting with a '#' are treated as comments and ignored by the
   # configuration parser.
   #
   # The '#' must be completely left justified and cannot be indented otherwise
   # it will not be treated as a comment.

   # Blank lines like the one above and below are ignored.

   # A parameter can be declared using the following format:
   #
   #   <name> <value>
   # 
   # where the string name must match the following regular expression:
   #
   #   [A-Za-z][A-Za-z_0-9\\.]*
   #
   # and the value can either be a single integer (no '.' in the number), a
   # single float, or multiple floats (up to four) to specify vectors.
   #
   # Example declarations are included below for reference.

   example.integer      0
   example.float        0.0
   example.vector_two   0.0 0.0
   example.vector_three 0.0 0.0 0.0
   example.vector_four  0.0 0.0 0.0 0.0

When working in Python directly, it's possible to override or add any number of configuration parameters prior to initialization a simulation.
One way this can be done is by following the design paradigm below:

.. code-block:: python

   from psim import Configuration, ...

   config = psim.Configuration(...)
   config[...] = ...
   ...

`include/psim/core/configuration.hpp`__, `src/psim/core/configuration.cpp`__, and `python/psim/_psim.cpp`__ contain the C++ and Python wrapper implementation respectively.

__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/include/psim/core/configuration.hpp
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/src/psim/core/configuration.cpp
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python/psim/_psim.cpp
