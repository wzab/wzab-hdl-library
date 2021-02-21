-------------------------------------------------------------------------------
-- Title      : fifo_to_udp
-- Project    : wzab-hdl-library
-------------------------------------------------------------------------------
-- File       : fifo_to_udp.vhd
-- Author     : Wojciech M. Zabo??otny  <wzab01@gmail.com> or <wzab@ise.pw.edu.pl>
-- Company    : Institute of Electronic Systems, Warsaw University of Technology
-- SPDX-License-Identifier: BSD-3-Clause
-- Created    : 2021-01-31
-- Last update: 2021-02-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This block generates an Ethernet UDP packet taking the data from
--              the FIFO.
--              It is assumed that the data are delivered byte by byte
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-01-31  1.0      wzab    Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity fifo_to_udp is

  generic (
    count_width : integer := 15);

  port (
    my_MAC    : in  std_logic_vector(47 downto 0);
    my_IP     : in  std_logic_vector(31 downto 0);
    rcv_MAC   : in  std_logic_vector(47 downto 0);
    rcv_IP    : in  std_logic_vector(31 downto 0);
    dport     : in  std_logic_vector(15 downto 0);
    -- Control interface
    send      : in  std_logic;
    busy      : out std_logic;
    max_words : in  std_logic_vector(count_width - 1 downto 0);

    -- System interface
    clk           : in  std_logic;
    rst_p         : in  std_logic;
    -- FIFO interface
    fifo_av_words : in  std_logic_vector(count_width - 1 downto 0);
    fifo_din      : in  std_logic_vector(31 downto 0);
    fifo_rd       : out std_logic;
    fifo_empty    : in  std_logic;
    -- ETH sender interface
    tx_data       : out std_logic_vector(7 downto 0);
    tx_valid      : out std_logic;
    tx_last       : out std_logic;
    tx_ready      : in  std_logic
    );

end entity fifo_to_udp;

