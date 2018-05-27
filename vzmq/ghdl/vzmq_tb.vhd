-------------------------------------------------------------------------------
-- Title      : Testbench for vzmq 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : vhpi_tb.vhd
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
use work.vzmq_pkg.all;
-------------------------------------------------------------------------------

entity vzmq_tb is

end vzmq_tb;

-------------------------------------------------------------------------------

architecture symul2 of vzmq_tb is

  signal sco   : integer   := 13254;
  signal sflag : std_logic := '0';

  component vzmq
    generic (
      MAX_SND : integer := 16384;
      MAX_RCV : integer := 16384
      );
    port
      (                                 --Sending interface
        snd_msg   : in  std_logic_vector(8*MAX_SND-1 downto 0);
        snd_stb   : in  std_logic;
        snd_bytes : in  std_logic_vector(31 downto 0);
        snd_ack   : out std_logic;
        --Receiving interface
        rcv_stb   : in  std_logic;
        rcv_ack   : out std_logic;
        rcv_msg   : out std_logic_vector(8*MAX_RCV-1 downto 0);
        rcv_bytes : out std_logic_vector(31 downto 0)
        );
  end component;

  signal snd_msg   : std_logic_vector(8*MAX_SND-1 downto 0) := (others => '0');
  signal snd_stb   : std_logic                              := '0';
  signal snd_bytes : std_logic_vector(31 downto 0)          := (others => '0');
  signal snd_ack   : std_logic                              := '0';
  signal rcv_stb   : std_logic                              := '0';
  signal rcv_ack   : std_logic                              := '0';
  signal rcv_msg   : std_logic_vector(8*MAX_RCV-1 downto 0) := (others => '0');
  signal rcv_bytes : std_logic_vector(31 downto 0)          := (others => '0');

begin  -- symul2

  vzmq_1 : vzmq
    generic map (
      MAX_SND => MAX_SND,
      MAX_RCV => MAX_RCV)
    port map (
      snd_msg   => snd_msg,
      snd_stb   => snd_stb,
      snd_bytes => snd_bytes,
      snd_ack   => snd_ack,
      rcv_stb   => rcv_stb,
      rcv_ack   => rcv_ack,
      rcv_msg   => rcv_msg,
      rcv_bytes => rcv_bytes);

  -- Receiving process
  process
    variable i, j   : integer;
    variable c      : integer;
    variable ln     : line;
    variable nbytes : integer;
  begin
    while true loop
      wait for 1 ns;
      sflag   <= '0';
      rcv_stb <= not rcv_stb;
      wait for 1 ns;
      if rcv_ack = '1' then
        report "message received!" severity note;
        sflag  <= '1';
        nbytes := to_integer(signed(rcv_bytes));
        j      := 0;
        c      := 0;
        if nbytes > 0 then
          write(ln, integer'image(nbytes));
          writeline(OUTPUT, ln);
          for i in 0 to (8*nbytes)-1 loop
            c := c*2;
            if rcv_msg(i) = '1' then
              c := c+1;
            end if;
            if j = 7 then
              write(ln, character'val(c));
              j := 0;
              c := 0;
            else
              j := j+1;
            end if;
          end loop;  -- i
          writeline(OUTPUT, ln);
        end if;
      end if;
    end loop;
  end process;

  process(sflag)
    constant txt  : string  := "Confirmation message";
    variable cd   : unsigned(7 downto 0);
    variable res  : integer := 0;
    variable mlen : integer := 0;
  begin
    if rising_edge(sflag) then
      snd_msg <= (others => '0');
      for i in 1 to txt'length loop
        cd := to_unsigned(character'pos(txt(i)), 8);
        for j in 0 to 7 loop
          if cd(j) = '1' then
            --snd_msg(8*(MAX_SND-i)+j) <= '1';
            snd_msg(8*(i-1)+7-j) <= '1';
          end if;
        end loop;  -- j
      end loop;  -- i
      snd_bytes <= std_logic_vector(to_unsigned(txt'length, 32));
      report "message sent!" severity note;
      snd_stb   <= not snd_stb;
      --report "returned " & integer'image(res) severity note;
      null;
    end if;
    null;
  end process;

end symul2;

-------------------------------------------------------------------------------
