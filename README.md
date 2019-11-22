# PAN Software Documentation
[![Documentation Status](https://readthedocs.org/projects/pan-software/badge/?version=latest)](https://pan-software.readthedocs.io/en/latest/?badge=latest)

First create a virtual environment and install Sphinx dependencies:
````
python3 -m virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
deactivate
````

To build the docs:
````
. venv/bin/activate
make html
cd build/html
python -m http.server 8080
````

Then visit `http://localhost:8080` in your browser.