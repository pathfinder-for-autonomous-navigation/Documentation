============
GPS Receiver
============
The PAN mission utilizes the Piksi, which is a Carrier Differential GPS (CDGPS).
Two Piksi units detect the phase difference between their GPS signals, and use that phase difference
to estimate a relative difference in position, called the baseline vector. This position difference
vector is accurate to 1cm which enables docking through cdGPS navigation alone for PAN.

Time Propagation
----------------
TODO

Piksi Control Task
------------------

The Piksi Control Task or PiksiControlTask requires that the serial buffer that is connected to the
flight computer have a receiving buffer capacity of 1024 bytes. This is because within a 120 ms
control cycle, there can potentially be two piksi packets. Each packet nominally contains about
299 bytes. 512 is not sufficient, but the next power of two, 1024 is sufficient to contain 299 * 2.

Data
----

Piksi Velocity readings are in ECEF coordinates and in millimeters persecond

Piksi Position readings are in ECEF coordinates and in meters

Piksi Baseline readings are in ECEF coordinates and in millimeters