STD=synopsys
VSTD=08
ENTITY=wb_test_top_tb
# --unbuffered option must be added in the new GHDL
RUN_OPTIONS= --unbuffered --stop-time=3900ns --wave=${ENTITY}.ghw 
#RUN_OPTIONS= --stop-time=290000ns 
#RUN_OPTIONS=  --wave=${ENTITY}.ghw 
SOURCES = \
 general-cores/modules/genrams/genram_pkg.vhd \
 general-cores/modules/wishbone/wishbone_pkg.vhd \
 general-cores/modules/wishbone/wb_crossbar/xwb_crossbar.vhd \
 my-cores/sim_wb_ctrl.vhd \
 my-cores/wb_test.vhd \
 my-cores/wb_test_top.vhd \
 my-cores/wb_test_top_tb.vhd \

OBJECTS=$(SOURCES:.vhd=.o)

%.o : %.vhd
	ghdl -a -g -C  --std=${VSTD} --ieee=${STD} $<
#	ghdl -a -g -C --workdir=comp --std=${VSTD} --ieee=${STD} $<

#--trace-signals --trace-processes
#RUN_OPTIONS= 
#--trace-processes
all: show
show:   ${ENTITY} ${ENTITY}.ghw
	gtkwave ${ENTITY}.ghw ${ENTITY}.sav
${ENTITY}: $(SOURCES:.vhd=.o)
#	vhdlp -work fmf fmf/*.vhd
#	ghdl -e -g --mb-comments --workdir=comp --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
	ghdl -e -g --mb-comments  --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
${ENTITY}.ghw: ${ENTITY}
#	./${ENTITY} --wave=${ENTITY}.ghw  ${RUN_OPTIONS} --stop-time=50000ns 2>&1 > res.txt
	./${ENTITY} ${RUN_OPTIONS} 
#> res.txt  2>&1 
clean:
	rm -f comp/* *.o *.vcd *.ghw events* ${ENTITY}

