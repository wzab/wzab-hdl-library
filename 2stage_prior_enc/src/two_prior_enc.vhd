-------------------------------------------------------------------------------
-- Title      : Two stage priority encoder with two-phase operation
-- Author     : Wojciech M. Zabolotny ( wza...@gmail.com )
-- Description: This blocks outputs numbers of the first input with '1'
-- Copyright (c) 2016
-- License    : Public domain or Creative Commons CC0
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.math_real.all;
library work;

entity two_prior_enc is
  generic(
    N_INPUTS   : integer := 32;         -- Number of inputs
    N_1ST_BITS : integer := 3           -- Number of bits in the 1st stage
    );
  port (inputs : in  std_logic_vector (N_INPUTS-1 downto 0);
        first  : out integer range 0 to N_INPUTS-1 := 0;
        found  : out std_logic;
        clk    : in  std_logic;
        rst_p  : in  std_logic);
end two_prior_enc;

architecture rtl1 of two_prior_enc is
  constant N_INS_1st : integer := 2**N_1ST_BITS;  -- Number of inputs in the 1st stage
  constant N_BLKS    : integer := (N_INPUTS+N_INS_1st-1)/N_INS_1st;
  constant N_BITS    : integer := integer(ceil(log2(real(N_INPUTS-1))));

  signal founds     : std_logic_vector(N_BLKS-1 downto 0)  := (others => '0');
  type T_CODES is array (0 to N_BLKS-1) of std_logic_vector(N_1ST_BITS-1 downto 0);
  signal codes      : T_CODES                              := (others => (others => '0'));
  signal s_code     : std_logic_vector (N_BITS-1 downto 0) := (others => '0');
  signal inputs_ext : std_logic_vector(N_INPUTS-1 downto 0);

begin

  process (inputs) is
  begin  -- process
    inputs_ext <= (others => '0');
    l1 : for i in 0 to N_INPUTS-1 loop
      inputs_ext(i) <= inputs(i);
    end loop;
  end process;

  g1 : for i in 0 to N_BLKS-1 generate
    -- The first synchronous process on the falling clock edge finds the first
    -- '1' in groups of inputs
    pl1 : process (clk) is
    begin  -- process pl1
      if clk'event and clk = '0' then   -- falling clock edge
        if rst_p = '1' then             -- synchronous reset (active high)
          founds(i) <= '0';
          codes(i)  <= (others => '0');
        else
          founds(i) <= '0';
          codes(i)  <= (others => '0');
          l1 : for j in 0 to 2**N_1ST_BITS-1 loop
            if inputs(i*N_INS_1st+j) = '1' then
              codes(i)  <= std_logic_vector(to_unsigned(j, N_1ST_BITS));
              founds(i) <= '1';
              exit l1;
            end if;
          end loop;  -- j
        end if;
      end if;
    end process pl1;

  end generate g1;

  -- The second process on the rising edge of the clock finds the first group
  -- with found '1' and encodes the number of group/input_in_group
  p1 : process (clk)
    variable icode_v : integer                             := 0;
    variable found_v : std_logic                           := '0';
    variable code_v  : std_logic_vector(N_BITS-1 downto 0) := (others => '0');
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if rst_p = '1' then               -- asynchronous reset (active low)
        s_code <= (others => '0');
        found  <= '0';
      else
        icode_v := 0;
        found_v := '0';
        code_v  := (others => '0');
        l1 : for i in 0 to N_BLKS-1 loop
          if founds(i) = '1' then
            icode_v := i;
            found_v := '1';
            exit l1;
          end if;
        end loop;  -- i
        if found_v = '1' then
          code_v(N_1ST_BITS-1 downto 0)      := codes(icode_v);
          code_v(N_BITS-1 downto N_1ST_BITS) := std_logic_vector(to_unsigned(icode_v, N_BITS-N_1ST_BITS));
          first                              <= to_integer(unsigned(code_v));
          found                              <= '1';
        else
          first <= 0;
          found <= '0';
        end if;
      end if;
    end if;
  end process;

end rtl1;
