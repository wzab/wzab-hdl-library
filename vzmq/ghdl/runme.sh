#!/bin/sh
set -e
gcc -c vzmqc.c 
ghdl -a vzmq_pkg.vhd vzmq.vhd vzmq_tb.vhd 
ghdl -e -Wl,vzmqc.o -Wl,-lzmq vzmq_tb
xterm -hold -e "sleep 1; python3 zmqtest.py" &
./vzmq_tb --wave=test.ghw

