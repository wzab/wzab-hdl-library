-------------------------------------------------------------------------------
-- Title      : Testbench for design "wzadd"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wzadd_tb.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- Created    : 2013-11-30
-- Last update: 2013-11-30
-- Platform   : 
-- Standard   : VHDL'87
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
use work.wzadd_pkg.all;
-------------------------------------------------------------------------------

entity wzadd_tb is

end wzadd_tb;

-------------------------------------------------------------------------------

architecture test1 of wzadd_tb is

  component wzadd
    port (
      din   : in  T_WZADD_INPUTS;
      clk   : in  std_logic;
      rst_n : in  std_logic;
      dout  : out unsigned(7 downto 0));
  end component;

  -- component ports
  signal din   : T_WZADD_INPUTS;
  signal rst_n : std_logic := '0';
  signal dout  : unsigned(7 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- test1

  -- component instantiation
  DUT : wzadd
    port map (
      din   => din,
      clk   => clk,
      rst_n => rst_n,
      dout  => dout);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    din(0) <= to_unsigned(1, 4);
    din(1) <= to_unsigned(2, 4);
    din(2) <= to_unsigned(3, 4);
    din(3) <= to_unsigned(4, 4);
    din(4) <= to_unsigned(5, 4);
    din(5) <= to_unsigned(6, 4);
    din(6) <= to_unsigned(7, 4);
    din(7) <= to_unsigned(8, 4);
    din(8) <= to_unsigned(9, 4);
    din(9) <= to_unsigned(10, 4);
    wait until Clk = '0';
    rst_n  <= '1';
    wait until Clk = '1';
    din(0) <= to_unsigned(15, 4);
    din(1) <= to_unsigned(14, 4);
    din(2) <= to_unsigned(13, 4);
    din(3) <= to_unsigned(12, 4);
    din(4) <= to_unsigned(11, 4);
    din(5) <= to_unsigned(10, 4);
    din(6) <= to_unsigned(9, 4);
    din(7) <= to_unsigned(8, 4);
    din(8) <= to_unsigned(7, 4);
    din(9) <= to_unsigned(6, 4);
    wait until Clk = '0';
    wait until Clk = '1';
    din(0) <= to_unsigned(0, 4);
    din(1) <= to_unsigned(2, 4);
    din(2) <= to_unsigned(4, 4);
    din(3) <= to_unsigned(6, 4);
    din(4) <= to_unsigned(8, 4);
    din(5) <= to_unsigned(10, 4);
    din(6) <= to_unsigned(12, 4);
    din(7) <= to_unsigned(14, 4);
    din(8) <= to_unsigned(1, 4);
    din(9) <= to_unsigned(2, 4);
    wait until Clk = '0';
    wait until Clk = '1';
    wait until Clk = '0';
    wait until Clk = '1';
    wait until Clk = '0';
    wait until Clk = '1';
    wait until Clk = '0';
    wait until Clk = '1';
    wait;
  end process WaveGen_Proc;


end test1;

-------------------------------------------------------------------------------

configuration wzadd_tb_test1_cfg of wzadd_tb is
  for test1
  end for;
end wzadd_tb_test1_cfg;

-------------------------------------------------------------------------------
