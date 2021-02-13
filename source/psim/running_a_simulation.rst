
.. _psim-running-a-simulation:

==============================
Running a Simulation
==============================

This gives an overview of how to run a PSim standalone simulation through via the command line.
If you're looking for details on the Python classes ``psim.SimulationRunner`` or ``psim.Simulation`` please check out `python/psim/simulation.py <https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python/psim/simulation.py>`_.

Prior to running a simulation you must have installed the ``psim`` Python module as described in :ref:`psim-installation-guide-building-and-testing-psim`.


.. _psim-running-a-simulation-command-line-interface:

Command Line Interface
------------------------------

.. note::

   Only the core options provided by the command line interface are presented here.
   For a complete list please run ``python -m psim --help``.

The core usage of the ``psim`` is given by:

.. code-block:: bash

   python -m psim [-p PLOTS] [-ps PLOTS_STEP] [-s STEPS] -c CONFIGS SIM

where:

* ``-p PLOTS``, ``--plots PLOTS`` specifies a comma separated list of plotting configuration files used to determine what data to log and plot over the course of the simulation.

  These plotting files can be found within `config/plots <https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/config/plots>`_ and it's nested subdirectories.
  To refer to a particular plotting file you specify it's relative path from ``config/plots`` dropping the ``.yml`` suffix.

* ``-ps PLOTS_STEP``, ``--plots-step`` instructs the simulation how frequently it should poll data from the simulation for plotting in simulation steps.

  For example, setting this to one provides a plot data point at every step while setting it to ten would only log a data point from plotting every ten steps.

* ``-s STEPS``, ``--steps STEPS`` specifies how many steps the simulation should run for (a value of zero allows the simulation to run forever).

  There are currently no other stopping conditions provided by the command line interface.

* ``-c CONFIGS``, ``--configs CONFIGS`` specifies a comma separated list of configuration files specifying initial conditions.

  These configuration files can be found within `config/parameters <https://github.com/pathfinder-for-autonomous-navigation/psim/tree/master/config/parameters>`_ and it's nested subdirectories.
  To refer to a particular configuration file you specify it's relative path from ``config/parameters`` dropping the ``.txt`` suffix.

* ``SIM`` gives the simulation type to be run.

  The string name of the Python simulation type is passed here and is case sensitive.
  A list of all the available types can be found in `python/psim/sims.py <https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python/psim/sims.py>`_.


.. _psim-running-a-simulation-testing-the-attitude-estimator:

Testing the Attitude Estimator
--------------------------------

As an example, how to run a test of the attitude estimator is given below:

.. code-block:: bash

   python -m psim -s 2000 -p fc/attitude,sensors/gyroscope,truth/attitude -ps 1 -c sensors/base,truth/base,truth/deployment AttitudeEstimatorTestGnc

This runs a simulated test of the attitude estimator starting during deployment.
Once the simulation terminates, you should be left with tons of plots describing the performance of the attitude estimator, the gyroscope, and the truth attitude dynamics.

Feel free to mess around with different simulation types, various initial conditions, and/or other plotting configurations.
Do note, however, that all combinations don't always produce a "valid" simulation.
For example, you can't ask for ``truth/attitude`` plots when running a simulation without attitude dynamics - e.g. ``SingleOrbitGnc``.
