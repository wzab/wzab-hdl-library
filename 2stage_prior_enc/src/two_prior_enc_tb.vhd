-------------------------------------------------------------------------------
-- Title      : Testbench for design "two_prior_enc"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : two_prior_enc_tb.vhd
-- Author     :   <wzab@wzab.nasz.dom>
-- Company    : 
-- Created    : 2016-09-07
-- Last update: 2016-09-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-09-09  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;

-------------------------------------------------------------------------------

entity two_prior_enc_tb is

end entity two_prior_enc_tb;

-------------------------------------------------------------------------------

architecture test of two_prior_enc_tb is

  constant N_INPUTS : integer := 128;
  constant N_1ST_BITS : integer := 4;
  -- component ports
  signal inputs : std_logic_vector (N_INPUTS-1 downto 0) := (others => '0');
  signal first  : integer range 0 to N_INPUTS-1 := 0;
  signal found : std_logic := '0';
  signal rst_p  : std_logic := '1';

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture test

  -- component instantiation
  DUT: entity work.two_prior_enc
    generic map (
      N_INPUTS => N_INPUTS,
      N_1ST_BITS => N_1ST_BITS)
    port map (
      inputs => inputs,
      found  => found,
      first => first,
      clk    => clk,
      rst_p  => rst_p);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 15 ns;
    rst_p <= '0';
    wait until rising_edge(Clk);
    inputs(127) <= '1';
    wait until rising_edge(Clk);
    inputs(27) <= '1';
    wait until rising_edge(Clk);
    inputs(13) <= '1';
    wait until rising_edge(Clk);
    inputs(13) <= '0';
    wait until rising_edge(Clk);
    inputs(0) <= '1';
    wait until rising_edge(Clk);
    inputs(0) <= '0';
    inputs(27) <= '0';
    wait until rising_edge(Clk);
    inputs(127) <= '0';
    wait until rising_edge(Clk);

    wait;
  end process WaveGen_Proc;

  

end architecture test;

-------------------------------------------------------------------------------


