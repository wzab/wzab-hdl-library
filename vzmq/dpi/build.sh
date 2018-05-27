xelab --dpiheader vzmq.h -svlog vzmq.sv 
xsc --gcc_link_options lzmq vzmqc.c
xelab -svlog vzmq.sv -sv_lib dpi -vhdl vzmq_pkg.vhd -vhdl vzmq_tb.vhd -R
