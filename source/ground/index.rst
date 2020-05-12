=============================
Ground Software Documentation
=============================

This section of doumentation will contain information about ground software. Ground software has two purposes: 

1) Store and index telemetry coming from the satellites 

2) Send commands to the satellite via the Iridium Satellite Constellation Network.

3) Send commands to the Flight Computer to test telemetry without hardware in the loop.

The code for the telemetry parsers and MCT is available `here <https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware/tree/master/src/gsw>`_.

The code for the downlink processing server and telemetry software is available `here. <https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware/tree/http_endpoints/tlm>`_

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   Radio_Session
   State_Session
   Processing_Downlinks
   TelemetryManagement
