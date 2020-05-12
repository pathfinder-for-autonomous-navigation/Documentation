==============
State Session
==============
A state session represents a connection session with a Flight Computer's state system. It is used 
by the simulation software and user command prompt to read and write to a flight computer's state. State sessions can be
used for testing telemetry without hardware in the loop.

Upon startup, a state session will create two HTTP endpoints which can be used to send telemetry 
to the flight computer. This section elaborates on these endpoints and how to send telemetry packets.

Sending Telemetry
------------------
We can request to send telemetry to the flight computer by running ``uplink [field1] [val1] [field2] [val2] ...``
in the user command prompt. The state session will then collect the requested telemetry as a JSON object and
serialize this information using the Uplink Producer.

A state session can then send the serialized uplink packet to the flight computer by sending a JSON command with the uplink packet to 
the flight computer's debug console. The debug console will parse the uplink packet and move the packet into the `Quake Manager's
<https://pan-software.readthedocs.io/en/latest/flight_software/subsystems/quake.html>`_
radio MT buffer. The Quake Manager would then deserialize and read the uplink packet on the next control cycle.

HTTP Endpoints
--------------
Upon creation, the state session will create a single http endpoint that allows the commander to request to send telemetry
to the flight computer. 