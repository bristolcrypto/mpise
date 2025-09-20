### Setup and usage :

#### Initial setup (one time):
Create a python environment and install the required packages. For reference, use the following commands:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### Regular usage:
Assuming that you have a python environment setup in this directory, use the following commands to analyze different logfiles:
```
source venv/bin/activate # Use once to activate the python environment
python process.py <name of logfile>
```
For example:
```
python process.py ../x25519-250918/cva6_x25519_rv64_isa_reduced.log
```


