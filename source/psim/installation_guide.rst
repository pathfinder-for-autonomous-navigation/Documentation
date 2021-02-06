
.. _psim-installation-guide:

==============================
Installation Guide
==============================

This outlines how to setup your development environment for the ``psim`` repository.
If you're experiencing build issues, try searching through :ref:`psim-installation-guide-common-problems` and seeing if anything seems relevant to you.
Feel free to expand on that section if necessary as well!


.. _psim-installation-guide-dependencies:

Dependencies
------------------------------

All of the following must be installed on your system in order to build the ``gnc`` and/or ``psim`` libraries:

* Python three (Python 3.6 or higher).
* Python three development headers.
* Python three ``distutils`` library.
* Bazel build system.

See this `Bazel installation guide <https://docs.bazel.build/versions/master/install.html>`_ for more details on setting up Bazel.

Python development headers can frequently be installed via your systems package manager.
On a Debian system, as an example, use:

.. code-block:: bash

   sudo apt-get install python3-dev

The Python ``distutils`` package always seems to already be installed.
If unsure, continue with the installation guide and revisit the ``disutils`` package later if needed.


.. _psim-installation-guide-cloning-the-repository:

Cloning the Repository
------------------------------

Be sure the clone the repository recursively to download all submodules as well:

.. code-block:: bash

   git clone --recursive git@github.com:pathfinder-for-autonomous-navigation/psim.git
   cd psim

When pulling in updates or switching between branches with different submodule commits, you must run:

.. code-block:: bash

   git submodule update

to actually reflect changes inside the submodules themselves!


.. _psim-installation-guide-python-virtual-environment:

Python Virtual Environment
------------------------------

.. warning::

   If you do not use your system's default version of Python three, ``psim`` may fail to build or run.

Both ``gnc`` and ``psim`` will share a Python virtual environment development.
From the root of the repository, run the following:

.. code-block:: bash

   python -m venv venv
   source venv/bin/activate
   pip install --upgrade pip wheel

being sure to use you're system wide install of Python three.


.. _psim-installation-guide-building-and-testing-gnc:

Building and Testing GNC
------------------------------

The ``gnc`` library is build and tested using `PlatformIO <https://docs.platformio.org/en/latest/>`_.
From within the :ref:`psim-installation-guide-python-virtual-environment`, execute the following commands to install the required dependencies:

.. code-block:: bash

   pip install -r requirements.txt

and then you are free to build and run the ``gnc`` unit tests natively with:

.. code-block:: bash

   pio test -e native

There are other build targets to run CI, execute code on a Teensy microcontroller, etc.
I recommend checking out the repositories `platformio.ini <https://github.com/pathfinder-for-autonomous-navigation/psim/blob/master/platformio.ini>`_ for more information on the various build targets.

Further testing of the ``gnc`` library is possible from within ``psim`` itself -- more on this later.


.. _psim-installation-guide-building-and-testing-psim:

Building and Testing PSim
------------------------------

The first way to interacting with ``psim`` is by building and running it's suite of C++ unit tests.
This is done by executing the following:

.. code-block:: bash

   bazel test //test/psim:all

A more limited set of unit tests that are executed for CI can also be run with:

.. code-block:: bash

   bazel test //test/psim:ci

The second, and far more useful, way of using ``psim`` software is building the ``psim`` Python module.
Prior to doing so, however, you must install the ``lin`` Python module in your :ref:`psim-installation-guide-python-virtual-environment` with:

.. code-block:: bash

   pip install lib/lin

This should be reinstalled everytime the ``lin`` submodule receives updates -- this isn't too often nowadays.
From there, the ``psim`` module is installed via:

.. code-block:: bash

   pip install -e .

where the ``-e`` flag installs the Python package in "editable mode" and allows Bazel build caching system to greatly reduce build times -- because a new copy of the repository isn't created for each install.

To verify the ``psim`` module is installed and functioning, run:

.. code-block:: bash

   python -m psim --help

and, if interested, continue on to :ref:`psim-running-a-simulation` to run a full simulation with your new Python module.


.. _psim-installation-guide-common-problems:

Common Problems
------------------------------

Bazel Requiring Python Two
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the past, we've seen Bazel trying to determine the version of a system wide Python two installation.
It will error out and complain that a command similar to:

.. code-block:: bash

   python --version

failed to run.
There are two ways we're currently aware of to fix this:

* Alias/install the Python three installation as the default Python on your system.
  Arch linux and other operating systems do this by default and ``psim`` builds without a Python two installation.
* Install Python two on your system even if you aren't going to use it.
  Bazel will be smart and figure out ``python3`` still exists on your system and use that Python version instead.

Bazel Failing to Build PSim After Upgrading Python
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Installing ``psim`` with:

.. code-block:: bash

   pip install -e .

will fail after performing a major version upgrade of Python three on your system -- e.g. upgrading Python 3.8.x to Python 3.9.x.

In the build process, Bazel hunts down the include path to your current Python three development headers.
It then creates a symbolic link to that directory which is passed as an include path to the compiler at build time.
That symbolic link becomes invalid when upgrading through a major version of Python because the include directory name changes.
As such, Bazel will spit out compiler errors saying things like the header ``Python.h`` can't be found.

To fix this you should run the following in the root of the repository:

.. code-block:: bash

   bazel clean --expunge

and then, if you haven't already create a new virtual environment and repeat the install process.
Running ``bazel clean --expunge`` forces Bazel to once again hunt down the Python include path fixing the issue.

PSim Standalone has Issues Generating Plots
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This has been noticed to happen on MacOS a couple times.
Recreating you're :ref:`psim-installation-guide-python-virtual-environment` with the ``--system-site-packages`` flag may help:

.. code-block:: bash

   rm -r venv
   python -m venv venv --system-site-packages
   source venv/bin/activate
   ...
