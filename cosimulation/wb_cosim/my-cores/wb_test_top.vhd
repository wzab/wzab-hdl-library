-- Code used to implement the emulated bus
-- according to method publicly disclosed by W.M.Zabolotny in 2007 
-- Usenet alt.sources "Bus controller model for VHDL & Python cosimulation"
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.wishbone_pkg.all;
library work;

entity wb_test_top is
  
  generic (
    rdpipename : string  := "rdpipe";
    wrpipename : string  := "wrpipe"
    );

  port (
    rst_i : in std_logic;
    clk_sys_i : in std_logic
    );

end wb_test_top;

architecture simul of wb_test_top is

  constant addrwidth, datawidth : integer := 32;

  signal wb_m_out   : t_wishbone_master_out_array(0 to 0);
  signal wb_m_in  : t_wishbone_master_in_array(0 to 0);
  signal wb_s_out : t_wishbone_slave_out_array(0 to 0);
  signal wb_s_in : t_wishbone_slave_in_array(0 to 0);

  signal rst_n_i : std_logic;
  
begin  -- simul

  rst_n_i <= not rst_i;
  wb_test_slvx_1: entity work.wb_test_slvx
    port map (
      sys_clk_i => clk_sys_i,
      rst_i     => rst_i,
      slv_i     => wb_s_in(0),
      slv_o     => wb_s_out(0));

  sim_wb_ctrl_1: entity work.sim_wb_ctrl
  generic map (
    rdpipename => rdpipename,
    wrpipename => wrpipename)
  port map (
    wb_m_out  => wb_m_out(0),
    wb_m_in   => wb_m_in(0),
    clk_sys_i => clk_sys_i);

  xwb_crossbar_1: entity work.xwb_crossbar
    generic map (
      g_num_masters => 1,
      g_num_slaves  => 1,
      g_registered  => false,
      g_address     => (0=>x"00000000") ,
      g_mask        => (0=>x"00000000"))
    port map (
      clk_sys_i => clk_sys_i,
      rst_n_i   => rst_n_i,
      slave_i   => wb_m_out,
      slave_o   => wb_m_in,
      master_i  => wb_s_out,
      master_o  => wb_s_in,
      sdb_sel_o => open);
  
end simul;
