This directory contains experimental data collected for intmul benchmark on : 
(1) spike, and 
(2) a linux bootable CVA6 (COREV_APU) running on the Genesys 2 FPGA board

It also contains scripts to plot and compare spike vs FPGA benchmark results. 
Scripts visualize benchmark results in a limited way.

Usage :
1. Install pip environment (one time setup)
cd $REPO_HOME/intmul-250606/rv64; python3 -m venv venv

2. Activate python environment 
cd $REPO_HOME/intmul-250606/rv64; source venv/bin/activate

3. Run one of the available scripts : python <script-name> <RTL configuration name>

Here <script-name> can take one of the following values :
(1) isa_simple.py
(2) ise_simple.py
(3) isa_hybrid.py
(4) ise_hybrid.py

<RTL configuration name> can take one of the following values:
rv64/mpise_00
rv64/mpise_01
rv64/mpise_10
rv64/mpise_11,
where, mpise_<i><j> corresponds to MPISE_DESTRUCTIVE=i and MPISE_STATELESS=j
