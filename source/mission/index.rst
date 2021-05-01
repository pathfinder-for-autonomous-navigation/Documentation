
.. _mission:

======================================
Full Mission Simulation Documentation
======================================

In a seperate terminal: Start TLM:

.. code:: bash

   python -m tlm

In a seperate terminal: Start an AutonomousMissionController with:

.. code:: bash

   python -m ptest runsim -c ptest/configs/amc.json -t AutonomousMissionController

In a seperate terminal: Start MCT with:
Make sure to specify a ptest/config that uses a specific config:

.. code::bash

   cd MCT
   npm start ptest/configs/ask_duncan_to_update_this.json

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation_guide
   running_a_hootl_hootl
   running_a_hootl_hitl
   common_problems
   debugging
   faq
