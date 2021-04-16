=============================
Full Mission Simulation
=============================

This section of the documentation will guide you through the startup of PTest/GSW for Full Mission Simualtions

First Time Setup:
Make sure you have bazel installed
Make sure you have your venv installed and ready to going
Make sure you have elasticsearch instaled

Do this every time setup:

.. code:: bash

   python -m ptest runsim -c ptest/configs/hitl_singlesat.json -t CheckBatteryLevel -ni

From the FSW repo:
Make sure your submodules are up to date:

.. code:: bash

   git submodule update --init --recursive

Make sure that PSim (within FSW):

.. code:: bash

   pio run -e lib/common/psim

Make sure that the builds of fsw that you're going to be using are built:
For example:

.. code:: bash

   pio run -e fsw_native_leader
   pio run -e fsw_native_follower
   pio run -e fsw_native_leader_autotelem

Start ElasticSearch:

.. code:: bash

   idk lmao

In a seperate terminal: Start TLM:

.. code:: bash

   python -m tlm
   
In a seperate terminal: Start a DualPsim Case with autotelem:

.. code:: bash

   python -m ptest runsim -c ptest/configs/hootl_hootl_autotelem.json -t DualPsim
   
In a seperate terminal: Start an AutonomousMissionController with:

.. code:: bash

   python -m ptest runsim -c ptest/configs/??? -t AutonomousMissionController
   
In a seperate terminal: Start MCT with:
Make sure to specify a ptest/config that uses a specific config:

.. code::bash

   cd MCT
   npm start ptest/configs/ask_duncan_to_update_this.json

.. toctree::
  :maxdepth: 2
  :caption: Contents:

  FAQ
