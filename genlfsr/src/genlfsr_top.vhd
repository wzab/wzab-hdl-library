
-------------------------------------------------------------------------------
-- Title      : Testbench for design "genlfsr"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : genlfsr_tb.vhd
-- Author     : Wojciech Zabolotny  <wzab@WZabHP.nasz.dom>
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
-- 2021-10-22  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.genlfsr_pkg.all;
-------------------------------------------------------------------------------

entity genlfsr_top is
  generic(
    width : integer := 16
    );
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    dout : out std_logic_vector(width-1 downto 0);
    ena  :     std_logic);

end entity genlfsr_top;

-------------------------------------------------------------------------------

architecture test of genlfsr_top is

  -- component generics
  constant length : integer     := 167;
  constant taps   : T_LFSR_TAPS := (167, 161);

  signal clk_out1 : std_logic;
  signal rst_n    : std_logic;
  signal locked   : std_logic;
  signal dout_x   : std_logic_vector(width-1 downto 0);

  component clk_main
    port
      (                                 -- Clock in ports
        -- Clock out ports
        clk_out1 : out std_logic;
        -- Status and control signals
        reset    : in  std_logic;
        locked   : out std_logic;
        clk_in1  : in  std_logic
        );
  end component;

begin  -- architecture test

  s1 : process (clk_out1) is
  begin  -- process s1
    if clk_out1'event and clk_out1 = '1' then  -- rising clock edge
      dout <= dout_x;
    end if;
  end process s1;

  clk_main_1 : entity work.clk_main
    port map (
      clk_out1 => clk_out1,
      reset    => rst,
      locked   => locked,
      clk_in1  => clk);


  rst_n <= locked and (not rst);

-- component instantiation
  DUT : entity work.genlfsr
    generic map (
      width  => width,
      length => length,
      taps   => taps)
    port map (
      rst_n => rst_n,
      ena   => ena,
      clk   => clk_out1,
      dout  => dout_x);

end architecture test;

