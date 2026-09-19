-------------------------------------------------------------------------------
-- Title      : Pseudorandom 32-bit test data generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tst_prng32.vhd
-- Author     : Wojciech Zabolotny  <wzab01@gmail.com>
-- Company    : 
-- Created    : 2026-09-20
-- Last update: 2026-09-20
-- Platform   : 
-- Standard   : VHDL'93/02
-- License    : Creative Commons CC0
-------------------------------------------------------------------------------
-- Description: This block generates pseudorandom test data in each clock cycle.
--              Thanks to use of two LSFRs shifted in opposite directions,
--              and nonlinear cyclic addition, the consecutive output data
--              should be uncorrelated, which should prevent undesired
--              optimalization of further data processing stages.
--              The block may be esily connected to AGWB-generated control
--              registers.
-------------------------------------------------------------------------------
-- Copyright (c) 2026 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2026-09-20  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tst_prng32 is
  port (
    clk_i : in std_logic;
    rst_i : in std_logic;

    load_i   : in std_logic;
    seed_a_i : in std_logic_vector(31 downto 0);
    seed_b_i : in std_logic_vector(31 downto 0);

    random_o : out std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of tst_prng32 is

  signal state_a : unsigned(31 downto 0);
  signal state_b : unsigned(31 downto 0);

  function lfsr_right(
    s : unsigned(31 downto 0)
    ) return unsigned is
    variable r : unsigned(31 downto 0);
  begin

    r := shift_right(s, 1);

    if s(0) = '1' then
      r := r xor unsigned'(x"80000057");
    end if;

    return r;
  end function;


  function lfsr_left(
    s : unsigned(31 downto 0)
    ) return unsigned is
    variable r : unsigned(31 downto 0);
  begin

    r := shift_left(s, 1);

    if s(31) = '1' then
      r := r xor unsigned'(x"8ED00001");
    end if;

    return r;
  end function;


  function rotl11(
    x : unsigned(31 downto 0)
    ) return unsigned is
  begin
    return x(20 downto 0) & x(31 downto 21);
  end function;


  function cyclic_add(
    a : unsigned(31 downto 0);
    b : unsigned(31 downto 0)
    ) return unsigned is
    variable s : unsigned(32 downto 0);
    variable r : unsigned(32 downto 0);
  begin

    s := ('0' & a) + ('0' & b);

    r := ('0' & s(31 downto 0));

    if s(32) = '1' then
      r := r + 1;
    end if;

    return r(31 downto 0);

  end function;

begin

  process(clk_i)
    variable next_a : unsigned(31 downto 0);
    variable next_b : unsigned(31 downto 0);
  begin
    if rising_edge(clk_i) then

      if rst_i = '1' then

        state_a <= x"12345678";
        state_b <= x"87654321";

      elsif load_i = '1' then

        if unsigned(seed_a_i) = 0 then
          state_a <= to_unsigned(1, 32);
        else
          state_a <= unsigned(seed_a_i);
        end if;

        if unsigned(seed_b_i) = 0 then
          state_b <= to_unsigned(1, 32);
        else
          state_b <= unsigned(seed_b_i);
        end if;

      else

        state_a <= lfsr_right(state_a);
        state_b <= lfsr_left(state_b);

      end if;
    end if;
  end process;


  random_o <= std_logic_vector(
    cyclic_add(
      state_a,
      rotl11(state_b)
      )
    );

end architecture;
