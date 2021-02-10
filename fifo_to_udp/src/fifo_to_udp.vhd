-------------------------------------------------------------------------------
-- Title      : fifo_to_udp
-- Project    : wzab-hdl-library
-------------------------------------------------------------------------------
-- File	      : fifo_to_udp.vhd
-- Author     : Wojciech M. Zabołotny  <wzab01@gmail.com> or <wzab@ise.pw.edu.pl>
-- Company    : Institute of Electronic Systems, Warsaw University of Technology
-- SPDX-License-Identifier: BSD-3-Clause
-- Created    : 2021-01-31
-- Last update: 2021-02-10
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This block generates an Ethernet UDP packet taking the data from
--		the FIFO.
--		It is assumed that the data are delivered byte by byte
--		
-------------------------------------------------------------------------------
-- Copyright (c) 2021 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date	       Version	Author	Description
-- 2021-01-31  1.0	wzab	Created
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
    max_bytes : in  std_logic_vector(count_width - 1 downto 0);

    -- System interface
    clk		  : in	std_logic;
    rst_p	  : in	std_logic;
    -- FIFO interface
    fifo_av_bytes : in	std_logic_vector(count_width - 1 downto 0);
    fifo_din	  : in	std_logic_vector(7 downto 0);
    fifo_rd	  : out std_logic;
    fifo_empty	  : in	std_logic;
    -- ETH sender interface
    tx_data	  : out std_logic_vector(7 downto 0);
    tx_valid	  : out std_logic;
    tx_last	  : out std_logic;
    tx_ready	  : in	std_logic
    );

end entity fifo_to_udp;

architecture rtl of fifo_to_udp is

  type t_state is (st_idle, st_start, st_ethhdr, st_udphdr, st_data);
  signal state	   : t_state := st_idle;
  signal byte_cnt  : unsigned(count_width-1 downto 0);
  signal fifo_rd_s : std_logic;
  signal tr_count  : integer;

  type t_bytes is array (natural range <>) of std_logic_vector(7 downto 0);

  -- The function eth_hdr returns the byte_nr-th byte of the eth_hdr
  -- The fact that this function builds the header for each byte
  -- does not impact the synthesis (it may slow down the simulation)
  impure function eth_hdr (
    constant byte_nr : in integer)
    return std_logic_vector is
    variable hdr : t_bytes(0 to 13);
  begin	 -- function eth_hdr
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
  impure function ip_udp_hdr (
    constant byte_cnt : in unsigned(count_width-1 downto 0);
    constant byte_nr  : in integer)
    return std_logic_vector is
    variable hdr    : t_bytes(0 to 27);
    variable len    : integer;
    variable bv_len : std_logic_vector(15 downto 0);
    variable chksum : unsigned(31 downto 0);
    variable chkupd : unsigned(15 downto 0);
  begin	 -- function udp_hdr
    hdr(0)  := x"45";
    hdr(1)  := x"00";
    -- Put the datagram length
    len	    := 5*4 + 2*4 + to_integer(byte_cnt);
    bv_len  := std_logic_vector(to_unsigned(len, 16));
    hdr(2)  := bv_len(15 downto 8);
    hdr(3)  := bv_len(7 downto 0);
    hdr(4)  := x"11";			-- Fragments
    hdr(5)  := x"22";
    hdr(6)  := x"00";
    hdr(7)  := x"00";
    hdr(8)  := x"10";			-- TTL
    hdr(9)  := x"11";			-- Protocol UDP=17
    hdr(10) := x"00";			-- CHKSUM MSB
    hdr(11) := x"00";			-- CHKSUM LSB
    for i in 0 to 3 loop
      hdr(15-i) := my_ip(i*8+7 downto i*8);
    end loop;  -- i
    for i in 0 to 3 loop
      hdr(19-i) := rcv_ip(i*8+7 downto i*8);
    end loop;  -- i
    -- End of IP header
    -- Calculate the checksum
    chksum := (others => '0');
    for i in 0 to 9 loop
      chkupd(15 downto 8) := unsigned(hdr(i*2));
      chkupd(7 downto 0)  := unsigned(hdr(i*2+1));
      chksum		  := chksum + chkupd;
    end loop;  -- i
    -- Now add carry
    chkupd		 := (others => '0');
    chkupd(15 downto 0)	 := chksum(31 downto 16);
    chksum(31 downto 16) := (others => '0');
    chksum		 := chksum + chkupd;  -- Add carry from previous additions
    chksum		 := chksum + chksum(31 downto 16);  -- Add possible carry from the
							    -- last addition
    chksum		 := chksum xor x"ffffffff";
    hdr(10)		 := std_logic_vector(chksum(15 downto 8));
    hdr(11)		 := std_logic_vector(chksum(7 downto 0));
    -- Create the UDP header
    hdr(20)		 := x"00";
    hdr(21)		 := x"00";	-- source port 0 (not used)
    hdr(22)		 := dport(15 downto 8);
    hdr(23)		 := dport(7 downto 0);
    -- Calculate length of the UDP part
    len			 := 2*4 + to_integer(byte_cnt);
    bv_len		 := std_logic_vector(to_unsigned(len, 16));
    hdr(24)		 := bv_len(15 downto 8);
    hdr(25)		 := bv_len(7 downto 0);
    hdr(26)		 := x"00";
    hdr(27)		 := x"00";	-- CHKSUM (not used)
    return hdr(byte_nr);
  end function ip_udp_hdr;


