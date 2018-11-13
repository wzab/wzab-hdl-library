#!/bin/bash
mkdir ip
COMP="ghdl -a --std=93c --ieee=standard --workdir=ip --work=ieee_proposed "
#$COMP fmod.vhd
#$COMP fixed_float_types_c.vhdl
#$COMP fixed_pkg_c.vhdl
#$COMP float_pkg_c.vhdl
#$COMP numeric_std_additions.vhdl
#$COMP numeric_std_unsigned_c.vhdl
#$COMP standard_additions_c.vhdl
#$COMP standard_textio_additions_c.vhdl
#$COMP std_logic_1164_additions.vhdl
$COMP env_c.vhdl
