-------------------------------------------------------------------------------
-- Title      : Package vzmq 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : vzmq_tb.vhd
-- Author     : Wojciech M. Zabolotny (wzab01<at>gmail.com or wzab<at>ise.pw.edu.pl
-- Company    : Institute of Electronic Systems
-- License    : Public Domain or Creative Commons CC0
-- Created    : 2018-05-20
-- Last update: 2018-05-26
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: vzmq - package for passing ZMQ messages to GHDL or XSIM simulation
-------------------------------------------------------------------------------
-- Copyright (c) 2016,2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-05-20  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.vzmq_pkg.all;

entity vzmq is
  generic (
    MAX_SND : integer := MAX_SND;
    MAX_RCV : integer := MAX_RCV);
  port (
    -- Sending interface
    snd_msg   : in  std_logic_vector(8*MAX_SND-1 downto 0);
    snd_stb   : in  std_logic;
    snd_bytes : in  std_logic_vector(31 downto 0);
    snd_ack   : out std_logic := '0';
    -- Receiving interface
    rcv_stb   : in  std_logic;
    rcv_ack   : out std_logic := '0';
    rcv_msg   : out std_logic_vector(8*MAX_RCV-1 downto 0);
    rcv_bytes : out std_logic_vector(31 downto 0)
    );

end entity vzmq;

architecture beh of vzmq is

  signal rcv_flag  : std_logic := '0';
  
begin  -- architecture beh

  -- Initialization of the ZMQ server
  process is
  begin  -- process
    report "Initializing server" severity note;
    init_zmq_server(MAX_SND,MAX_RCV);
    wait;    
  end process;
  
  process (snd_stb) is
    variable v_snd_bytes : integer := 0;
    variable v_act_snd : integer := 0;
    variable v_snd_msg : std_logic_vector(8*MAX_SND-1 downto 0) := (others => '0');
  begin  -- process 
    if snd_stb'event then
      report "send in VHDL" severity note;
      v_snd_bytes := to_integer(signed(snd_bytes));
      v_snd_msg := snd_msg;
      zmq_put_message(v_snd_bytes, v_act_snd, v_snd_msg);
      if (v_act_snd >= 0) then
        snd_ack <= '1';
      else
        snd_ack <= '0';
      end if;
    end if;
  end process;

  process (rcv_stb) is
    variable v_rcv_bytes : integer := 0;
    variable v_act_rcv : integer :=0 ;
    variable v_rcv_msg : std_logic_vector(8*MAX_RCV-1 downto 0) := (others => '0');
  begin  -- process
    if rcv_stb'event then
      rcv_flag <= not rcv_flag;
      v_rcv_bytes := MAX_RCV;
      zmq_get_message(v_rcv_bytes, v_act_rcv, v_rcv_msg);
      rcv_msg <= v_rcv_msg;
      rcv_bytes <= std_logic_vector(to_signed(v_act_rcv,32));
      if (v_act_rcv > 0) then
        rcv_ack <= '1';
      else
        rcv_ack <= '0';
      end if;
    end if;
  end process;


end architecture beh;

