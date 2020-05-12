=================================
Processing and Storing Downlinks
=================================

ElasticSearch
==============
ElasticSearch is a database that allows us to organize information into various indexes or subcategories. In Ground software, every radio has two indexes in which we store telemetry data as JSON objects: 

#. Iridium Reports 

    * Name: Iridium_Report_[IMEI of the radio]

    * Iridium reports house the most recent information about telemetry, such as Mobile Originated Message Numbers (MOMSN), Mobile Terminated Message Numbers (MTMSN), and confirmation MTMSNs. An MOMSN number is the ID of the most recent downlink recieved. An MTMSN number is the ID of the most recent uplink sent from the ground. A confirmation MTMSN is what we call the MTMSN of the last uplink message recieved and processed by the radio. If the most recent confirmation MTMSN and the most recent MTMSN are not equal, then that means that there is a message queued in Iridium that has not yet been recieved by the satellite radio, and we prohibit the ground from sending any more uplinks by setting the `send-uplinks` flag in the Iridium report to False. 

#. Statefield Reports (Statefield_Reports_[IMEI of the radio]). 

    * Name: Iridium_Report_[IMEI of the radio]

    * Statefield Reports house the most recent information pertaining to the actual satellite(s). This information is found in the Short Burst Data (SBD) attachment in downlink emails. 

Every radio has their own Iridium Report index and Statefield Report index to store telemetry information in ElasticSearch. This allows us to distinguish the statefield and telemetry information for each satellite.


Email Processor
================
Telemetry is sent from the satellite to the PAN email account via the Iridium Satellite Constellation Network in compressed serialized packets. These
packets contain special information and data about the satellites that we need to store and index. This is accomplished by a server written with Flask 
which continuously reads unread emails from the Iridium Network, parses the data that comes from the satellite in the form of 
an email attachment, and stores that parsed information in an Elasticsearch database. 

When the email processor is started, it opens a thread `check_email_thread`, which will continuously do the following:

#. Read the most recent unread email received from the Iridium email account.

    * If the most recent unread email is identified as a downlink from a satellite radio, the server `parses <https://pan-software.readthedocs.io/en/latest/ground/Recieving_Downlinks.html#downlink-parser>`_ the information stored in the email attachment containing statefield data and returns a statefield report. A statefield report is a JSON object that holds statefield names, the updated values of each statefield, and the time at which the report was recieved.

    * If the most recent unread email is identified as a confirmation that a radio has received an uplink, the server will record that an uplink confirmation was just received and return None.

    * If there are no unread emails from any satellites, the server returns None.

#. Process the information recieved from the most recent unread email from Iridium

    * If the server has recieved a statefield report, then the thread indexes the statefield report in ElasticSearch. The function will also create and index an Iridium report.

    * If the server does not recieve a statefield report, but we see that the class variable for the uplink confirmation is set to true, then the thread creates and indexes only an Iridium report in ElasticSearch.

    * If the server has not recieved any sort of communication from the satellite, then we do nothing.

#. The thread delays for 10 seconds to reduce CPU bandwidth

Reading Stored Telemetry 
=========================
The email processor also has an endpoint from which we can access data from the ElasticSearch database. This endpoint requires two queries: the IMEI number of 
the radio you want telemetry information from, and the specific statefield that you want to know the most recent value of. The Flask server will then search 
for the statefield report index based on the given IMEI number, and the search within that index for the value of the most recent statefield that was requested.

This endpoint is used for reading statefield information from a satellite when opening a RadioSession to a certain radio. It is also used by RadioSession to confirm whether 
or not the ground is cleared to send more uplinks (i.e if there aren't any messages already queued to be sent to the satellite).