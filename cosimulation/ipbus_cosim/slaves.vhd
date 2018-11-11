-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity slaves is
  port(
    ipb_clk           : in  std_logic;
    ipb_rst           : in  std_logic;
    ipb_in            : in  ipb_wbus;
    ipb_out           : out ipb_rbus;
    -- Portd used to communicate with the core
    in_val1            : in unsigned(3 downto 0);
    in_val2 :  in  unsigned(7 downto 0);
    in_val3 :  in  unsigned(31 downto 0);
    out_val1 : out unsigned(15 downto 0);
    out_val2 : out unsigned(7 downto 0);
    out_val3 : out unsigned(31 downto 0)
    );

end slaves;

architecture rtl of slaves is

  constant NSLV             : positive := 2;
  constant N_CTRL            : positive := 2;
  constant N_STAT            : positive := 2;
  signal ipbw               : ipb_wbus_array(NSLV-1 downto 0);
  signal ipbr, ipbr_d       : ipb_rbus_array(NSLV-1 downto 0);
  signal ctrl_reg           : ipb_reg_v(N_CTRL-1 downto 0);
  signal stat_reg           : ipb_reg_v(N_STAT-1 downto 0);

begin

  fabric : entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

  -- slave0
  -- We simply generate error, when an attempt is taken to contact slave0
  ipbr(0).ipb_err <= ipbw(0).ipb_strobe;
  
  slave1 : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => N_CTRL,
      N_STAT => N_STAT)
    port map (
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(1),
      ipbus_out => ipbr(1),
      d         => stat_reg,
      q         => ctrl_reg,
      stb       => open);
-- Assignment of signals
  stat_reg(0)(3 downto 0) <= std_logic_vector(in_val1);
  stat_reg(0)(11 downto 4) <= std_logic_vector(in_val2);
  stat_reg(1) <= std_logic_vector(in_val3);
  out_val1 <= unsigned(ctrl_reg(0)(15 downto 0));
  out_val2 <= unsigned(ctrl_reg(0)(23 downto 16));
  out_val3 <= unsigned(ctrl_reg(1));
end rtl;
