Last time I had to prepare a firmware for FPGA, that contained a complex hierarchy of blocks and subbblocks, containing registers and arrays of registers on different levels of hierarchy. Those registers were connected to simple block driven by IPbus ( https://github.com/ipbus/ipbus-firmware ) or AXI-Lite slave (e.g., generated with Tools/Create and Package New IP/Ctreate AXI4 Peripheral), that provides certain number of R/W - "Control" and RO - "Status" registers.
Until the design was small, it was easy to allocate the register addresses by hand and to connect them with manually written HDL.
However, as the design grew up, this task became more tiring and error prone.
Therefore, I have decided to prepare something to automate this task. Initially I tried to prepare my own metalanguage to describe the structure, and parse it with "pyparsing".
However, finally I have found a simpler solution, where the structure of design is described in pure Python.
Lets assume, that our design contains the top entity "Top", that contains 3 registers, N_OF_A blocks "ABlock" and, N_OF_B blocks "BBlock".
The nested blocks also have a complex structure, as shown below:

	TOP
	|
	|
	+-SREG: top_status
	+-CREG: sys_control
	+-CREG: resets
	|
	+-N_OF_A x ABlocks
	| |
	| +-SREG: A_status
	| +-CREG: A_control
	| +-N_OF_I2C_SLAVES x I2CBlock
	| | |
	| | +-CREG: I2C_Config
	| | +-SREG: I2C_Status
	| | +-CREG: I2C_Command
	| |
	| +-N_OF_SPI_SLAVES x SPIBlock
	|   |
	|   +-CREG: SPI_Config
	|   +-SREG: SPI_Status
	|   +-CREG: SPI_Tx
	|   +-SREG: SPI_Rx
	|
	+-N_OF_B x BBlocks
	  |
	  +- N_OF_CELLS x CREG: Out_data
	  +- N_OF_CELLS x SREG: In_data
	  +- SREG: B_status
	  +- CREG: B_config

Maintaining of addresses in the above structure, especially when the constants "N_OF..." are changing, is really a nightmare.
In my proposed solution, the abover structure may be described in a simple Python file:

	#!/usr/bin/python3
	from addr_gen import *

	#Definitions of constants used in the package
	c.ADDR_VERSION=int(time.time())
	c.N_OF_A = 13
	c.N_OF_I2C_SLAVES = 6
	c.N_OF_SPI_SLAVES = 8
	c.N_OF_B = 5
	c.N_OF_CELLS = 12

	#Define registers in the BBlock
	bbl_def=aobj("BBLOCK",[
	  ("out_data",sreg_def,c.N_OF_CELLS),
	  ("in_data",sreg_def,c.N_OF_CELLS),
	])

	#Define registers in SPI block
	spi_def=aobj("SPI",[
	  ("spi_config",creg_def),
	  ("spi_status",sreg_def),
	  ("spi_tx",creg_def),
	  ("spi_rx",sreg_def),
	])

	#Define registers in I2C block
	i2c_def=aobj("I2C",[
	  ("i2c_config",creg_def),
	  ("i2c_status",sreg_def),
	  ("i2c_command",creg_def),
	])

	#Define registers and subblocks in the ABlock
	abl_def=aobj("ABLOCK",[
	  ("a_status",creg_def),
	  ("a_control",creg_def,2), #Two registers, supporting up to 64 links
	  ("spi",spi_def,c.N_OF_SPI_SLAVES),
	  ("i2c",spi_def,c.N_OF_I2C_SLAVES),
	])

	#Define registers and subblocks in the TOP block
	top_def=aobj("TOP",[
	  ("addr_ver",sreg_def),
	  ("top_st",sreg_def),
	  ("sys_ctrl",sreg_def),
	  ("resets",creg_def),
	  ("ab",abl_def,c.N_OF_A),
	  ("bb",bbl_def,c.N_OF_B),
	])

	#Generate package with constants
	gen_vhdl_const_package("top_const_pkg")

	#Generate package with address related types and addresses
	gen_vhdl_addr_package("top_adr_pkg","",crob_def,0,0)

	#Generate Python module with addresses
	gen_python_addr_module("top_adr",crob_def,0,0)

Running the above, generates the appropriate VHDL packages with constants and addresses, and python module with addresses.
Connection of signals in the VHDL code may be done as follows:
(I assume, that each blocks provides inputs from control registers and output to status registers in hierarchical records like below:

	  type T_I2C_CTRL is record
	    i2c_config : std_logic_vector(31 downto 0);
	    i2c_command : std_logic_vector(31 downto 0);
	  end record T_I2C_CTRL;
	  type T_I2C_CTRL_ARR is array(natural range<>) of T_I2C_CTRL;
	  
	  type T_SPI_CTRL is record
	    spi_config : std_logic_vector(31 downto 0);
	    spi_command : std_logic_vector(31 downto 0);
	  end record T_SPI_CTRL;
	  type T_SPI_CTRL_ARR is array(natural range<>) of T_SPI_CTRL;
	  
	  type T_ABL_CTRL is record
	    a_control: std_logic_vector(31 downto 0);
	    spi : T_SPI_CTRL_ARR(0 to N_OF_SPI_SLAVES-1);
	    i2c : T_I2C_CTRL_ARR(0 to N_OF_I2C_SLAVES-1);
	  end record T_ABL_CTRL;

)

	-- Process for connecting the signals
    	process (all) is
	    begin  -- process
	      stat_reg(tad_addr.addr_ver) <= std_logic_vector(to_unsigned(32,ADDR_VERSION));
	      stat_reg(tad_addr.top_st) <= s_top_status;
	      s_top_control <= ctrl_reg(tad_addr.sys_ctrl);
	      s_resets <= ctrl_reg(tad_addr.resets);
	      for an in 0 to N_OF_A-1 loop
	         stat_reg(tad_addr.ab(an).a_status)<=s_a_stat(an).a_status;
	         s_a_ctrl(an)<=ctrl_reg(tad_addr.ab(an).a_control);
	         for spin in 0 to N_OF_SPI_SLAVES loop
	            s_a_ctrl(an).spi(spin).spi_config <= ctrl_reg(tad_addr.ab(an).spi(spin).spi_config;
	            stat_reg(tad_addr.ab(an).spi(spin).spi_status) <= s_a_stat(an).spi(spin).spi_status;
	            s_a_ctrl(an).spi(spin).spi_command <= ctrl_reg(tad_addr.ab(an).spi(spin).spi_command;
	         end loop; -- spin
	         -- Similar loop for I2C slaves
	      end loop;  -- an
	      -- Similar loop for B Blocks
	    end process;

The presented approach allows to maintain addresses allocation during the long term development of the design.
I'll appreciate any improvements, suggestions and corrections.
I publish that code as Public Domain or Creative Commons CC0 license, whatever better suits your needs.
I hope that it will be useful or inspiring for somebode, but I do not provide warranty of any kind.

With best regards,
Wojtek

