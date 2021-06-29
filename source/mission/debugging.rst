
==============================
Debugging
==============================

Intercept a specific value out of elasticsearch:

.. code:: bash

   ???

Start ElasticSearch:

.. code:: bash

   sudo systemctl start elastic ElasticSearch

Look at what is inside elasticsearch:
.. code:: bash

   curl http://localhost:9200/_aliases?pretty=true

Clear ElasticSearch:
.. code:: bash

   curl -X DELETE "localhost:9200/_all?pretty"

If you ever see any problem with PSim first try this!!!!

.. code:: bash

   git submodule update --init --recursive
   pip install -e lib/common/psim

Anything with the whole MCT/PTest Stack:
Are you sure elasticsearch was started?
Are you sure tlm was started?
Are you sure PTest is running?
Are you sure MCT is running?
