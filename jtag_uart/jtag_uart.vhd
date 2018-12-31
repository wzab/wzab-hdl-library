-------------------------------------------------------------------------------
-- Title      : jtag_uart - simple UART-like communication interface 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : jtag_uart.vhd
-- Author     : Wojciech M. Zabolotny
-- License    : PUBLIC DOMAIN
-- Company    : 
-- Created    : 2018-12-20
-- Last update: 2018-12-25
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description:
--
--
--   That code is significantly based on my JTAG bus controller
--   published in https://groups.google.com/d/msg/alt.sources/Rh5yEuF2YGE/p6UB0RdRS-AJ
--   thread on alt.sources Usenet group.
-------------------------------------------------------------------------------
-- Copyright (c) 2018 Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl) 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-12-20  1.0      wzab      Created
-------------------------------------------------------------------------------
--
--  This program is PUBLIC DOMAIN or Creative Commons CC0 code
--  You can do with it whatever you want. However, NO WARRANTY of ANY KIND
--  is provided
--
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library work;

entity jtag_uart is
  port (
    din   : in  std_logic_vector(7 downto 0);
    dout  : out std_logic_vector(7 downto 0);
    wr    : in  std_logic;
    rd    : in  std_logic;
    clk   : in  std_logic;
    rst_n : in  std_logic;
    rdy   : out std_logic;
    dav   : out std_logic
    );
end jtag_uart;

architecture syn of jtag_uart is

  component BSCANE2
    generic (
      JTAG_CHAIN : integer);
    port (
      CAPTURE : out std_ulogic;
      DRCK    : out std_ulogic;
      RESET   : out std_ulogic;
      RUNTEST : out std_ulogic;
      SEL     : out std_ulogic;
      SHIFT   : out std_ulogic;
      TCK     : out std_ulogic;
      TDI     : out std_ulogic;
      TMS     : out std_ulogic;
      UPDATE  : out std_ulogic;
      TDO     : in  std_ulogic);
  end component;

  component uart_fifo
    port (
      rst    : in  std_logic;
      wr_clk : in  std_logic;
      rd_clk : in  std_logic;
      din    : in  std_logic_vector(7 downto 0);
      wr_en  : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(7 downto 0);
      full   : out std_logic;
      empty  : out std_logic
      );
  end component;

  signal in_fifo_wr, in_fifo_full, in_fifo_empty, out_fifo_rd, out_fifo_empty, out_fifo_full : std_logic;
  signal in_fifo_din, out_fifo_dout                                                          : std_logic_vector(7 downto 0);

  signal jt_shift, jt_update, jt_tdi, jt_tdo, jt_tck, jt_tms, jt_drck,
    jt_capture, jt_sel, jt_reset : std_ulogic;  -- := '0';

  signal rst_p : std_logic;

  function maximum(L, R : integer) return integer is
  begin
    if L > R then
      return L;
    else
      return R;
    end if;
  end;

  constant DR_SHIFT_LEN : integer                                   := 9;
  -- Register storing the access address and mode (read/write)
  signal dr_shift       : std_logic_vector(DR_SHIFT_LEN-1 downto 0) := (others => '0');

begin

  rst_p <= not rst_n;

  BSCANE2_1 : BSCANE2
    generic map (
      JTAG_CHAIN => 1)
    port map (
      CAPTURE => jt_CAPTURE,
      DRCK    => jt_DRCK,
      RESET   => jt_RESET,
      SEL     => jt_SEL,
      SHIFT   => jt_SHIFT,
      TCK     => jt_TCK,
      TDI     => jt_TDI,
      TMS     => jt_TMS,
      UPDATE  => jt_UPDATE,
      TDO     => jt_TDO);

  -- Generate the read and write strobes
  --out_fifo_rd <= '1' when jt_capture = '1' and jt_sel = '1' and out_fifo_empty='0' else '0';
  -- Generate the write strobe for the external bus - when write_cmd, and this
  -- is the data word
  --in_fifo_wr <= '1' when jt_update = '1' and jt_sel = '1' and
  --              in_fifo_full = '0' and dr_shift(DR_SHIFT_LEN-1) = '1' else '0';

  -- Load and shift data to dr_addr_and_mode register
  pjtag1 : process (jt_tck, jt_reset)
  begin  -- process
    if jt_reset = '1' then
      dr_shift    <= (others => '0');
      out_fifo_rd <= '0';
      in_fifo_wr <= '0';
    elsif jt_tck'event and jt_tck = '1' then  -- falling clock edge - state
      -- defaults
      out_fifo_rd <= '0';
      in_fifo_wr <= '0';
      --
      if jt_sel = '1' then
        if jt_capture = '1' then
          if out_fifo_empty = '0' then
            -- Read the data
            dr_shift(8)          <= '1';
            dr_shift(7 downto 0) <= out_fifo_dout;
            out_fifo_rd          <= '1';
          else
            dr_shift <= (others => '0');
          end if;
        end if;
        if jt_shift = '1' then
          -- Shift the register
          dr_shift(DR_SHIFT_LEN-1) <= jt_tdi;
          for i in 0 to DR_SHIFT_LEN-2 loop
            dr_shift(i) <= dr_shift(i+1);
          end loop;  -- i
        end if;
        if jt_update = '1' then
          if dr_shift(DR_SHIFT_LEN-1) = '1' and in_fifo_full = '0' then
            -- We have received the new byte
            in_fifo_din <= dr_shift(7 downto 0);
            in_fifo_wr <= '1';
          end if;        
        end if;
      end if;
    end if;
  end process pjtag1;

  jt_TDO <= dr_shift(0);

-- Fifos for CDC
  in_fifo : uart_fifo
    port map (
      rst    => rst_p,
      wr_clk => jt_tck,
      rd_clk => clk,
      din    => in_fifo_din,
      wr_en  => in_fifo_wr,
      rd_en  => rd,
      dout   => dout,
      full   => in_fifo_full,
      empty  => in_fifo_empty);

  out_fifo : uart_fifo
    port map (
      rst    => rst_p,
      wr_clk => clk,
      rd_clk => jt_tck,
      din    => din,
      wr_en  => wr,
      rd_en  => out_fifo_rd,
      dout   => out_fifo_dout,
      full   => out_fifo_full,
      empty  => out_fifo_empty);

  rdy <= not out_fifo_full;
  dav <= not in_fifo_empty;

end syn;
