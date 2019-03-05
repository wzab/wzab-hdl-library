This is a simple JTAG to Wishbone bridge that you may use to debug your WB-based designs
from the quartus_stp console.
The solution consists of three files:

  * jtag2wb.vhd - implements the JTAG to Wishbone bridge IP core
  * jtag2wb.tcl - implements the Tcl code working with that IP core 
  * jtag2wb_srv.tcl - Implements the TCP server that allows you to perform read and write operations via TCP/IP socket.

The Tcl code offers four functions:
      (Please note, that you may need to adapt the code
      so that your JTAG programmer and the appropriate FPGA chip is correctly found).

  *  bus_open<br/>
      must be called to start accessing the controller

  *  bus_close<br/>
      must be called to stop accessing the controller

  *  bus_write address value<br/>
      Writes to the register under specific address.
  
  *  bus_read address<br/>
      Reads the value from the register under specific address
      and returns it.

This is a "quick&dirty" implementation. so probably the code may be significantly improved or corrected. It worked and appeared to be useful for me, so I decided to share it.

This is a free code published as PUBLIC DOMAIN or under Creative Commons CC0 license.

I do not provide warranty of any kind. If you decide to use it, you do it on your own risk.
The code was first published on Usenet alt.sources group - [JTAG to Wishbone bridge with TCP server for Intel/Altera FPGAs](https://groups.google.com/d/msg/alt.sources/npW-y9S7qE0/S1llbzeXCAAJ), and [JTAG to Wishbone bridge for debugging in quartus_stp console](https://groups.google.com/d/msg/alt.sources/npW-y9S7qE0/L0hNbgOWCAAJ)
