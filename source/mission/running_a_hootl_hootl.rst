
.. _mission-running-a-hootl-hootl:

==============================
Running a HOOTL HOOTL
==============================

This outlines how to start a HOOTL-HOOTL, full-mission testcase with ground software in the loop.
Thanks to the generally abstract interface provided by ``ptest`` this looks very similar to :ref:`mission-running-a-hootl-hitl`.

In general, it's recommended to start all of processes described here in separate terminals for ease of use.


.. _mission-running-a-hootl-hootl-starting-elastisearch:

Starting ElasticSearch
------------------------------

First on the list here is to start ElasticSearch on your machine.
On Linux systems with ``systemd`` this is generally done with

.. code-block:: bash

   sudo systemctl start elasticsearch.service

and stopped with

.. code-block:: bash

   sudo systemctl stop elasticsearch.service

I'd recommend checking out `this`__ Arch Wiki page for information on basic ``systemd`` usage for more commonly used commands.

__ https://wiki.archlinux.org/index.php/systemd#Basic_systemctl_usage

For those running on Mac, EsticSearch can be started with

.. code-block:: bash

   elasticsearch

In either case, once ElasticSearch is booted it's recommended to clear the database with

.. code-block:: bash

   curl -XDELETE localhost:9200/*

to prevent old data from interfering with the simulation.

If the above directions don't help with starting ElasticSearch, it may be worth checking out their guide `here`__ as well.

__ https://www.elastic.co/guide/en/elasticsearch/reference/current/starting-elasticsearch.html


.. _mission-running-a-hootl-hootl-starting-ptest:

Starting PTest
------------------------------

From the root of the Flight Software repository the desired ``ptest`` case can be started with

.. code-block:: bash

   python -m ptest runsim -c ptest/configs/hootl_hootl_autotelem.json -t DualSat[(Startup)(Detumble)(Standby)(FarField)(NearField)]Case

where the testcase name boots into the desired mission scenario (either startup, detumble, standby, near field operations, or far field operations).
Note that, generally speaking, the autotelem feature is desired for full mission cases so OpenMCT actually gets populated with data.
This is why we're running with a ``*_autotelem.json`` configuration.

Please remember to configure the IMEI numbers in the ``hootl_hootl+autotelem.json`` file.
Failing to make these numbers unique to your own machine could cause email collisions between simulations being run by different PAN members.


.. _mission-running-a-hootl-hootl-starting-the-autonomous-mission-controller:

Starting the Autonomous Mission Controller
-------------------------------------------

The autonomous mission controller (AMC) can be starting with

.. code-block:: bash

   python -m ptest runsim -c ptest/configs/amc.json -t AutonomousMissionController

where it's absolutely critical to match the IMEI number within the ``amc.json`` configuration to those used in the testcase.


.. _mission-running-a-hootl-hootl-starting-openmct:

Starting OpenMCT
------------------------------

Assuming OpenMCT was already installed, the server can be started with

.. code-block:: bash

   cd MCT
   npm start ../ptest/configs/hootl_hoolt_autotelem.json
