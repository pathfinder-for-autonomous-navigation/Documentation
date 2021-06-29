
.. _mission-running-a-hootl-hitl:

==============================
Running a HOOTL HITL
==============================

This outlines how to start a HOOTL-HITL, full-mission testcase with ground software in the loop.
Thanks to the generally abstract interface provided by ``ptest`` this looks very similar to :ref:`mission-running-a-hootl-hootl`.

In general, it's recommended to start all of processes described here in separate terminals for ease of use.


Starting ElasticSearch
------------------------------

Please follower the instructions include with the HOOTL HOOTL simulation instructions for :ref:`mission-running-a-hootl-hootl-starting-elastisearch`.


.. _mission-running-a-hootl-hitl-starting-tlm:

Starting TLM
------------------------------

Because in a HOOTL HITL setup we're going to have one actual Iridium radio, it's neccesary to start the ``tlm`` service.
This can be done with

.. code-block:: bash

   python -m tlm


.. _mission-running-a-hootl-hitl-starting-ptest:

Starting PTest
------------------------------

From the root of the Flight Software repository the desired ``ptest`` case can be started with

.. code-block:: bash

    python -m ptest runsim -c ptest/configs/hootl_hitl_autotelem.json -t DualSat[(Startup)(Detumble)(Standby)(FarField)(NearField)]Case

where the testcase name boots into the desired mission scenario (either startup, detumble, standby, near field operations, or far field operations).
Note that, generally speaking, the autotelem feature is desired for full mission cases so OpenMCT actually gets populated with data.
This is why we're running with a ``*_autotelem.json`` configuration.

Please remember to configure the IMEI number for the HOOTL instance in the ``hootl_hitl_autotelem.json`` file.
Failing to make this number unique to your own machine could cause email collisions between simulations being run by different PAN members.


.. _mission-running-a-hootl-hitl-starting-the-autonomous-mission-controller:

Starting the Autonomous Mission Controller
-------------------------------------------

The autonomous mission controller (AMC) can be starting with

.. code-block:: bash

    python -m ptest runsim -c ptest/configs/amc.json -t AutonomousMissionController

where it's absolutely critical to match the IMEI number within the ``amc.json`` configuration to those used in the testcase.
Note that in the case of HOOTL HITL you'll need to pull the actual IMEI number from the hardware quake itself!


.. _mission-running-a-hootl-hitl-starting-openmct:

Starting OpenMCT
------------------------------

Assuming OpenMCT was already installed, the server can be started with

.. code-block:: bash

    cd MCT
    npm start ../ptest/configs/hootl_hitl_autotelem.json
