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

package vzmq_pkg is

  -- Maximum length of received and transmitted messages in bytes
  constant MAX_SND : integer := 1000;
  constant MAX_RCV : integer := 2000;
  
end vzmq_pkg;

