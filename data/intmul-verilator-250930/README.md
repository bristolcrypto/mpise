## Purpose

You can use the contents of this folder to analyze runtime data captured for intmul benchmark on cva6-verilator simulation setup.

The folder data/intmul-verilator-<date> contains :
1. The original data captured while executing intmul benchmark on the CVA6 verilator simulation setup on said <date> 
2. The scripts to parse, process and analyze the data. The data is prepared for further downstream processing (e.g. to generate plots using src/sw/intmul/scan.sh).

## Usage :
1. Setup python environment 
```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
2. Analyze a single logfile :
```
python single.py <path-to-logfile.log>
```
This will produce analytics and graphs corresponding to a particular logfile.

3. Batch processing (all logfiles):
Process the raw logfiles for downstream scripts (e.g. plotting in src/sw/intmul/scan.sh)
```
bash process-all.sh
```
This step will process the folders in "original-logs", and create "generated-logs" folder. The processed files are noise-cleaned, formatted for further downstream processing. For example:

4. Plot with scan.sh :
The process-all.sh script can also be invoked internally by src/sw/intmul/scan.sh for plotting purposes :
```
MPISE_DESTRUCTIVE="x" MPISE_STATELESS="y" ARCH="rv32" DATA="intmul-verilator-250930" bash scan.sh clean
MPISE_DESTRUCTIVE="x" MPISE_STATELESS="y" ARCH="rv32" DATA="intmul-verilator-250930" bash scan.sh plot
```
where (x,y) each can take values 0 or 1.
