
.. _psim-running-a-simulation:

==============================
Running a Simulation
==============================

This gives an overview of how to run a PSim standalone simulation through via the command line.
If you're looking for details on the Python classes ``psim.SimulationRunner`` or ``psim.Simulation`` please check out `python/psim/simulation.py <https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/python/psim/simulation.py>`_.


.. _psim-running-a-simulation-testing-the-attitude-estimator:

Testing the Attitude Estimator
---------------------------------

Assuming the ``psim`` Python module is already installed, a simulation testing the attitude estimator can be run with:

.. code-block:: bash

   python -m psim -s 2000 -p fc/attitude,sensors/gyroscope,truth/attitude -ps 1 -c sensors/base,truth/base,truth/deployment AttitudeEstimatorTestGnc

which is an absolute monster of a command at first glance.
