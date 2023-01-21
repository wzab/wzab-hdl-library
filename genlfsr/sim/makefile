VHDLS = \
  ../src/genlfsr_pkg.vhd \
  ../src/genlfsr.vhd \
  genlfsr_tb.vhd \


STD=standard
#STD=synopsys
show_ghw:   genlfsr_tb genlfsr_tb.ghw
	gtkwave genlfsr_tb.ghw genlfsr.sav
genlfsr_tb: ${VHDLS}
	ghdl -a --std=93c --ieee=${STD} ${VHDLS} 
	ghdl -e --std=93c -fexplicit --ieee=${STD} genlfsr_tb
genlfsr_tb.ghw: genlfsr_tb
	./genlfsr_tb --wave=genlfsr_tb.ghw --stop-time=2000000ns
clean:
	rm *.o *.vcd *.ghw *.dat *.cf genlfsr_tb
