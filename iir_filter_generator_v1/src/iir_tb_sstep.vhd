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

entity iir_tb is

end iir_tb;

-------------------------------------------------------------------------------

architecture beh1 of iir_tb is

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

  -- component generics
  file foutp : text is out "output_sstep.txt";
  --Constants below are defined in the octave generated filtdef package
  --constant ibits    : integer := 16;
  --constant fbits    : integer := 20;
  --constant na       : integer := 3;
  --constant nb       : integer := 3;
  --constant a_coeffs : T_IIR_COEFFS(0 to na-1) :=  ( 1.00000,  -1.98981,   0.99980);
  --constant b_coeffs : T_IIR_COEFFS(0 to nb-1) := ( 0.0099907,   0.0000e+00,   0.0000e+00);
  

  -- component ports
  signal in_smp  : sfixed(ibits downto -fbits) := (others => '0');
  signal out_smp : sfixed(ibits downto -fbits);
  signal rst     : std_logic := '0';
  signal dout : signed(15 downto 0);

  signal fin : real;
  signal fout : real;

  signal stime : integer := 0;
  -- clock
  signal Clk : std_logic := '1';

begin  -- beh1

  fin <= to_real(in_smp);
  fout <= to_real(out_smp);
  dout <= to_signed(out_smp * 8192,16);
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

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
    variable l : line;
  begin
    -- insert signal assignments here    
    wait until Clk = '1';
    wait for 105 ns;
    rst <= '1';
    wait until Clk = '1';
    wait until Clk = '0';
    in_smp <= to_sfixed(1.0,ibits,-fbits);
    while true loop
    write(l,fout);
    writeline(foutp,l);
    wait until Clk = '1';
    wait until Clk = '0';
  end loop;
  end process WaveGen_Proc;

  

end beh1;

-------------------------------------------------------------------------------

configuration iir_tb_beh1_cfg of iir_tb is
  for beh1
  end for;
end iir_tb_beh1_cfg;

-------------------------------------------------------------------------------
