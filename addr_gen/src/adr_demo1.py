#!/usr/bin/python3
"""
The code below is written by Wojciech M. Zabolotny ( wzab01<at>gmail.com or wzab<at>ise.pw.edu.pl)
9-11.02.2018 and is published as Public domain or under Creative Commons CC0 license.
It is used to generate the map of addresses for VHDL designs using the vector of control
or status registers to communicate with software (via IPbus, AXI-Lite or other bus.)
"""
from addr_gen import *
import time
#Definitions of constants used in the package
c.ADDR_VERSION=int(time.time()) #Record version to match HDL and SW address definitions
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
gen_vhdl_addr_package("top_adr_pkg","",top_def,0,0)

#Generate Python module with addresses
gen_python_addr_module("top_adr",top_def,0,0)

