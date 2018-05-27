#!/bin/sh
set -e
gcc -c vzmqc.c 
ghdl -a vzmq_pkg.vhd vzmq.vhd vzmq_tb.vhd 
ghdl -e -Wl,vzmqc.o -Wl,-lzmq vzmq_tb
xterm -e "sleep 1; python zmqtest.py" &
./vzmq_tb --wave=test.ghw

