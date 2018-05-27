-------------------------------------------------------------------------------
-- Title      : Testbench for vzmq 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : vhpi_tb.vhd
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
-- Copyright (c) 2016, 2018
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-05-20  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.vzmq.all;
-------------------------------------------------------------------------------

entity vzmq_tb is

end vzmq_tb;

-------------------------------------------------------------------------------

architecture symul2 of vzmq_tb is

  signal sco   : integer                       := 13254;
  signal sflag : std_logic                     := '0';

begin  -- symul2

  process
    variable ts   : integer             := 5;
    variable nmax : integer             := 1000;
    variable nact : integer             := 0;
    variable buf  : unsigned(0 to 8*ZMQ_RCV_MAX-1) := (others => '0');
    variable j    : integer             := 0;
    variable c    : integer             := 0;
    variable ln   : line;
  begin
    init_zmq_server(ZMQ_SND_MAX, ZMQ_RCV_MAX);
    while true loop
      zmq_get_message(nmax, nact, buf);
      j := 0;
      c := 0;
      if nact > 0 then
        write(ln, integer'image(nact));
        writeline(OUTPUT, ln);
        for i in 0 to (8*nact)-1 loop
          c := c/2;
          if buf(i) = '1' then
            c :=c+128;
          end if;
          if j = 7 then
            write(ln, character'val(c));
            j := 0;
            c := 0;
          else
            j :=j+1;
          end if;
        end loop;  -- i
        writeline(OUTPUT, ln);
        sflag <= '1';
        wait for 5 ns;
        sflag <= '0';
        wait for 5 ns;
      end if;
    end loop;

  end process;

  process(sflag)
    variable sbuf : unsigned(0 to 8*ZMQ_SND_MAX-1) := (others => '0');
    constant txt  : string              := "Confirmation message";
    variable cd   : unsigned(7 downto 0);
    variable res  : integer             := 0;
    variable mlen : integer             := 0;
  begin
    if rising_edge(sflag) then
      sbuf := (others => '0');
      for i in 1 to txt'length loop
        cd := to_unsigned(character'pos(txt(i)), 8);
        for j in 0 to 7 loop
          if cd(j) = '1' then
            sbuf((i-1)*8+j) := '1';
          end if;
        end loop;  -- j
      end loop;  -- i
      mlen := txt'length;
      report "message sent!" severity note;
      zmq_put_message(mlen, res, sbuf);
      report "returned " & integer'image(res) severity note;
      null;
    end if;
    null;
  end process;

end symul2;

-------------------------------------------------------------------------------
