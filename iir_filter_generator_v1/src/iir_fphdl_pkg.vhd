-- This is PUBLIC DOMAIN code written by Wojciech M. Zabolotny
-- wzab@ise.pw.edu.pl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.fixed_pkg.all;
use work.fixed_prec_pkg.all;            -- defines ibits and fbits

package iir_fp_pkg is

  type T_IIR_COEFFS is array (natural range <>) of sfixed(ibits downto -fbits);
  function maximum (
    left, right : integer)              -- inputs
    return integer;

  function tfs (
    val : real)
    return sfixed;

end iir_fp_pkg;

package body iir_fp_pkg is

  function maximum (
    left, right : integer)              -- inputs
    return integer is
  begin  -- function max
    if left > right then return left;
    else return right;
    end if;
  end function maximum;

  function tfs (
    val : real)
    return sfixed is
  begin
    return to_sfixed(val, ibits, -fbits);
  end function tfs;


end iir_fp_pkg;
