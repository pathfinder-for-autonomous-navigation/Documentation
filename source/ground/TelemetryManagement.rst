=======================
Telemetry Management
=======================

The data coming from the satellite must be serialized and compressed because we are only able to send 70 bytes of information at a time over radio. 
Thus, it is necessary to compress and then parse data from the satellite to ensure we can recieve as much information as possible whenever 
we are able to establish communication.

I recommend reading these two sections to better understand how downlink information is compressed and sent over radio to get a better sense of
how downlink data is parsed:

* `How satellite information is serialized  <https://pan-software.readthedocs.io/en/latest/flight_software/serializer.html>`_.

* `How serialized satellite information is organized and sent over radio <https://pan-software.readthedocs.io/en/latest/flight_software/subsystems/telemetry.html#downlink-producer>`_.

Uplink Producer
================
The uplink producer accepts a JSON file containing the names and desired values of the statefields to be set from the ground. The producer
then serializes all the statefield information to a bitstream and writes the uplink packet to an SBD file. The uplink producer throws an
error if the size of the serialized requested telemetry exceeds the limit of 70 bytes.

Downlink Parser
================
As the thread in the email processor reads unread emails from the Iridium network, the Downlink Parser parses the serialized information and data into a readable
JSON object (ElasticSearch only accepts JSON objects). 

The downlink parser reads files/packets containing the statefield information of a groups of flows with varying priorities and processes them at a bit level. If the first bit of a packet is 1, then that signifies the start of a new downlink frame. 
The downlink producer will continue to read serialized data until it recieves another frame that starts with 1. Once the downlink parser reads the next packet that starts with 1, that means the previous frame is finished and the downlink parser 
returns the most recently collected frame as a JSON object.