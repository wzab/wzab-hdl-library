STD=synopsys
VSTD=93c
ENTITY=wz_random_tb
#RUN_OPTIONS= --stop-time=2900ns --wave=${ENTITY}.ghw 
RUN_OPTIONS= --stop-time=290000ns 
#RUN_OPTIONS=  --wave=${ENTITY}.ghw 
SOURCES = \
  wz_random_pkg.vhd \
  wz_random_tb.vhd \

OBJECTS=$(SOURCES:.vhd=.o)

all: $(OBJECTS)

%.o : %.vhd
	ghdl -a -g -C  --std=${VSTD} --ieee=${STD} $<
#	ghdl -a -g -C --workdir=comp --std=${VSTD} --ieee=${STD} $<

#--trace-signals --trace-processes
#RUN_OPTIONS= 
#--trace-processes
all: ${ENTITY}.ghw
reader:   ${ENTITY} ${ENTITY}.ghw
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