architecture rtl of fifo_to_udp is

  type t_state is (st_idle, st_start, st_ethhdr, st_udphdr, st_counter1, st_counter2, st_data);
  signal state     : t_state               := st_idle;
  signal word_cnt  : unsigned(count_width-1 downto 0);
  signal word_cnt2 : unsigned(count_width-1 downto 0);
  signal fifo_rd_s : std_logic;
  signal tr_count  : integer;
  signal pkt_num   : unsigned(15 downto 0) := (others => '0');

  type t_bytes is array (natural range <>) of std_logic_vector(7 downto 0);

  -- The function eth_hdr returns the byte_nr-th byte of the eth_hdr
  -- The fact that this function builds the header for each byte
  -- does not impact the synthesis (it may slow down the simulation)
  impure function eth_hdr (
    constant byte_nr : in integer)
    return std_logic_vector is
    variable hdr : t_bytes(0 to 13);
  begin  -- function eth_hdr
    -- Copy the receiver MAC
    for i in 0 to 5 loop
      hdr(5-i) := rcv_mac(i*8+7 downto i*8);
    end loop;  -- i
    -- Copy the sender MAC
    for i in 0 to 5 loop
      hdr(11-i) := my_mac(i*8+7 downto i*8);
    end loop;  -- i
    -- Put the ether type
    hdr(12) := x"08";
    hdr(13) := x"00";
    return hdr(byte_nr);
  end function eth_hdr;

  -- The function eth_hdr returns the byte_nr-th byte of the udp_hdr
  -- The fact that this function builds the header for each byte
  -- does not impact the synthesis (it may slow down the simulation)
  -- As we don't know the data (yet) when we assemble the header,
  -- we don't calculate the checksum (optional in IPv4).
  -- We rely on Ethernet frame chksum.

  function init_ip_udp_hdr
    return t_bytes is
    variable hdr : t_bytes(27 downto 0);
  begin  -- function udp_hdr
    hdr(0)  := x"45";
    hdr(1)  := x"00";
    -- Put the datagram length
    --len           := 5*4 + 2*4 + 4*to_integer(word_cnt);
    --bv_len  := std_logic_vector(to_unsigned(len, 16));
    hdr(2)  := x"00";                   --bv_len(15 downto 8);
    hdr(3)  := x"00";                   --bv_len(7 downto 0);
    hdr(4)  := x"11";                   -- Fragments
    hdr(5)  := x"22";
    hdr(6)  := x"00";
    hdr(7)  := x"00";
    hdr(8)  := x"10";                   -- TTL
    hdr(9)  := x"11";                   -- Protocol UDP=17
    -- Chksum
    hdr(10) := x"00";                   -- CHKSUM MSB
    hdr(11) := x"00";                   -- CHKSUM LSB
    -- My IP
    hdr(12) := x"00";
    hdr(13) := x"00";
    hdr(14) := x"00";
    hdr(15) := x"00";
    -- RCV IP
    hdr(16) := x"00";
    hdr(17) := x"00";
    hdr(18) := x"00";
    hdr(19) := x"00";
    -- End of IP header
    -- UDP header
    hdr(20) := x"00";
    hdr(21) := x"00";                   -- source port 0 (not used)
    hdr(22) := x"00";                   -- := dport(15 downto 8);
    hdr(23) := x"00";                   -- := dport(7 downto 0);
    -- Calculate length of the UDP part
    -- len                       := 2*4 + 4*to_integer(word_cnt);
    -- bv_len            := std_logic_vector(to_unsigned(len, 16));
    hdr(24) := x"00";                   --bv_len(15 downto 8);
    hdr(25) := x"00";                   --bv_len(7 downto 0);
    hdr(26) := x"00";
    hdr(27) := x"00";                   -- CHKSUM (not used)
    return hdr;
  end function init_ip_udp_hdr;

  function init_udp_hdr_chksum(constant hdr : t_bytes(27 downto 0))
    return unsigned is
    variable chksum : unsigned(31 downto 0) := (others => '0');
    variable tmp    : unsigned(15 downto 0);
  begin
    for i in 0 to 9 loop
      tmp(15 downto 8) := unsigned(hdr(2*i));
      tmp(7 downto 0)  := unsigned(hdr(2*i+1));
      chksum           := chksum + resize(tmp, 32);
      if chksum(16) = '1' then
        chksum(31 downto 16) := (others => '0');
        chksum               := chksum + 1;
        if chksum(16) = '1' then
          chksum := chksum + 1;
        end if;
      end if;
      chksum(31 downto 16) := (others => '0');
    end loop;  -- i
    return chksum(15 downto 0);
  end function init_udp_hdr_chksum;

  function update_udp_hdr_chksum(old_chks : unsigned(15 downto 0); val : unsigned(15 downto 0))
    return unsigned is
    variable chksum : unsigned(31 downto 0) := (others => '0');
  begin
    chksum := resize(old_chks(15 downto 0), 32) + resize(val(15 downto 0), 32);
    if chksum(16) = '1' then
      chksum(31 downto 16) := (others => '0');
      chksum               := chksum + 1;
      if chksum(16) = '1' then
        chksum := chksum + 1;
      end if;
      chksum(31 downto 16) := (others => '0');
    end if;
    return chksum(15 downto 0);
  end function update_udp_hdr_chksum;

  signal udp_hdr        : t_bytes(27 downto 0) := init_ip_udp_hdr;
  signal udp_step       : integer;
  signal udp_hdr_chksum : unsigned(15 downto 0);
  signal udp_hdr_start  : std_logic            := '0';

