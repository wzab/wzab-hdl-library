-------------------------------------------------------------------------------
-- Title      : Testbench for design "lcd_test"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lcd_test_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2007-12-30
-- Last update: 2007-12-30
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-12-30  1.0      xl	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity lcd_test_tb is

end lcd_test_tb;

-------------------------------------------------------------------------------

architecture test of lcd_test_tb is

  component lcd_test
    port (
      led            : out std_logic_vector(7 downto 0);
      lcd            : out std_logic_vector(7 downto 4);
      lcd_rs         : out std_logic;
      lcd_rw         : out std_logic;
      lcd_e          : out std_logic;
      strataflash_oe : out std_logic;
      strataflash_we : out std_logic;
      strataflash_ce : out std_logic;
      sys_clk       : in  std_logic;
      sys_rst       : in  std_logic);
  end component;

  -- component ports
  signal led            : std_logic_vector(7 downto 0);
  signal lcd            : std_logic_vector(7 downto 4);
  signal lcd_rs         : std_logic;
  signal lcd_rw         : std_logic;
  signal lcd_e          : std_logic;
  signal strataflash_oe : std_logic;
  signal strataflash_we : std_logic;
  signal strataflash_ce : std_logic;
  signal main_clk       : std_logic;
  signal main_rst       : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- test

  -- component instantiation
  DUT: lcd_test
    port map (
      led            => led,
      lcd            => lcd,
      lcd_rs         => lcd_rs,
      lcd_rw         => lcd_rw,
      lcd_e          => lcd_e,
      strataflash_oe => strataflash_oe,
      strataflash_we => strataflash_we,
      strataflash_ce => strataflash_ce,
      sys_clk       => main_clk,
      sys_rst       => main_rst);

  -- clock generation
  Clk <= not Clk after 10 ns;
  main_clk <= Clk;
  
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    main_rst <= '1';
    wait until Clk = '1';
    wait for 300 ns;
    main_rst <= '0';
    wait for 500_000_000 ns;
  end process WaveGen_Proc;

  

end test;

-------------------------------------------------------------------------------

configuration lcd_test_tb_test_cfg of lcd_test_tb is
  for test
  end for;
end lcd_test_tb_test_cfg;

-------------------------------------------------------------------------------
