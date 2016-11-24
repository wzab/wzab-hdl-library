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

-- nsteps - describes in how many steps we would like to have the results calculated...
-- so the result will be updated every nsteps clocks.
-- We have a clock signal - and clock0 signal which requires all blocks to read
-- the input data. All outputs should be also stable when clock0 is high
-- (so that the next block is able to read the stable data)
  
  generic (
    ibits    : integer := 7;
    fbits    : integer := 5;
    nsteps   : integer := 1;
    na       : integer := 3;
    nb       : integer := 3;
    a_coeffs : T_IIR_COEFFS;
    b_coeffs : T_IIR_COEFFS
    );
  port (
    in_smp  : in  sfixed(ibits downto -fbits);
    out_smp : out sfixed(ibits downto -fbits);
    clk     : in  std_logic;
    clk0    : in  std_logic;
    rst     : in  std_logic
    );

end dsp_sys;

architecture beh of dsp_sys is

-- It is important, that during all update cycle input signal remains stable
  
  constant order : integer := maximum(na, nb);
  -- jmax defines how many results we can calculate simultaneously...
  constant jmax  : integer := (order+(nsteps-1))/nsteps;

  type T_DEL_LINE is array (natural range<>) of sfixed(ibits downto -fbits);
  signal del_line  : T_DEL_LINE(0 to order-2)      := (others => (others => '0'));
  signal s_out_smp : sfixed(ibits downto -fbits)   := (others => '0');
  signal s_in_smp  : sfixed(ibits downto -fbits)   := (others => '0');
  signal step_cnt  : integer range 0 to nsteps     := 0;
  signal first     : integer range -jmax to order := 0;
  signal tmp2      : sfixed(ibits downto -fbits)   := (others => '0');
begin  -- beh

  s_out_smp <= resize(del_line(0)+in_smp*b_coeffs(0), ibits, -fbits);
  out_smp   <= s_out_smp;

  xyz : process (rst, clk)
    variable tmp : sfixed(ibits downto -fbits);
    variable s   : line;
    variable i   : integer;
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      del_line <= (others => (others => '0'));
      step_cnt <= 0;
      first    <= order - 1;
    elsif clk'event and clk = '0' then  -- rising clock edge
      if clk0 = '1' then
        step_cnt <= 0;
        s_in_smp <= in_smp;
        first    <= order - 1;
      elsif step_cnt < nsteps then
        -- To keep the output stable during the whole evaluation, we start from
        -- the last delay
        for j in 1 to jmax loop
          -- We perform jmax cycles, starting from the last delay elements
          -- number of updated node
          i   := first + 1 - j;
          -- we have to remember the previous value of last updated delay
          -- as it is needed in the next cycle
          tmp := to_sfixed(0, ibits, -fbits);
          -- if this is not the first cycle, we need to start from the value of
          -- the previous delay line (in the first cycle for j=1
          -- i = order-1, so this case is eliminated by the next if!)
          if i > 0 and i < order-1 then
            if j = 1 then
              tmp := tmp2;              -- we have to use the previous value
                                        -- of the delay updated as last in the
                                        -- previous cycle
            else
              tmp := del_line(i);
            end if;
          end if;
          if i > 0 and i < nb then
            tmp := resize(tmp + s_in_smp * b_coeffs(i), ibits, -fbits);
          end if;
          if i > 0 and i < na then
            tmp := resize(tmp - s_out_smp * a_coeffs(i), ibits, -fbits);
          end if;
          if i > 0 and i <= order-1 then
            if j = jmax then
              tmp2 <= del_line(i-1);
            end if;
            del_line(i-1) <= tmp;
          end if;
        end loop;  -- i
        if step_cnt < nsteps-1 then
          first <= first-jmax;
        end if;
        step_cnt <= step_cnt+1;
      else
        -- step_cnt = nsteps
        null;  -- don't do anything, just wait for clk0='1'
      end if;
    end if;
  end process;
  
end beh;
