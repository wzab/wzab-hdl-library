-------------------------------------------------------------------------------
-- Title      : Testbench for design "fifo_to_udp"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fifo_to_udp_tb.vhd
-- Author     : Wojciech Zabołotny  <wzab@wzab>
-- Company    : 
-- Created    : 2021-02-10
-- Last update: 2021-02-10
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-02-10  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;

-------------------------------------------------------------------------------

entity fifo_to_udp_tb is

end entity fifo_to_udp_tb;

-------------------------------------------------------------------------------

architecture beh of fifo_to_udp_tb is

  -- component generics
  constant count_width : integer := 16;

  -- component ports
  signal my_MAC	       : std_logic_vector(47 downto 0) := x"0a0b0c0d0e1d";
  signal my_IP	       : std_logic_vector(31 downto 0) := x"1c4bac54";
  signal rcv_MAC       : std_logic_vector(47 downto 0) := x"123456789abc";
  signal rcv_IP	       : std_logic_vector(31 downto 0) := x"34657812";
  signal dport	       : std_logic_vector(15 downto 0) := x"1234";
  signal send	       : std_logic := '0';
  signal busy	       : std_logic;
  signal rst_p	       : std_logic := '1';
  signal fifo_av_words : std_logic_vector(count_width - 1 downto 0) := x"0010";
  signal fifo_din      : std_logic_vector(7 downto 0) := x"ab";
  signal fifo_rd       : std_logic;
  signal fifo_empty    : std_logic := '0';
  signal tx_data       : std_logic_vector(7 downto 0);
  signal tx_valid      : std_logic;
  signal tx_last       : std_logic;
  signal tx_ready      : std_logic := '1';

  -- clock
  signal Clk : std_logic := '1';

  type bfile is file of character;
  file pkt_out : bfile open write_mode is "packet.bin";
  
begin  -- architecture beh

  -- component instantiation
  DUT: entity work.fifo_to_udp
    generic map (
      count_width => count_width)
    port map (
      my_MAC	    => my_MAC,
      my_IP	    => my_IP,
      rcv_MAC	    => rcv_MAC,
      rcv_IP	    => rcv_IP,
      dport	    => dport,
      send	    => send,
      busy	    => busy,
      clk	    => clk,
      rst_p	    => rst_p,
      fifo_av_words => fifo_av_words,
      fifo_din	    => fifo_din,
      fifo_rd	    => fifo_rd,
      fifo_empty    => fifo_empty,
      tx_data	    => tx_data,
      tx_valid	    => tx_valid,
      tx_last	    => tx_last,
      tx_ready	    => tx_ready);

  -- clock generation
  Clk <= not Clk after 10 ns;

  w1: process (clk) is
    variable pout : character;
  begin  -- process w1
    if clk'event and clk = '1' then  	-- rising clock edge
      if tx_ready = '1' and tx_valid = '1' then
	pout := character'val(to_integer(unsigned(tx_data)));
	write(pkt_out,pout);	
      end if;
    end if;
  end process w1;
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for 15 ns;
    rst_p <= '0';
    wait until rising_edge(Clk);
    send <= '1';
    wait until rising_edge(Clk);
    send <= '0';
    wait until busy = '0';
    wait until rising_edge(Clk);
    wait;    
  end process WaveGen_Proc;

  

end architecture beh;

-------------------------------------------------------------------------------

configuration fifo_to_udp_tb_beh_cfg of fifo_to_udp_tb is
  for beh
  end for;
end fifo_to_udp_tb_beh_cfg;

-------------------------------------------------------------------------------
