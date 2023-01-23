-------------------------------------------------------------------------------
-- Title      : Testbench for design "wz_random_pkg"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wz_random_tb.vhd
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
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wz_random_pkg.all;
-------------------------------------------------------------------------------

entity wz_random_tb is

end wz_random_tb;

-------------------------------------------------------------------------------

architecture test1 of wz_random_tb is

  -- clock
  signal Clk : std_logic := '1';
  constant DLEN : integer := 15;
  
begin  -- test1

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
    variable data : unsigned(DLEN-1 downto 0);
  begin
    for i in 0 to 50 loop
      wait until Clk = '0';
      wait until Clk = '1';
      data := random_unsigned(DLEN);
      report integer'image(to_integer(data)) severity note;
    end loop;
    wait;
  end process WaveGen_Proc;


end test1;


