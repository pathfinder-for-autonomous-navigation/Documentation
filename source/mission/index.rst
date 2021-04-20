=============================
Full Mission Simulation
=============================

This section of the documentation will guide you through the startup of PTest/GSW for Full Mission Simualtions

=================================
First Time Setup:
=================================
Make sure you have bazel installed
Make sure you have your venv installed and ready to going
Make sure you have elasticsearch instaled:
This link worked for me on Ubuntu 20.04 (WSL2):
https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-20-04


=================================
Every Time Setup:
=================================

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

=================================
Spooling up the Stack:
=================================

Start ElasticSearch:
If you don't have systemd:

.. code:: bash

   sudo -i service elasticsearch start

On MacOS:

.. code:: bash

   elasticsearch

If you do have systemd, you can set elasticsearch to startup everytime with:
https://www.elastic.co/guide/en/elasticsearch/reference/current/starting-elasticsearch.html

In a seperate terminal: Start TLM:

.. code:: bash

   python -m tlm
   
In a seperate terminal: Start a Case that puts the satellite in the desired simulation level:
Pick one of the following (AND CONFIGURE IMEI NUMBERS!!!):

.. code:: bash

   python -m ptest runsim -c ptest/configs/hootl_autotelem.json -t SingleSatStandbyCase
   
.. code:: bash

   python -m ptest runsim -c ptest/configs/hootl_autotelem.json -t SingleSatStartupCase
 
.. code:: bash

   python -m ptest runsim -c ptest/configs/hootl_hootl_autotelem.json -t DualSatStandbyCase
 
.. code:: bash

   python -m ptest runsim -c ptest/configs/hootl_hootl_autotelem.json -t DualSatStartupCase
 
In a seperate terminal: Start an AutonomousMissionController with:

.. code:: bash

   python -m ptest runsim -c ptest/configs/amc.json -t AutonomousMissionController
   
In a seperate terminal: Start MCT inside FlightSoftware/MCT:
Make sure to specify a ptest/config that uses a specific config:

.. code:: bash

   cd MCT
   npm start ptest/configs/hootl_hootl_autotelem.json

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   Debugging