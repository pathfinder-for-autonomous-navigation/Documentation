=================================
Debugging
=================================

Intercept a specific value out of elasticsearch:

Start ElasticSearch:

.. code:: bash

   idk lmao

Look at what is inside elasticsearch:
.. code:: bash

   curl http://localhost:9200/_aliases?pretty=true

If you ever see any problem with PSim first try this!!!!

.. code:: bash

   git submodule update --init --recursive
   pip install -e lib/common/psim

Anything with the whole MCT/PTest Stack:
Are you sure elasticsearch was started?
Are you sure tlm was started?
Are you sure PTest is running?
Are you sure MCT is running?