begin  -- architecture rtl

  udphdr : process (clk, rst_p) is
    variable len       : unsigned(15 downto 0);
    variable v_udp_hdr : t_bytes(27 downto 0) := init_ip_udp_hdr;
  begin  -- process udphdr
    if clk'event and clk = '1' then     -- rising clock edge
      if rst_p = '1' then               -- asynchronous reset (active high)
        udp_hdr  <= init_ip_udp_hdr;
        udp_step <= 0;
      else
        case udp_step is
          when 0 =>
            if udp_hdr_start = '1' then
              v_udp_hdr      := init_ip_udp_hdr;
              udp_hdr        <= v_udp_hdr;
              udp_hdr_chksum <= init_udp_hdr_chksum(v_udp_hdr);
              udp_step       <= 1;
              udp_hdr(22)    <= dport(15 downto 8);
              udp_hdr(23)    <= dport(7 downto 0);
              if unsigned(fifo_av_words) > unsigned(max_words) then
                word_cnt <= unsigned(max_words);
              else
                word_cnt <= unsigned(fifo_av_words);
              end if;
            end if;
          when 1 =>
            len            := 5*4 + 2*4 +resize(4*word_cnt, 16);
            udp_hdr_chksum <= update_udp_hdr_chksum(udp_hdr_chksum, len);
            udp_hdr(2)     <= std_logic_vector(len(15 downto 8));
            udp_hdr(3)     <= std_logic_vector(len(7 downto 0));
            udp_step       <= 2;
          when 2 =>
            udp_hdr_chksum <= update_udp_hdr_chksum(udp_hdr_chksum, unsigned(my_ip(31 downto 16)));
            udp_hdr(12)    <= my_ip(31 downto 24);
            udp_hdr(13)    <= my_ip(23 downto 16);
            udp_step       <= 3;
          when 3 =>
            udp_hdr_chksum <= update_udp_hdr_chksum(udp_hdr_chksum, unsigned(my_ip(15 downto 0)));
            udp_hdr(14)    <= my_ip(15 downto 8);
            udp_hdr(15)    <= my_ip(7 downto 0);
            udp_step       <= 4;
          when 4 =>
            udp_hdr_chksum <= update_udp_hdr_chksum(udp_hdr_chksum, unsigned(rcv_ip(31 downto 16)));
            udp_hdr(16)    <= rcv_ip(31 downto 24);
            udp_hdr(17)    <= rcv_ip(23 downto 16);
            udp_step       <= 5;
          when 5 =>
            udp_hdr_chksum <= update_udp_hdr_chksum(udp_hdr_chksum, unsigned(rcv_ip(15 downto 0)));
            udp_hdr(18)    <= rcv_ip(15 downto 8);
            udp_hdr(19)    <= rcv_ip(7 downto 0);
            udp_step       <= 6;
          when 6 =>
            udp_hdr(10) <= std_logic_vector(udp_hdr_chksum(15 downto 8)) xor x"ff";
            udp_hdr(11) <= std_logic_vector(udp_hdr_chksum(7 downto 0)) xor x"ff";
            len         := 2*4 + resize(4 * word_cnt, 16);
            udp_hdr(24) <= std_logic_vector(len(15 downto 8));
            udp_hdr(25) <= std_logic_vector(len(7 downto 0));
            udp_step    <= 0;
          when others =>
            udp_step <= 0;
        end case;
      end if;
    end if;
  end process udphdr;

  p1 : process (clk) is
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      if rst_p = '1' then               -- synchronous reset (active high)
        state         <= st_idle;
        tx_valid      <= '0';
        tx_last       <= '0';
        busy          <= '0';
        udp_hdr_start <= '0';
      else
        tx_last       <= '0';
        tx_valid      <= '0';
        udp_hdr_start <= '0';
        case state is
          when st_idle =>
            tx_valid <= '0';
            if send = '1' then
              busy          <= '1';
              state         <= st_ethhdr;
              -- Trigger preparation of the UDP header
              udp_hdr_start <= '1';
              tx_data       <= eth_hdr(0);
              tx_valid      <= '1';
              tr_count      <= 1;
            end if;
          when st_ethhdr =>
            -- Process word_cnt in a pipeline
            -- the FSM remains in that state for 13 cycles,
            -- so the word_cnt will be calculated and will be stable
            tx_valid <= '1';
            if tx_ready = '1' then
              tx_data  <= eth_hdr(tr_count);
              tr_count <= tr_count + 1;
              if tr_count = 13 then
                tr_count <= 0;
                state    <= st_udphdr;
              end if;
            end if;
          when st_udphdr =>
            tx_valid <= '1';
            if tx_ready = '1' then
              --tx_data  <= ip_udp_hdr(word_cnt, tr_count);
              tx_data  <= udp_hdr(tr_count);
              tr_count <= tr_count + 1;
              if tr_count = 27 then
                state <= st_counter1;
              end if;
            end if;
          when st_counter1 =>
            tx_valid <= '1';
            if tx_ready = '1' then
              tx_data <= std_logic_vector(pkt_num(15 downto 8));
              state   <= st_counter2;
            end if;
          when st_counter2 =>
            tx_valid <= '1';
            if tx_ready = '1' then
              tx_data   <= std_logic_vector(pkt_num(7 downto 0));
              pkt_num   <= pkt_num + 1;
              tr_count  <= 3;
              word_cnt2 <= to_unsigned(1, count_width);
              state     <= st_data;
            end if;
          when st_data =>
            tx_valid <= '1';
            -- If tx_ready is low, keep the previous value
            if tx_ready = '1' then
              tx_data <= fifo_din(8*tr_count+7 downto 8*tr_count);
              if tr_count = 0 then
                if word_cnt = word_cnt2 then
                  tx_last <= '1';
                  busy    <= '0';
                  state   <= st_idle;
                else
                  word_cnt2 <= word_cnt2 + 1;
                  tr_count  <= 3;
                end if;
              else
                tr_count <= tr_count - 1;
              end if;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process p1;

  -- When we read from FIFO?
  -- when data_transfer is '1', tx_ready is '1', tr_count is 3 and fifo_empty is '0'
  fifo_rd_s <= '1' when ((state = st_data) and
                         (tx_ready = '1') and
                         (tr_count = 0) and
                         (fifo_empty = '0')) else '0';
  fifo_rd <= fifo_rd_s;

end architecture rtl;
