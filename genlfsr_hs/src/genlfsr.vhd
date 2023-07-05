library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.genlfsr_pkg.all;

entity genlfsr is
  
  generic (
    width  : integer     := 16;         -- number of bits updated in a single
                                        -- clock cycle (affects the resource consumption!)
    length : integer     := 17;         -- length of the register
    taps   : T_LFSR_TAPS := (17, 14));  -- XORed bits as specified in Xilinx XAPP0

  port (
    rst_n : in  std_logic;
    ena   : in  std_logic;
    clk   : in  std_logic;
    dout  : out std_logic_vector(width-1 downto 0));

end genlfsr;

architecture beh of genlfsr is

  signal reg : std_logic_vector(length-1 downto 0);
  
begin  -- beh

  lfsr1 : process (clk, rst_n)
    variable vreg : std_logic_vector(length-1 downto 0);
    variable fb   : std_logic;
  begin  -- process lfsr1
    if rst_n = '0' then                 -- asynchronous reset (active low)
      reg <= (others => '1');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ena = '1' then
        vreg := reg;
        --for i in 1 to width loop
          fb := '0';
          for j in taps'range loop
            if fb = vreg(taps(j)-1) then
              fb := '0';
            else
              fb := '1';
            end if;
          end loop;  -- j
          for k in vreg'left downto 1 loop
            vreg(k) := vreg(k-1);
          end loop;  -- k
          vreg(0) := fb;
        --end loop;  -- i
        reg <= vreg;
      end if;
    end if;
  end process lfsr1;

  dout <= reg(width-1 downto 0);

end beh;
