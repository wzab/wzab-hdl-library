These are the sources of the simple JTAG-UART for Xilinx FPGAs with BSCANE2 JTAG block.
If you instantiate the jtag_uart in your design, then you may run Vivado in the batch mode:

    $ vivado -mode batch -source uart_srv.tcl

And you'll get the UART server listening on the TCP port 9900.
Then you may connect to it from netcat:

    $ nc localhost 9900

You may also communicate with it from other software written in C or Python or another language.

Please note, that the JTAG UART server fully loads one CPU core, as it must continuously perform the JTAG scan operations to check if the new character arrives.
At the moment there is also a problem to stop it. (CTRL+C stops the server, but does not cause Vivado to exit). You need to kill the Vivado from another console with kill command.

The code is published as PUBLIC DOMAIN or under Creative Commons CC0 license.
You can do with it whatever you want, but I don't give you warranty of any kind.

The code was first published on the Usenet alt.sources group - [JTAG-UART IP core and TCP server in Tcl for Xilinx FPGAs](https://groups.google.com/d/msg/alt.sources/cMhDPauWLm4/nwzZMg8ZCQAJ), and on [Xilinx forum](https://forums.xilinx.com/t5/Vivado-TCL-Community/Is-there-a-JTAG-UART-available-for-PS-implemented-logic/m-p/923926/highlight/true#M7461).
