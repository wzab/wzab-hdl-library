-------------------------------------------------------------------------------
-- Title      : Testbench for design "genlfsr"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : genlfsr_tb.vhd
-- Author     : Wojciech Zabołotny  <wzab@WZabHP.nasz.dom>
-- Company    : 
-- Created    : 2021-10-22
-- Last update: 2021-10-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-10-22  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.genlfsr_pkg.all;
-------------------------------------------------------------------------------

entity genlfsr_tb is

end entity genlfsr_tb;

-------------------------------------------------------------------------------

architecture test of genlfsr_tb is

  -- component generics
  constant width  : integer     := 16;
  constant length : integer     := 17;
  constant taps   : T_LFSR_TAPS := (17, 14);

  -- component ports
  signal rst_n : std_logic := '0';
  signal ena   : std_logic := '0';
  signal dout  : std_logic_vector(width-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture test

  -- component instantiation
  DUT: entity work.genlfsr
    generic map (
      width  => width,
      length => length,
      taps   => taps)
    port map (
      rst_n => rst_n,
      ena   => ena,
      clk   => Clk,
      dout  => dout);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 15 ns;
    rst_n <= '1';
    wait for 10 ns;
    ena <= '1';
  end process WaveGen_Proc;

  

end architecture test;

-------------------------------------------------------------------------------

configuration genlfsr_tb_test_cfg of genlfsr_tb is
  for test
  end for;
end genlfsr_tb_test_cfg;

-------------------------------------------------------------------------------
