#!/bin/bash
set -e 
./rec_to_pkg_nest.py test.rec 
ghdl -a test_pkg.vhd test_tb.vhd 
ghdl -e test_tb
./test_tb --stop-time=100ns --wave=test.ghw
gtkwave test.ghw test.sav
