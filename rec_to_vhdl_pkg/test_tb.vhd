-------------------------------------------------------------------------------
-- Title      : Testbench for records & record converters generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : test_tb.vhd
-- Author     : Wojciech Zabolotny
-- Company    : 
-- Created    : 2016-09-21
-- Last update: 2016-09-21
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- License    : PUBLIC DOMAIN or Creative Commons CC0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-09-21  1.0      wzab    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.test_pkg.all;
-------------------------------------------------------------------------------

entity test_tb is

end test_tb;

-------------------------------------------------------------------------------

architecture test1 of test_tb is

  -- signals
  signal din, dout   : test_rec;
  signal test_vec : std_logic_vector(test_rec_width-1 downto 0);

begin  -- test1
  test_vec <= test_rec_to_stlv(din);
  dout <= stlv_to_test_rec(test_vec);
  -- waveform generation
  WaveGen_Proc : process
  begin
    din.nmbr <= to_unsigned(1,6);
    din.flags <= "11010";
    din.srec2.f1 <= '1';
    din.srec2.f2 <="1000";
    din.srec2.f3 <=to_unsigned(4,3);
    din.srec1.p1 <="0101";
    din.srec1.stb <= '1';
    wait for 10 ns;
    din.srec1.stb <= '0';
    wait for 10 ns;
    din.srec2.f2 <= "0111";
    wait for 10 ns;
    din.flags <= "00111";
    din.nmbr <= to_unsigned(2,6);
    wait for 10 ns;
    din.srec1.p1 <= "1100";
    wait for 10 ns;
    din.srec1.stb <= '1';    
    wait;
  end process WaveGen_Proc;


end test1;

