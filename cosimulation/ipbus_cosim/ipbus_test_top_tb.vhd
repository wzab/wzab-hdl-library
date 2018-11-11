-------------------------------------------------------------------------------
-- Title      : Testbench for design "ipbus_test_top"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ipbus_test_top_tb.vhd
-- Author     : Wojciech Zabołotny  <wzab@WZlap.nasz.dom>
-- Company    : 
-- Created    : 2015-02-05
-- Last update: 2015-02-05
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-02-05  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity ipbus_test_top_tb is

end entity ipbus_test_top_tb;

-------------------------------------------------------------------------------

architecture test1 of ipbus_test_top_tb is

  -- component generics
  constant rdpipename : string := "/tmp/rdpipe";
  constant wrpipename : string := "/tmp/wrpipe";

  -- component ports
  signal ipb_rst : std_logic := '1';
  signal ipb_clk : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture test1

  -- component instantiation
  DUT: entity work.ipbus_test_top
    generic map (
      rdpipename => rdpipename,
      wrpipename => wrpipename)
    port map (
      ipb_rst => ipb_rst,
      ipb_clk => ipb_clk);

  -- clock generation
  Clk <= not Clk after 30 ns;

  ipb_clk <= Clk;
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 100 ns;
    ipb_rst <= '0';
    wait;
  end process WaveGen_Proc;

  

end architecture test1;

-------------------------------------------------------------------------------

configuration ipbus_test_top_tb_test1_cfg of ipbus_test_top_tb is
  for test1
  end for;
end ipbus_test_top_tb_test1_cfg;

-------------------------------------------------------------------------------
