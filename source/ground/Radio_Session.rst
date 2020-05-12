==============
Radio Session
==============
The RadioSession class represents a connection session with a Flight Computer's Quake radio. 
RadioSession is used by the simulation software and the user command prompt to read and 
write to a flight computer's Quake radio. Upon startup, a radio session will create HTTP 
endpoints which can be used to send telemetry to a radio. This section elaborates on these endpoints,
how autonomous uplinks are scheduled, and the two main methods in radio session: read_state and write_state.

Uplink Timer
------------
The two satellites communicate their respective GPS positions and other state information via the ground
station and Iridium. After recieving state information from one satellite, the ground autonomously sends
an uplink with the relevant information to the other satellite. While communication between the satellites 
and the ground station is established, we can expect information packets to be recieved and sent by the 
ground every few minutes.

After autonomously creating a packet to be sent to a satellite, the radio session queues the packet and 
starts an ``Uplink Timer``. The radio session waits until the timer is up before sending the uplink to 
the other satellite. The amount of time that the radio session waits before sending the uplink can be 
configured in the radio session config file. In the config file, the ``send_queue_duration`` specifies 
the total amount of time that radio session waits before sending the uplink and the ``send_lockout_duration`` 
specifies the amount of time during which the mission commander can no longer make edits to the queued uplink. 
For example, if the ``send_queue_duration`` is 10 minutes and the ``send_lockout_duration`` is 2 minutes, 
then the mission commander can make edits to the queued uplink for only the first 8 minutes. After 10 
minutes, the uplink will be sent to the satellite via Iridium.

The ``Uplink Timer`` can be paused and resumed to allow more time for the mission commander to edit 
a queued uplink. This can be done by sending a request to a designated HTTP endpoint.

HTTP Endpoints
---------------
Upon creation, the radio session will set up four HTTP endpoints that allow the mission commander
to send uplinks to the satellite. The mission commander can access these endpoints and send telemetry
using NASA's OpenMCT interface.

**1) Time**

This endpoint returns the amount of time left on the uplink timer is an autonomous uplink is queued.

**2) Pause**

This endpoint allows the mission commander to pause the uplink timer so that he or she can make edits
to a queued uplink.

**3) Resume**

This endpoint allows the mission commander to resume the uplink timer once he or she is done making edits
to a queued uplink.

**4) Request Telemetry**

This endpoint allows a mission commander to send telemetry to a satellite by posting requested telemetry 
as a JSON object over HTTP. If an autonomous uplink is queued to be sent, then the requested telemetry will
be added to the queued uplink packet. We are constrained to send 70 bytes of information per uplink packet. Therefore,
editing queued autonomous uplinks allows us to send as much information per uplink packet as possible.

On the other hand, if there is no autonomous uplink queued, then the uplink packet will
immediately be sent to the satellite (i.e there will be no use of an ``UplinkTimer`` or a queue duration).

Read State
-----------

`read_state()` allows us to read the most recent value of a statefield of a satellite. To do this, 
RadioSession establishes a connection to the `Email Processor 
<https://pan-software.readthedocs.io/en/latest/ground/Recieving_Downlinks.html#email-processor>`_ 
responsible for indexing statefield information from both satellite radios. RadioSession then sends a 
GET request to the email processor over HTTP with the name of the ElasticSearch index 
(statefield_report_[imei of RadioSession's connected radio]) and the name of the desired statefield as queries. 

Write State
-----------

`write_state()` allows us to set the value of a statefield for a specific satellite from the ground. 
First, RadioSession confirms whether or not there are any uplinks currently queued to be sent to the 
connected radio. RadioSession does this by sending a GET request to the ElasticSearch database over 
HTTP with the name of the ElasticSearch index (iridium_report_[imei of RadioSession's connected radio]) 
and the name of the `send-uplinks` flag as queries. 
    
If RadioSession is cleared to send uplinks, then RadioSession 1) waits a designated send queue duration and then
2) sends an uplink to the satellite via Iridium. The subject of the uplink is the IMEI number of the radio 
of the satellite that will set the statefields. The uplink message will also contain an attached SBD file that holds 
the serialized names and the desired values of the statefields we wish to set from the ground. While the uplink is queued, the 
mission commander can edit the contents of this uplink packet over HTTP.
    
Once the radio recieves the uplink, the `Uplink Consumer 
<https://pan-software.readthedocs.io/en/latest/flight_software/subsystems/telemetry.html#uplink-consumer>`_ 
in Flight Software will then deserialize and read the SBD file and set the statefield values accordingly.

Email Access
------------
All uplinks are sent to the satellites via the Iridium Satellite Network. To accomplish this, radio session 
sends an email from the designated PAN email account to Iridium's email address. The subject of the email is the IMEI
number of the satellite's radio, and attached to the email is a file holding a serialized uplink packet.

In order to access PAN's email account from a remote server and send messages, the radio session obtains token credentials
using Google's Gmail API. We are constrained to a token grant rate limit a 10,000 grants per day, or approximately 
10 token grants a minute. However, since the radio session waits an established send queue duration before sending
an uplink, this limit poses no foreseeable issue.