begin  -- architecture rtl

  p1 : process (clk) is
  begin	 -- process p1
    if clk'event and clk = '1' then	-- rising clock edge
      if rst_p = '1' then		-- synchronous reset (active high)
	state	 <= st_idle;
	tx_valid <= '0';
	tx_last	 <= '0';
      else
	tx_last	 <= '0';
	tx_valid <= '0';
	case state is
	  when st_idle =>
	    if send = '1' then
	      state <= st_ethhdr;
	      if unsigned(max_bytes) < unsigned(fifo_av_bytes) then
		byte_cnt <= unsigned(max_bytes);
	      else
		byte_cnt <= unsigned(fifo_av_bytes);
	      end if;
	      tx_data  <= eth_hdr(0);
	      tx_valid <= '1';
	      tr_count <= 1;
	    end if;
	  when st_ethhdr =>
	    tx_valid <= '1';
	    if tx_ready = '1' then
	      tx_data  <= eth_hdr(tr_count);
	      tr_count <= tr_count + 1;
	      if tr_count = 13 then
		tr_count <= 0;
		state	 <= st_udphdr;
	      end if;
	    end if;
	  when st_udphdr =>
	    tx_valid <= '1';
	    if tx_ready = '1' then
	      tx_data  <= ip_udp_hdr(byte_cnt, tr_count);
	      tr_count <= tr_count + 1;
	      if tr_count = 27 then
		state <= st_data;
	      end if;
	    end if;
	  when st_data =>
	    tx_valid <= '1';
	    if fifo_rd_s = '1' then
	      tx_data  <= fifo_din;  	-- If fifo_rd is low, keep the previous
					-- value
	      if byte_cnt = 1 then
		tx_last <= '1';
	      end if;
	      if byte_cnt = 0 then
		tx_valid <= '0';
		busy	 <= '0';
		state	 <= st_idle;
	      else
		byte_cnt <= byte_cnt - 1;
	      end if;
	    end if;
	  when others => null;
	end case;
      end if;
    end if;
  end process p1;

  -- When we read from FIFO?
  -- when data_transfer is '1', tx_ready is '1' end fifo_empty is '0'
  fifo_rd_s <= '1' when ((state = st_data) and
			 (tx_ready = '1') and
			 (fifo_empty = '0')) else '0';
  fifo_rd <= fifo_rd_s;

end architecture rtl;
