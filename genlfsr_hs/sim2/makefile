VHDLS = \
  ../src/genlfsr_pkg.vhd \
  ../src/genlfsr.vhd \
  genlfsr_tb.vhd \


STD=standard
#STD=synopsys
dta_out.txt: genlfsr_tb
	./genlfsr_tb 
genlfsr_tb: ${VHDLS}
	ghdl -a --std=08 --ieee=${STD} ${VHDLS} 
	ghdl -e --std=08 -fexplicit --ieee=${STD} genlfsr_tb
clean:
	rm *.o *.vcd *.ghw *.dat *.cf genlfsr_tb
