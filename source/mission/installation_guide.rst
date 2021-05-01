
.. _mission-installation-guide:

==============================
Installation Guide
==============================

This outlines how to setup your development environment to run full mission simulations.
If you encounter any issues during installation, please first refer to the :ref:`mission-common-problems` page.
Feel free to add an additional section to the :ref:`mission-common-problems` page if you encounter a new issue.


.. _mission-installation-guide-dependencies:

Dependencies
------------------------------

In order to run full mission simulations, the dependencies for flight software, simulation software, and the ground software stack must be installed.
Flight and simulation software dependencies are covered in detail in the PSim :ref:`psim-installation-guide-dependencies` guide -- flight software's dependencies are a subset of PSim's.

In addition to the above dependencies, we also need to install ElasticSearch and the NodeJS package manager NPM for OpenMCT support.
Installation for these packages is system specific but generally can be installed via your OS' package manager.

If you're running on WSL `this`__ may be helpful for ElasticSearch.

__ https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-20-04


.. _mission-installation-guide-installing-flight-software:

Installing Flight Software
------------------------------

Installing the flight software repository is the only code-base required for full mission simulations.
Simply clone the repository recursively

.. code-block:: bash

   git clone --recursive git@github.com:pathfinder-for-autonomous-navigation/FlightSoftware.git
   cd FlightSoftware

and setup a virtual environment:

.. code-block:: bash

   python -m venv venv
   source venv/bin/activate
   pip install --upgrade pip wheel
   pip install -r requirements.txt
   pip install -e lib/common/psim

being sure to use your system's default version of Python 3 to create the virtual environment as required by PSim in :ref:`psim-installation-guide-python-virtual-environment`.
Assuming all has gone well so far, both the ``psim`` and ``ptest`` Python modules have been successfully installed.
For help with ``psim`` specific install instructions, please see PSim's :ref:`psim-installation-guide-common-problems` section.


.. _mission-installation-guide-installing-ground-software:

Installing Ground Software
------------------------------

For detailed instructions please reference the `MCT README`__.

__ https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware/tree/master/MCT
