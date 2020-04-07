===================
PTest Documentation
===================

PTest is an extremely robust testing architecture that tests our flight software
in conjunction with our mission simulation in both a Hardware-out-of-the-Loop (HOOTL)
and Hardware-in-the-Loop (HITL) configuration. The HITL tests can be further broken
down into

 - Teensy-in-the-Loop (TITL) tests, which are like HOOTL tests but with flight
   software running on an actual Teensy 3.6, like it would on the satellite, rather
   than as a binary executable on a computer. 
 - Vehicle-in-the-Loop (VITL) tests, which run the flight software on the
   satellite's entire electronics stack. Optionally, VITL tests can incorporate
   other satellite elements like the propulsion system, the ADCS box, or the radio.

Flight software must be proven on HOOTL and TITL levels before running at a VITL level.
This testing architecture allows us to have iterated stages of proving the flight
readiness of software whilst minimizing risk to expensive hardware during testing.

See below for design documentation for ptest. To install and run ptest, consult the README
in ``FlightSoftware/ptest/README.md``.

.. toctree::
   :maxdepth: 2
   :caption: Contents:
   
   testing_architecture
   writing_ptest_cases
