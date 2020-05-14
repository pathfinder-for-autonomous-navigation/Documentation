=================================
Guidance, Navigation, and Control
=================================

Attitude Determination
======================
TODO

Attitude Control
================
TODO

Orbit Estimator
==========================

Author: Nathan Zimmerberg (nhz2@cornell.edu)
Started: 13 May 2020
Last Updated 14 May 2020

Main Goal
------------
The goal of the orbit estimator is to 
estimate the position and velocity of self and the target satellites given sensor inputs 
and messages sent from ground.

Input
---------

GPS:
    Each satellite has a Piksi GPS receiver (see :doc:`gps`).

Ground Messages:
    Ground software will uplink the target's estimated orbit whenever possible.

    Ground software can also modify the orbit estimator, including resetting, 
    changing the propagation and sensor models, and manually setting the orbit.

Propulsion:
    The last thruster firing.

Attitude Determination and Control:
    The estimated attitude, combined with the last thruster firing to get the change in velocity in ECEF.


Output
--------

Expected self and target Orbit, statistics, and debug information.

Software Components
-------------------

The following components need to be finished and tested before 
getting combined into the main orbit estimator.

Check Orbit Validity: Done
    Check Orbits are in low earth orbit, this is useful for catching filter instabilities.

    A valid orbit has finite and real position and velocity, is in low earth orbit, and has a reasonable time stamp within MAXGPSTIME_NS, MINGPSTIME_NS.

    Low earth orbit is a Orbit that stays between MINORBITRADIUS and MAXORBITRADIUS.

Short Orbit Propagation with Jacobian Output: Done
    The EKFs need to propagate the state and covariance in between GPS readings using this.

Orbit GroundPropagator: Done
    Class to propagate orbits sent from ground.

    The GroundPropagator tries to:

    1. minimize the number of grav calls needed to get an up to date orbit estimate.
    2. use the most recently input Orbit.

    Implimentation details:

        Under normal conditions, this estimator just propagates the most recently uplinked Orbit. in current.

        If a new Orbit get uplinked it will normally get put in catching_up, and the estimator will propagate it to the current time in the background while still propagating current as the best estimate. Once catching_up is done propagating it replaces current.

        If another Orbit gets uplinked while catching_up is still being propagated in the background, it gets stored in to_catch_up. This ensures too many Orbits getting uplinked won't overload the estimator and prevent it from making progress. If to_catch_up takes fewer grav calls to finish propagating than catching_up it replaces catching_up. Also to_catch_up replaces catching_up if catching_up finishes propagating.

        Propagator details:
            High order integrators Yoshida coefficients from: https://doi.org/10.1016/0375-9601(90)90092-3
            The higher order propagator step right now works like this, first it converts position and velocity in ecef to relative inertial coordinates to a close reference circular orbit. Then it does a series of drift-kick-drift steps (see https://en.wikipedia.org/wiki/Leapfrog_integration ) where a drift is rel_r= rel_r+rel_v*dt*0.5; and a kick is rel_v= rel_v + g_ecef0*dt; For the low order step(2nd ish) there is just one drift-kick-drift, for the higher order step(6th ish) Yoshida coefficients are used to do 7 drift-kick-drifts with a series of d*dt: Where somehow this magical series of time steps cause some errors to cancel out. Finally when the step(s) are done the relative position and velocity are converted back to ecef.

Single Orbit Extended Kalman Filter: WIP
    Use an extended Kalman filter to estimate the self orbit from GPS data.

    This is currently implemented only in MATLAB, 
    but the current implementation is too computationally expensive and numerically unstable
    to be directly used in flight software. I am working on a square root Kalman filter, 
    and more carefully managing the computational load for the C++ version.

Double Orbit Extended Kalman Filter: WIP
    Use an extended Kalman filter to estimate the self and target orbit from CDGPS and GPS data.

    This is currently implemented only in MATLAB, 
    but the current implementation is too computationally expensive and numerically unstable
    to be directly used in flight software. I am working on a square root Kalman filter, 
    and more carefully managing the computational load for the C++ version.


Testing
-------

Unit Tests:
    Unit tests are run in CI, and the teensy.

    Unit tests check that the orbit propagation is accurate, 
    and the Kalman filter math is right.

Estimator Performance Tests:

    To test the orbit estimator performance I am using data from GRACE-FO_ and from PSIM. 

    .. _GRACE-FO: https://podaac.jpl.nasa.gov/GRACE-FO

    The workflow is to generate a file of sensor data and truth on every control cycle from a 
    full PSIM sim. Then open that file in a Jupyter Notebook and plot the performance of the estimator under test.

    For example see https://github.com/pathfinder-for-autonomous-navigation/psim/blob/Jupyter-Notebook-Plotting-Utility/estimatortest/Orbit-estimator-test.ipynb

    The C++ components can be easily wrapped in python using pybind11 and cppimport so tweaks to the C++ code can be quickly tested.

    This is much faster than running a full PSIM sim and doesn't require access to MATLAB.

    Also Jupyter Notebook can be run over SSH so if someone has an old laptop, can't get the code to compile, or doesn't have MATLAB,
    they can still visually test the estimator on a Linux server.


Orbital Control Algorithm
=========================
TODO
