-------------------------------------------------------------------------------
-- Title      : Testbench for design "genlfsr"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : genlfsr_tb.vhd
-- Author     : Wojciech Zabołotny  <wzab@WZabHP.nasz.dom>
-- Company    : 
-- Created    : 2021-10-22
-- Last update: 2023-07-05
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
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.genlfsr_pkg.all;
-------------------------------------------------------------------------------

entity genlfsr_tb is

end entity genlfsr_tb;

-------------------------------------------------------------------------------

architecture test of genlfsr_tb is

  -- component generics
  constant width  : integer     := 16;
  constant length1 : integer     := 167;
  constant taps1   : T_LFSR_TAPS := (167, 161);
  constant length2 : integer     := 125;
  constant taps2   : T_LFSR_TAPS := (125,124,18,17);

  -- component ports
  signal rst_n : std_logic := '0';
  signal ena   : std_logic := '0';
  signal dout  : std_logic_vector(width-1 downto 0);
  signal dout_x1   : std_logic_vector(width-1 downto 0);
  signal dout_x2   : std_logic_vector(width-1 downto 0);

  signal simend : boolean := false;
  signal count_ena : std_logic := '0';

  constant COUNT_SIZE : integer := 21;
  
  signal clk_count : unsigned(COUNT_SIZE-1 downto 0) := (others => '0');
  signal clk_count_stop : unsigned(COUNT_SIZE-1 downto 0) := (COUNT_SIZE-1 => '1', others => '0');
  
  -- clock
  signal Clk : std_logic := '1';
  

    -- Bit reversal based on Jonathan Bromley post
  -- https://groups.google.com/g/comp.lang.vhdl/c/eBZQXrw2Ngk/m/4H7oL8hdHMcJ
  function rev (
    constant x : std_logic_vector)
    return std_logic_vector is
    variable res : std_logic_vector(x'range);
    alias xrev : std_logic_vector(x'reverse_range) is x;    
  begin  -- function rev
    for i in xrev'range loop
      res(i) := xrev(i);
    end loop;  -- i
    return res;
  end function rev;
 
begin  -- architecture test

  -- component instantiation
  DUT1: entity work.genlfsr
    generic map (
      width  => width,
      length => length1,
      taps   => taps1)
    port map (
      rst_n => rst_n,
      ena   => ena,
      clk   => Clk,
      dout  => dout_x1);

    -- component instantiation
  DUT2: entity work.genlfsr
    generic map (
      width  => width,
      length => length2,
      taps   => taps2)
    port map (
      rst_n => rst_n,
      ena   => ena,
      clk   => Clk,
      dout  => dout_x2);

  dout <= dout_x1 xor rev(dout_x2);

 data_dump: process (clk) is
   file out_file : text open write_mode is "dta_out.txt";
   variable out_line : line;
 begin  -- process data_dump
   if clk'event and clk = '1' then   -- rising clock edge
     if count_ena = '1' then
       if clk_count > clk_count_stop then
         simend <= True;
       else
         clk_count <= clk_count + 1;
         hwrite(out_line,dout,left,(width+3)/4);
         writeline(out_file,out_line);
       end if;
     end if;
   end if;
 end process data_dump;
  
  -- clock generation
  Clk <= not Clk after 10 ns when simend=False else '0';

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 15 ns;
    rst_n <= '1';
    wait for 10 ns;
    ena <= '1';
    -- wait until the PRNG "stabilize"
    wait for 10000 ns;
    -- Start writing data and counting clocks
    count_ena <= '1';
    wait;
  end process WaveGen_Proc;

  

end architecture test;

-------------------------------------------------------------------------------

configuration genlfsr_tb_test_cfg of genlfsr_tb is
  for test
  end for;
end genlfsr_tb_test_cfg;

-------------------------------------------------------------------------------
