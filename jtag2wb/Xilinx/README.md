This is a simple JTAG to Wishbone bridge that you may use to debug your WB-based designs from the Vivado Tcl console.
The solution consists of two files:


  * jtag2wb.vhd - implements the JTAG to Wishbone bridge IP core
  * jtag2wb.tcl - implements the Tcl code working with that IP core

The Tcl code offers just three functions:

  *  bus_init<br/>
      must be called to get access to the controller
      (Please note, that you may need to adapt this procedure
      so that your JTAG programmer is correctly found).

  *  bus_write address value<br/>
      Writes to the register under specific address.
  
  *  bus_read address<br/>
      Reads the value from the register under specific address
      and returns it.

This is a "quick&dirty" implementation. so probably the code may be significantly improved or corrected. It worked and appeared to be useful for me, so I decided to share it.

This is a free code published as PUBLIC DOMAIN or under Creative Commons CC0 license.

I do not provide warranty of any kind. If you decide to use it, you do it on your own risk.
The code was first published on Usenet alt.sources group - [JTAG to Wishbone bridge for debugging in Vivado Tcl console](https://groups.google.com/d/msg/alt.sources/npW-y9S7qE0/M7vBcFyGCgAJ) and on [Xilinx forum](https://forums.xilinx.com/t5/Vivado-TCL-Community/JTAG-to-Wishbone-Master/m-p/924687/highlight/true#M7492).
