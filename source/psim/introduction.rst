
.. _psim-introduction:

==============================
Introduction
==============================

There are two main deliverables contained within the PSim repository: the ``gnc`` library and the ``psim`` Python module.
Here we'll provide a brief overview of the motivation behind these two products, their respective build systems, and their general layout within the repository.


.. _psim-introduction-gnc-library-overview:

GNC Library Overview
------------------------------

The ``gnc`` Library is an upstream dependency of PAN's `flight software`__ and provides it with implementations of estimators, controllers, and environmental models -- among other things.

With microcontrollers being the eventual target platform, the entire ``gnc`` library is written in C/C++, avoids dynamic memory allocation, and is built using the `PlatformIO`__ build system.
The general layout of the ``gnc`` library within the repository is outlined below:

__ https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware
__ https://platformio.org/

* The header files made public by the library are located under the `include/gnc`__ and `include/orb`__ directories.

* The source files compiled as part of the library and header files that are considered private to the library's implementation are located under the `src/gnc`__ directory.

* Upstream dependencies are pulled in as git submodules and are located within the `lib`__ directory.

* Unit tests for the library are located in `test/gnc`__.

* Build target information is enumerated in `platformio.ini`__ and the file specifying the ``gnc`` library to `PlatformIO`__ is the `library.json`__ file.

__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/include/gnc
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/include/orb
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/src/gnc
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/lib
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/test/gnc
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/platformio.ini
__ https://platformio.org/
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/library.json

For more details on building the ``gnc`` library and running tests please see :ref:`psim-installation-guide-building-and-testing-gnc`.


.. _psim-introduction-psim-overview:

PSim Overview
------------------------------

The ``psim`` Python module is intended to serve two main purposes:

* Support high-fidelity integrated testing both in HOOTL and HITL configurations.
  This means ``psim`` must be capable of simulating orbital and attitude dynamics, realistically respond to the actuator commands issued by flight software, and respond with simulated sensor data that can be fed back into flight software.

* Serve as a simulation environment to verify estimator and controller implementations contained with the ``gnc`` library independant of flight software.
  The main reason to verify ``gnc`` algorithms outside the integrated testing environment described above is speed.
  The above tests only run at real time meaning verifying an orbit estimator, for example, over the course of many orbits in such an environment would be a very inefficient process.

The first use case is supported by the rudimentary interface provided by the ``psim.Simulation`` object.
It allows ``ptest`` to step the simulation as required and easily exchange sensor and actuator data as needed.
The second use case is satisfied by the ``psim`` command line interface described in :ref:`psim-running-a-simulation`.
It allows the user to run a "standalone" simulation running far faster than realtime, manipulate initial conditions, generate plots, et cetera.

Given ``psim`` only needs to be compiled for desktop platforms we have more freedom to use the full set of C/C++ and STL features.
The `Bazel`__ build system is also use making handling a large number of dependencies, large number of build targets, and autogenerated source files far easier to deal with.
The general layout of ``psim`` within the repository is given below:

__ https://bazel.build/

* Additional Skylark to adapt the `Bazel`__ build system for use with ``psim`` is located within the `bazel`__ directory.
  The code here supports the autogenerated `*.yml.hpp` files among other features.

* The public header and YAML model interface files for each ``psim`` library are located within the `include/psim`__ directory.

* The source files compiled are part of each respective library and header files considered to be private to each library's implementation are located under the `src/psim`__ directory.

* Unit tests written using `GoogleTest`__ are locating in `test/psim`__.

* The source code that actually makes the ``psim`` code accessible via Python is defined in `python/psim/_psim.cpp`__.

* C/C++ build targets and dependency information are defined in the `WORKSPACE`__ and `BUILD.bazel`__ files.

* Additional Python code making up the ``psim`` Python module can be found under the `python`__ directory.


__ https://bazel.build/
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/bazel
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/include/psim
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/src/psim
__ https://github.com/google/googletest
__ https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/test/psim
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python/psim/_psim.cpp
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/WORKSPACE
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/BUILD.bazel
__ https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python

For more information on building the ``psim`` Python module and running unit tests please see :ref:`psim-installation-guide-building-and-testing-psim`.
