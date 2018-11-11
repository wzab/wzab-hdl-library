-------------------------------------------------------------------------------
-- Title      : WB test slave
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wb_test.vhd
-- Author     : FPGA Developer  <xl@wzab.nasz.dom>
-- Company    : 
-- Created    : 2018-04-16
-- Last update: 2018-11-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: It just allows you to check in simulation if the access is correct
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-07-26  1.0      xl      Created
-------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.wishbone_pkg.all;

entity wb_test_slvx is
  port (
    
    sys_clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    slv_i   : in  t_wishbone_slave_in;
    slv_o : out t_wishbone_slave_out
    );
end wb_test_slvx;


architecture rtl of wb_test_slvx is

  type T_MEM is array (0 to 1023) of std_logic_vector(31 downto 0);
  signal mem         : T_MEM                 := (others => (others => '0'));
  signal tst_counter : unsigned(31 downto 0) := (others => '0');

begin
  -- At the moment we do not generate errors nor stalls
  slv_o.rty   <= '0';
  slv_o.err   <= '0';
  slv_o.stall <= '0';

  process (sys_clk_i) is
    variable v_read : std_logic_vector(31 downto 0);
  begin  -- process
    if sys_clk_i'event and sys_clk_i = '1' then  -- rising clock edge
      if rst_i = '1' then           -- synchronous reset (active high)
        v_read      := (others => '0');
        slv_o.ack   <= '0';
        slv_o.dat   <= (others => '0');
        tst_counter <= (others => '0');
      else
        v_read := (others => '0');
        -- Decrement test counter
        if to_integer(tst_counter) /= 0 then
          tst_counter <= tst_counter - 1;
        end if;
        if(slv_i.stb = '1') then
          slv_o.ack <= '1';
          if slv_i.we = '1' then
            -- Write access
            if slv_i.adr(30) = '0' then
              -- simple memory
              mem(to_integer(unsigned(slv_i.adr(9 downto 0)))) <= slv_i.dat;
            else
              -- counter
              tst_counter <= unsigned(slv_i.dat);
            end if;
          else
            -- Read access
            if slv_i.adr(30) = '0' then
              v_read := mem(to_integer(unsigned(slv_i.adr(9 downto 0))));
              if slv_i.adr(31) = '1' then
                v_read := std_logic_vector(unsigned(v_read)+unsigned(slv_i.adr)+12);
              end if;
            else
              v_read := std_logic_vector(tst_counter);
            end if;
          end if;
        else
          slv_o.ack <= '0';
        end if;
      end if;
      slv_o.dat <= v_read;
    end if;
  end process;

end architecture rtl;

