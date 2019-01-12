VHDLS = \
  wzadd_pkg.vhd \
  wzadd.vhd \
  wzadd_tb.vhd \


STD=standard
#STD=synopsys

show_ghw:   wzadd_tb test.ghw
	gtkwave test.ghw test.sav
wzadd.vhd:
	./gen_parallel_adder.py 10 4 24 wzadd
wzadd_pkg.vhd:
	./gen_parallel_adder.py 10 4 24 wzadd
wzadd_tb: ${VHDLS}
	ghdl -a --std=93c --ieee=${STD} ${VHDLS} 
	ghdl -e --std=93c -fexplicit --ieee=${STD} wzadd_tb
test.ghw: wzadd_tb
	./wzadd_tb --wave=test.ghw --stop-time=200ns
clean:
	rm wzadd.vhd wzadd_pkg.vhd *.o *.vcd *.ghw *.dat *.cf *.raw *.wav wzadd_tb

