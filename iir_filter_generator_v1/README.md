Two-phase configurable priority encoder in VHDL
===============================================
This code has been published first on 2nd of April 2011 as PUBLIC DOMAIN at usenet alt.sources group
with the subject "Behavioral but synthesizable implementation of IIR filters in VHDL".

The post is available in the [google archive](https://groups.google.com/forum/#!msg/alt.sources/AYOs37DoPoE/7O6Mm4sDz8gJ)

Attached sources implement the IIR filters in VHDL.
The filters are described with behavioral code, but they are
also suitable for synthesis.
Two versions of filters are provided. In the iir_fphdl_sstep
all calculations are done in a single step, so design is really 
resources hungry.
In the iir_fphdl_mstep the output value of the filter is calculated
in a few clock cycles (defined by "nsteps"). Therefore the same 
multiplier may be used for different calculations in consecutive
clock cycles.

The archive contains my files, which are PUBLIC DOMAIN
and one file which is redistributed under GPL license (fmod.vhd).

To run simulation of filters with GHDL ( http://ghdl.free.fr )
you should create a directory, then donwload and unpack
http://www.vhdl.org/fphdl/vhdl2008c.zip in this directory 
and unpack archive with my sources.
To get vhdl2008c compiled with GHDL you should set the write permission
to fixed_pkg_c.vhdl and add the marked line near to begining of the file:

|library IEEE_PROPOSED;
|use IEEE_PROPOSED.fixed_float_types.all;
|use ieee_proposed.math_real_fmod.all;  -- <== This line must be added !
|
|package fixed_pkg is

Then run the "comp.sh" script to compile VHDL2008 compatibility library
After that you may run the "filter_test.m" file in Octave, which performs
simulation of the same filter in Octave, and in GHDL - in "single step"
and "multiple steps" configurations. Finally the vim is used to display 
step responses of all filters.
In the "filter_test.m" you can modify the parameters of the simulated
filter.
You can also watch the generated ghw files with gtkwave to see
how filters work.

If you want to test synthesis, you should dowmnload and unpack somewhere
http://www.vhdl.org/fphdl/xilinx_11.zip sources.

For synthesis I've used the following sources (contents of the .prj file)

For "multiple steps" configuration:

    vhdl ieee_proposed "../fphdl/fixed_float_types_c.vhdl"
    vhdl ieee_proposed "../fphdl/fixed_pkg_c.vhdl"
    vhdl work "../fixed_prec.vhd"
    vhdl work "../iir_fphdl_pkg.vhd"
    vhdl work "../iir_fphdl_mstep.vhd"
    vhdl work "../filtdef.vhd"
    vhdl work "../iir_top_mstep.vhd"

For "single step" configuration:
    
    vhdl ieee_proposed "../fphdl/fixed_float_types_c.vhdl"
    vhdl ieee_proposed "../fphdl/fixed_pkg_c.vhdl"
    vhdl work "../fixed_prec.vhd"
    vhdl work "../iir_fphdl_pkg.vhd"
    vhdl work "../iir_fphdl_sstep.vhd"
    vhdl work "../filtdef.vhd"
    vhdl work "../iir_top_sstep.vhd"

Plese try to synthesize filter defined currently in filter_test.m
into 3s250eft256 device and into 3s500eft256 device to see the difference
between both implementations...

Of course the proposed implementation of IIR filters is far from optimal.
In fact it would be much better to implement them in cascade or parallel
form...
Unless otherwise specified in the source files, the code is published under Public Domain or Creative Commons CC0 license
(whatever better suits your needs)

This is a free and Open Source solution. I don't give any warranty.
You use it at your own risk!

Wojciech M. Zabolotny wzab01@gmail.com


