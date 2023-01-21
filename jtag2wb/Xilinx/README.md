# Description #

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

## Important remark ##

Please remember, that you must ensure that your server properly communicates with the FPGA,
The crucial part is:

    # The length of the shift should correspond to the length of the instruction register of your FPGA
    # The shifted value should correspond to the USER command, that selects
    # your BSCANE2 as the data register
    scan_ir_hw_jtag 6 -tdi 02

That's good for the Artix 7 chip. How do you know? Just check `Vivado/2020.1/data/parts/xilinx/artix7/public/bsdl/xa7a100t_csg324.bsd` file. You'll see:

    attribute INSTRUCTION_LENGTH of XA7A100T_CSG324 : entity is 6;
    [...]
    "USER1 (000010)," & -- Not available until after configuration

If you are using another chip, you may need to change the line used to switch on communication with your controller. For example, for Kintex Ultrascale XCKU115, we have in file `Vivado/2020.1/data/parts/xilinx/kintexu/public/xcku115_flvf1924.bsd`:

    -- Instruction Register Description
    attribute INSTRUCTION_LENGTH of XCKU115_FLVF1924 : entity is 12;
    [...]
    "USER1          (000010100100)," & -- PRIVATE, Not available until after configuration
    "USER2          (000011100100)," & -- PRIVATE, Not available until after configuration
    "USER3          (100010100100)," & -- PRIVATE, Not available until after configuration
    "USER4          (100011100100)," & -- PRIVATE, Not available until after configuration

So the right line would be:

`scan_ir_hw_jtag 12 -tdi 0a4`


