#!/bin/bash
set -e
# Compile the VHDL
VHDLS="\
 lcd_ram.vhd \
 lcd_test_tb.vhd \
 "
STD=standard
mkdir -p work
#STD=synopsys
ghdl -a --workdir=work --std=02  --ieee=$STD $VHDLS
ghdl -e --workdir=work --std=02  --ieee=$STD lcd_test_tb
# Run the simulation
./lcd_test_tb --wave=lcd.ghw --stop-time=10000000ns
# Let'us view the recorded waveforms
gtkwave lcd.ghw lcd.sav
