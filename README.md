# PAN Software Documentation
[![Documentation Status](https://readthedocs.org/projects/pan-software/badge/?version=latest)](https://pan-software.readthedocs.io/en/latest/?badge=latest)

## Reading the Documentation Online
Check out [https://pan-software.readthedocs.io](https://pan-software.readthedocs.io) to read the documentation online from the latest commit on master.
If you've just updated master, it might take some time before the docs show up at that URL, since ReadTheDocs.io has to rebuild the documentation.

## Setting up for local documentation development
First create a virtual environment and install Sphinx dependencies:
````
python3 -m virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
````

## Editing documentation locally
To build the docs and then view them, actuate the virtual environment you created during setup, then run
````
make html
cd build/html
python -m http.server 8080
````

To automatically build the docs every time you make a change to your local files, run instead
````
make livehtml
````

In either case, visit `http://localhost:8080` in your browser to read your local copy of the docs.

Sphinx documentation is written in a markup style called reStructuredText (RST). Here's a good [guide to RST](http://docutils.sourceforge.net/docs/user/rst/quickref.html) that you might want to look at if you want to contribute to this repository.

## Pushing your changes
Once you've written documentation, open a PR. If it passes the Travis CI build, then your PR
will be merged in automatically! There are no reviews required for PRs on this repository, in order
to encourage maximum development of documentation.
