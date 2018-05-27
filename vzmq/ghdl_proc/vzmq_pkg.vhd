-------------------------------------------------------------------------------
-- Title      : Package vzmq 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : vzmq_tb.vhd
-- Author     : Wojciech M. Zabolotny (wzab01<at>gmail.com or wzab<at>ise.pw.edu.pl
-- Company    : Institute of Electronic Systems
-- License    : Public Domain or Creative Commons CC0
-- Created    : 2018-05-20
-- Last update: 2018-05-24
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: vzmq - package for passing ZMQ messages to GHDL simulation
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

package vzmq is

  -- Maximum length of received and transmitted messages in bytes
  constant ZMQ_RCV_MAX : integer := 1000;
  constant ZMQ_SND_MAX : integer := 2000;
  
  procedure init_zmq_server (
    constant max_send : in integer;
    constant max_receive : in integer
    );
  attribute foreign of init_zmq_server : procedure is "VHPIDIRECT init_zmq_server_c";

  procedure zmq_get_message (
    variable nmax : in integer;
    variable nact : out integer;
    variable v1 : inout unsigned(0 to 8*ZMQ_RCV_MAX-1)
    );
  attribute foreign of zmq_get_message : procedure is "VHPIDIRECT zmq_get_message_c";

  procedure zmq_put_message (
    variable msize : in integer;
    variable nact : out integer;
    variable v1 : inout unsigned(0 to 8*ZMQ_SND_MAX-1)
    );
  attribute foreign of zmq_put_message : procedure is "VHPIDIRECT zmq_put_message_c";

end vzmq;

package body vzmq is

  procedure init_zmq_server (
    constant max_send : in integer;
    constant max_receive : in integer
    ) is
  begin
    assert false severity failure;
  end init_zmq_server;

  procedure zmq_get_message (
    variable nmax : in integer;
    variable nact : out integer;
    variable v1 : inout unsigned(0 to 8*ZMQ_RCV_MAX-1)
    ) is
  begin
    assert false severity failure;
  end zmq_get_message;

  procedure zmq_put_message (
    variable msize : in integer;
    variable nact : out integer;
    variable v1 : inout unsigned(0 to 8*ZMQ_SND_MAX-1)
    ) is
  begin
    assert false severity failure;
  end zmq_put_message;

end vzmq;

