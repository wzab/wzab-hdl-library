STD=standard
#STD=synopsys
VSTD=93c
ENTITY=fifo_to_udp_tb
# --unbuffered option must be added in the new GHDL
RUN_OPTIONS= --unbuffered --stop-time=20000ns --wave=${ENTITY}.ghw 
#RUN_OPTIONS+= --trace-signals
#RUN_OPTIONS= --stop-time=290000ns 
#RUN_OPTIONS=  --wave=${ENTITY}.ghw 

SOURCES = \
 src/fifo_to_udp.vhd \
 src/fifo_to_udp_tb.vhd \

OBJECTS=$(SOURCES:.vhd=.o)

all: show

$(OBJECTS): %.o : %.vhd
	ghdl -a -g -C  --std=${VSTD} --ieee=${STD} $<

#--trace-signals --trace-processes
#RUN_OPTIONS= 
#--trace-processes
show:   ${ENTITY} ${ENTITY}.ghw
	gtkwave ${ENTITY}.ghw ${ENTITY}.sav
${ENTITY}: ${OBJECTS_GC} ${OBJECTS_AGWB} ${OBJECTS}
#	vhdlp -work fmf fmf/*.vhd
#	ghdl -e -g --mb-comments --workdir=comp --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
	ghdl -e -g --mb-comments  --std=${VSTD} -fexplicit --ieee=${STD} ${ENTITY}
${ENTITY}.ghw: ${ENTITY}
#	./${ENTITY} --wave=${ENTITY}.ghw  ${RUN_OPTIONS} --stop-time=50000ns 2>&1 > res.txt
	./${ENTITY} ${RUN_OPTIONS} 
#> res.txt  2>&1 
clean:
	rm -f comp/* *.o *.vcd *.ghw *.cf events* ${ENTITY}

