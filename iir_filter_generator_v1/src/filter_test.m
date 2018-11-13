#!/usr/bin/octave
% Public domain script written by Wojciech M. Zabolotny
% wzab@ise.pw.edu.pl 
% To show simulation of IIR filters implemented in VHDL
%
% Generate the filter
%[b,a]=cheby1(6,0.5,0.2);
pkg load signal
[b,a]=cheby1(7,0.5,0.2);
% Set the number of integer and fractional bits
ibits = 16;
fbits = 20;
% Set number of clock cycles used to update the output
% of the "multistep" implementation
nsteps = 4;
% Extract lengths of a and b
[x,nb]=size(b);
[x,na]=size(a);
% Generate the step response of the filter
sr=filter(b,a,ones(100,1));
% Write the step response to the file
save "-ascii" output_octave.txt sr

% Now generate the fixed_prec package for GHDL simulations
s=["package fixed_prec_pkg is"];
s=[s;"constant ibits : integer := " num2str(ibits) ";"];
s=[s;"constant fbits : integer := " num2str(fbits) ";"];
s=[s;"end fixed_prec_pkg;"];
fo=fopen("fixed_prec.vhd","w");
fdisp(fo,s)
fclose(fo)

% Now generate the filtdef package for GHDL simulations
s=[
"library ieee;";
"use ieee.std_logic_1164.all;";
"use ieee.numeric_std.all;";
"use std.textio.all;";
"library ieee;";
"use ieee.fixed_pkg.all;";
"use work.fixed_prec_pkg.all;";
"use work.iir_fp_pkg.all;";
"package filtdef is"];
s=[s;"constant nsteps : integer := " num2str(nsteps) ";"];
s=[s;"constant na : integer := " num2str(na) ";"];
s=[s;"constant nb : integer := " num2str(nb) ";"];
l=["constant a_coeffs : T_IIR_COEFFS(0 to na-1) := ("];
for i = 1:na
  l=[l "tfs(" num2str(a(i),"%10.10e") ")"];
  if (i ~= na )
     l=[l,","];
  endif;
endfor
l=[l ");"];
s=[s;l];
l=["constant b_coeffs : T_IIR_COEFFS(0 to nb-1) := ("];
for i = 1:nb
  l=[l "tfs(" num2str(b(i),"%10.10e") ")"];
  if (i ~= nb) 
     l=[l ","];
  endif;
endfor
l=[l,");"];
s=[s;l;"end filtdef;"];
fo=fopen("filtdef.vhd","w");
fdisp(fo,s)
fclose(fo)
% Finally run the testbenches
system("make -f makefile_sstep clean")
system("make -f makefile_sstep")
system("make -f makefile_mstep clean")
system("make -f makefile_mstep")
% Compare results
system("xterm -e vim -O output_sstep.txt output_octave.txt output_mstep.txt")



