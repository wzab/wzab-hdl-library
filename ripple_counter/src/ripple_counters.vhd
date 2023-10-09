library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity ripple_counters is
  generic (
    width : integer := 8);
  port (
    clk     : in  std_logic;
    rd_clk  : in  std_logic;
    rst     : in  std_logic;
    sel     : in  std_logic;
    ena     : in  std_logic;
    count_a : out std_logic_vector(width-1 downto 0);
    count_b : out std_logic_vector(width-1 downto 0)
    );
end ripple_counters;

architecture beh1 of ripple_counters is

  signal clk_a, clk_b                 : std_logic_vector(width downto 0);
  attribute ASYNC_REG                 : string;
  attribute ASYNC_REG of clk_a, clk_b : signal is "TRUE";

begin

  clk_a(0) <= clk;
  clk_b(0) <= clk;

  gen_ff : for i in 0 to width-1 generate
    process (clk_a(i), rst) is
    begin  -- process
      if rst = '0' then                 -- asynchronous reset (active low)
        clk_a(i+1) <= '0';
      elsif clk_a(i)'event and clk_a(i) = '1' then  -- rising clock edge
        if (i > 0) or (ena='1' and sel='1') then 
          clk_a(i+1) <= not clk_a(i+1);
        end if;
      end if;
    end process;
    process (clk_b(i), rst) is
    begin  -- process
      if rst = '0' then                 -- asynchronous reset (active low)
        clk_b(i+1) <= '0';
      elsif clk_b(i)'event and clk_b(i) = '1' then  -- rising clock edge
        if (i > 0) or (ena='1' and sel='0') then 
            clk_b(i+1) <= not clk_b(i+1);
        end if;
      end if;
    end process;
  end generate gen_ff;

  process (rd_clk) is
  begin  -- process
    if rd_clk'event and rd_clk = '1' then  -- rising clock edge
      count_a <= clk_a(width downto 1);
      count_b <= clk_b(width downto 1);
    end if;
  end process;

end architecture;
