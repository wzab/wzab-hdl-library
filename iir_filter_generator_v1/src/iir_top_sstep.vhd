-- This is PUBLIC DOMAIN code written by Wojciech M. Zabolotny
-- wzab@ise.pw.edu.pl

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use std.textio.all;
library work;
use work.fixed_prec_pkg.all;
use work.iir_fp_pkg.all;
use work.filtdef.all;
-------------------------------------------------------------------------------

entity iir_top_sstep is
    port (
      in_smp  : in   sfixed(ibits downto -fbits);
      out_smp : out   sfixed(ibits downto -fbits);
      clk     : in std_logic;
      rst     : in std_logic);
end iir_top_sstep;

-------------------------------------------------------------------------------

architecture beh1 of iir_top_sstep is

  component dsp_sys
    generic (
      ibits    : integer;
      fbits    : integer;
      na       : integer;
      nb       : integer;
      a_coeffs : T_IIR_COEFFS;
      b_coeffs : T_IIR_COEFFS);
    port (
      in_smp  : in   sfixed(ibits downto -fbits);
      out_smp : out   sfixed(ibits downto -fbits);
      clk     : in std_logic;
      rst     : in std_logic);
  end component;

begin  -- beh1

  -- component instantiation
  DUT: dsp_sys
    generic map (
      ibits    => ibits,
      fbits    => fbits,
      na       => na,
      nb       => nb,
      a_coeffs => a_coeffs,
      b_coeffs => b_coeffs)
    port map (
      in_smp  => in_smp,
      out_smp => out_smp,
      clk     => clk,
      rst     => rst);

end beh1;

-------------------------------------------------------------------------------

configuration iir_top_beh1_cfg of iir_top_sstep is
  for beh1
  end for;
end iir_top_beh1_cfg;

-------------------------------------------------------------------------------
