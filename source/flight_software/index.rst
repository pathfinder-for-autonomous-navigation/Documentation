=============================
Flight Software Documentation
=============================

The code for flight software is available `here<https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware>`_.

I recommend reading :doc:`components` as an absolute first, then there are two paths you
can take through this documentation:

- A `systems-level` understanding: read through :doc:`mission_manager`, and then the entries
  in :doc:`subsystems/index` in any order.
- A `implementation` understanding: read through :doc:`serializer`, and then the entries
  in :doc:`subsystems/index` in any order, then :doc:`mission_manager`.

The former path is useful for people new to PAN or trying to learn about PAN; the latter path
is important for flight software developers.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   components
   serializer
   mission_manager
   subsystems/index
