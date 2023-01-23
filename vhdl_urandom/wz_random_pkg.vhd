-------------------------------------------------------------------------------
-- Title      : Function returning random bytes from Linux /dev/urandom
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wz_random_pkg.vhd
-- Author     : Wojciech M. Zabolotny wzab<at>ise.pw.edu.pl
-- Company    : 
-- Created    : 2013-11-30
-- Last update: 2023-01-23
-- Platform   : 
-- Standard   : VHDL'93
-- License    : PUBLIC DOMAIN CODE
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-11-30  1.0      wzab    Created
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

package wz_random_pkg is

  impure function random_byte
    return unsigned;

  impure function random_unsigned(len : integer)
    return unsigned;

end package wz_random_pkg;

package body wz_random_pkg is

  type T_CHAR_FILE is file of character;
  file urandom_file : T_CHAR_FILE open read_mode is "/dev/urandom";

  impure function random_byte
    return unsigned is
    variable res      : unsigned(7 downto 0);
    variable rnd_char : character;
  begin  -- function random_byte
    read(urandom_file, rnd_char);
    res := to_unsigned(character'pos(rnd_char), 8);
    return res;
  end function random_byte;

  impure function random_unsigned(len : integer)
    return unsigned is
    variable res  : unsigned((len-1) downto 0);
    variable code : unsigned(7 downto 0);
    variable pos  : integer;
    variable lim  : integer;
  begin  -- function random_byte
    pos := 0;
    res := (others => '0');
    while pos < len loop
      code := random_byte;
      lim  := len-pos;
      if lim > 8 then
        lim := 8;
      end if;
      res((pos+lim-1) downto pos) := code(lim-1 downto 0);
      pos                         := pos+8;
    end loop;
    return res;
  end function random_unsigned;

end package body wz_random_pkg;
