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

entity dsp_sys is

  generic (
    ibits    : integer := 7;
    fbits    : integer := 5;
    na       : integer := 3;
    nb       : integer := 3;
    a_coeffs : T_IIR_COEFFS;
    b_coeffs : T_IIR_COEFFS
    );
  port (
    in_smp  : in  sfixed(ibits downto -fbits);
    out_smp : out sfixed(ibits downto -fbits);
    clk     : in  std_logic;
    rst     : in  std_logic
    );

end dsp_sys;

architecture beh of dsp_sys is
  

  constant order  : integer                  := maximum(na, nb);
  type T_DEL_LINE is array (natural range<>) of sfixed(ibits downto -fbits);
  signal del_line : T_DEL_LINE(0 to order-1) := (others => (others => '0'));
  
begin  -- beh

  
  
  process (clk, rst)
    variable s_out_smp : sfixed(ibits downto -fbits) := (others => '0');
    variable tmp, tmp2 : sfixed(ibits downto -fbits);
    variable s         : line;
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      del_line <= (others => (others => '0'));
    elsif clk'event and clk = '0' then  -- rising clock edge
      s_out_smp := resize(del_line(0)+in_smp*b_coeffs(0), ibits, -fbits);
      out_smp   <= s_out_smp;
      for i in 1 to order-1 loop
        tmp := to_sfixed(0.0, ibits, -fbits);
        if i < order-1 then
          tmp := del_line(i);
        end if;
        if i < nb then
          tmp := resize(tmp + in_smp * b_coeffs(i), ibits, -fbits);
        end if;
        if i > 0 and i < na then
          tmp := resize(tmp - s_out_smp * a_coeffs(i), ibits, -fbits);
        end if;
        del_line(i-1) <= tmp;
      end loop;  -- i
    end if;
  end process;
  
end beh;
