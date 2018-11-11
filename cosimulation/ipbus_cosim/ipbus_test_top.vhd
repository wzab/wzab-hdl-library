-- Code used to implement the emulated bus
-- according to method publicly disclosed by W.M.Zabolotny in 2007 
-- Usenet alt.sources "Bus controller model for VHDL & Python cosimulation"
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.ipbus.all;
library work;

entity ipbus_test_top is
  
  generic (
    rdpipename : string  := "rdpipe";
    wrpipename : string  := "wrpipe"
    );

  port (
    ipb_rst : in std_logic;
    ipb_clk : in std_logic
    );

end ipbus_test_top;

architecture simul of ipbus_test_top is

  constant addrwidth, datawidth : integer := 32;

  signal ipb_master_out   : ipb_wbus;
  signal ipb_master_in  : ipb_rbus;
  signal in_val1  : unsigned(3 downto 0);
  signal in_val2  : unsigned(7 downto 0);
  signal in_val3  : unsigned(31 downto 0);
  signal out_val1 : unsigned(15 downto 0);
  signal out_val2 : unsigned(7 downto 0);
  signal out_val3 : unsigned(31 downto 0);

begin  -- simul

  slaves_1: entity work.slaves
    port map (
      ipb_clk  => ipb_clk,
      ipb_rst  => ipb_rst,
      ipb_in   => ipb_master_out,
      ipb_out  => ipb_master_in,
      in_val1  => in_val1,
      in_val2  => in_val2,
      in_val3  => in_val3,
      out_val1 => out_val1,
      out_val2 => out_val2,
      out_val3 => out_val3);

  in_val1 <= x"a";
  in_val2 <= out_val2;
  in_val3 <= out_val3 + out_val1;

  ipbus_ctrl_1: entity work.ipbus_ctrl
    generic map (
      rdpipename => rdpipename,
      wrpipename => wrpipename)
    port map (
      ipb_out => ipb_master_out,
      ipb_in  => ipb_master_in,
      ipb_clk => ipb_clk);

end simul;
