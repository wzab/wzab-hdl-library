That code implements an adder which allows you to use hardware
 adders with long word (quite common in modern FPGAs) to perform
 multiple additions in parallel.

The code was first published on the Usenet alt.sources group
on 30th of November 2013 with subject "Generator of VHDL code for parallel adder (using long-word hardware adders to perform multiple additions in parallel)" 

The original post is available in the [Google archive](https://groups.google.com/forum/#!topic/alt.sources/8DqGgELScDM).

# DESCRIPTION #

I was solving a problem, when I needed to calculate every clock a sum of multiple values
encoded on a small number of bits (the latency of a few clocks is allowed).
A natural solution seemed to be a binary tree of adders, consisting of N levels,
when on each level I calculate a sum of two values.
E.g. assuming, that I have to calculate a sum of 8 values, I can calculate:

On the 1st level:

    Y0 = X0 + X1, Y1=X2+X3, Y2=X4+X5, Y3=X6+X7 (4 adders)

On the 2nd level: 

    V0 = Y0+Y1, V1=Y2+Y3 (2 adders)

On the 3rd level:

    Z = V0+V1  (1 adder)

If each level is equipped with a pipeline register, I can get a short critical path,
and the final latency is equal to 3 clocks, the new values may be entered every clock, 
and the result is availeble every clock. The whole design uses 7 adders.

However modern FPGAs are equipped with adders using long words. E.g. the Xilinx family 7
chips use adders with 25 bit input operands. 
If we assume, that the input values are encoded only at 5 bits, we can significantly
reduce consumption of resources.
Lets encode input words X0..X7 on bits of operands on the 1st level as follows:

    A(4 downto 0)=X0; A(5)='0';
    A(10 downto 6)=X2; A(11)='0';
    A(16 downto 12)=X4; A(17)='0';
    A(22 downto 18)=X6; A(23)='0';

    B(4 downto 0)=X1; B(5)='0';
    B(10 downto 6)=X3; B(11)='0';
    B(16 downto 12)=X5; B(17)='0';
    B(22 downto 18)=X7; B(23)='0';

Then on the first layer we can perform all calculations using only single adder:
C=A+B, and sub-sums are encoded as follows:

    C(5 downto 0)= X0+X1=Y0; C(11 downto 6)=X2+X3=Y1; C(17 downto 12)=X4+X5=Y2; C(23 downto 18)=X6+X7=Y3

On the 2nd level we work with 6-bit values (7-bit after addition of leading '0'), so we can perform
up to 3 additions in a single adder (but we need only 2)

    D(5 downto 0)=Y0; D(6)='0'; D(12 downto 7)=Y2; D(13)='0';
    E(5 downto 0)=Y1; D(6)='0'; D(12 downto 7)=Y3; D(13)='0';

After addition:
F=D+E we get:

    F(6 downto 0)=Y0+Y1=V0 ; F(13 downto 7)=Y2+Y3=V1;

The final addition may be performed in a standard way.
Please note, that now we had to use only 3 adders!

The tool "gen_parallel_adder.py" generates the VHDL source which uses adders with long words
to perform multiple additions in parallel.

The correct calling syntax is:

    gen_parallel_adder.py n m k name

where the arguments are:

  * n - number of input values
  * m - length of input words
  * k - length of input operand in the hardware adder
  * name - name of the component which will be generated.

The tool generates {name}.vhd file with implementation of the adders' tree
and {name}_pkg.vhd file with necessary types, and information about the latency.

Attached makefile generates sample parallel adder and simulates it using GHDL
and gtkwave.




