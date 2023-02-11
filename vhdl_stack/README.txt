This is text part of the original message sent to alt sources.
It is archived at http://ftp.fi.netbsd.org/pub/misc/archive/alt.sources/1401.gz

From: Wojciech Zabolotny <wzab@ise.pw.edu.pl>
Newsgroups: alt.sources
Subject: FSM with state stack in VHDL
Date: Mon, 31 Dec 2007 15:48:56 +0000 (UTC)
Organization: http://news.icm.edu.pl/
Message-ID: <slrnfni43i.so1.wzab@ipebio15.ise.pw.edu.pl>

Archive-name: stack-fsm
Submitted-by: wzab@ise.pw.edu.pl

Hi All,

Playing with the Spartan 3E Starter Kit reference designs, I've found the
following  "Exercise" in the "Initial Design - LCD Display Control).

Exercise: Implement a hardware state machine which can perform
the LCD initialisation sequence. Compare the size of your implementation
with the 96 slices required to implement a PicoBlaze processor.

Trying to implement a required state machine, I've found an idea which is
quite interesting, but may also seem to be crazy:
A state machine with "soubroutines". The idea is to implement typical
state sequences as "subroutines", which may be "called" after pushing
the next state to the stack.

There are two implementations provided. One implements the stack in
registers, but "return" requires only a single cycle. The another one
uses additional clock cycle, to simplify access to the stack, which allows
XST to implement the stack in the inferred RAM.

The resulting code requires 159 slices in version with stack in inferred
RAM, or 189 slices in the version with stack implemented in registers.

The code heavily uses VHDL procedures, but synthesizes correctly with XST.
I have also a version, where procedures are replaced with M4 macros,
so you can generate the "procedure-free" VHDL for less advanced synthesis 
tools.

The code is published as public domain. Maybe someone will find this idea
useful?

The sources contain also the GHDL testbench: lcd_test_tb.vhd, and the shell
script needed to run it.
If you are going to run the simulation however, change the definition
of the T_CLK from:
   constant T_CLK : integer := 20;
to:
   constant T_CLK : integer := 2000;
Otherwise the simulation will be very loooong, and the resulting file will
occupy a lot of space.
 
Regards & Happy New Year!
Wojciech M. Zabolotny
wzab@ise.pw.edu.pl

