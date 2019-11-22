. venv/bin/activate
make html
cd build/html
python -m http.server 8080
