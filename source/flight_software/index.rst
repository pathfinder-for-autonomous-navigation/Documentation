=========================================
Flight Software and Systems Documentation
=========================================

This section of the documentation contains documentation on both the flight software and the
PAN satellite's subsystems. The two ideas go hand-in-hand, which is why their documentation is
woven together.

The code for flight software is available `here <https://github.com/pathfinder-for-autonomous-navigation/FlightSoftware/>`_.

I recommend reading :doc:`components` as an absolute first, then there are two paths you
can take through this documentation:

- A `systems-level` understanding: read through :doc:`mission_manager`, and then the entries
  in :doc:`subsystems/index` in any order.
- A `implementation` understanding: read through :doc:`serializer`, and then the entries
  in :doc:`subsystems/index` in any order, then :doc:`mission_manager`, then :doc:`desktop_operation`.

The former path is useful for people new to PAN or trying to learn about PAN; the latter path
is important for flight software developers.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   components
   desktop_operation
   serializer
   mission_manager
   subsystems/index
