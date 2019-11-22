# PAN Software Documentation
[![Documentation Status](https://readthedocs.com/projects/pathfinder-for-autonomous-navigation-pan-software-manual/badge/?version=latest&token=996baa95133a37741a847ffa6ec32f55ac1d898192e988063413d56687fbc20e)](https://pathfinder-for-autonomous-navigation-pan-software-manual.readthedocs-hosted.com/en/latest/?badge=latest)

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