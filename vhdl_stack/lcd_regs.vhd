-------------------------------------------------------------------------------
-- Title      : LCD controller for Spartan 3E Starter Kit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lcd.vhd
-- Author     : Wojciech M. Zabolotny <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2007-12-31
-- Last update: 2007-12-31
-- Platform   : 
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: This is a sample implementation of state machine
-- with "state stack", which allows you to implement often used
-- sequences of states as "subroutines"
-- This implementation uses registers to implement the stack.
-------------------------------------------------------------------------------
-- Copyright (c) 2007
-- This is public domain code!!!
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-12-31  1.0      wzab	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_test is
  
  port (
    led            : out std_logic_vector(7 downto 0);
    lcd            : out std_logic_vector(7 downto 4);
    lcd_rs         : out std_logic;
    lcd_rw         : out std_logic;
    lcd_e          : out std_logic;
    strataflash_oe : out std_logic;
    strataflash_we : out std_logic;
    strataflash_ce : out std_logic;
    sys_clk        : in  std_logic;
    sys_rst        : in  std_logic);

end lcd_test;

architecture beh of lcd_test is

  constant T_CLK : integer := 20;       -- Clock period in ns
  type T_LCD_STATE is (L_START, L_WRITE, L_DELAY, L_INIT0,
                       L_INIT1, L_INIT2, L_INIT3, L_INIT4, L_INIT5, L_INIT6, L_INIT7,
                       L_INIT8, L_INIT9, L_INIT10, L_INIT11, L_INIT12, L_INIT13, L_INIT14, L_INIT15,
                       L_INIT16, L_INIT17, L_INIT18, L_INIT19, L_INIT20, L_INIT21, L_INIT22,
                       L_WRITED, L_WRITED_1, L_WRITED_2, L_WRITED_3, L_WRITED_4,
                       L_WRITE4, L_WRITE4_1, L_WRITE4_2, L_WRITE4_3,
                       L_WRITE8, L_WRITE8_1, L_WRITE8_2);
  constant STACK_DEPTH : integer                        := 7;
  type T_STACK is array (STACK_DEPTH-1 downto 0) of T_LCD_STATE;
  signal stack         : T_STACK;
  signal stack_ptr     : integer range 0 to STACK_DEPTH := 0;
  signal stack_err     : boolean                        := false;
  signal lcd_state     : T_LCD_STATE                    := L_START;
  signal lcd_cmd       : std_logic_vector(7 downto 0);
  signal cnt_del       : integer                        := 0;

  signal main_clk, main_rst, main_rst0 : std_logic := '0';
  
begin  -- beh

  strataflash_ce <= '0';
  strataflash_we <= '1';
  strataflash_oe <= '1';

  main_clk       <= sys_clk;
  led(7)         <= '1' when stack_err else '0';
  process (main_clk, sys_rst)
  begin  -- process
    if sys_rst = '1' then               -- asynchronous reset (active low)
      main_rst  <= '0';
      main_rst0 <= '0';
    elsif main_clk'event and main_clk = '1' then  -- rising clock edge
      main_rst0 <= '1';
      main_rst  <= main_rst0;
    end if;
  end process;

  process (main_clk, sys_rst)

    procedure STK_PUSH (
      constant next_state : in T_LCD_STATE) is
    begin  -- STK_PUSH
      if stack_ptr < STACK_DEPTH then
        stack(stack_ptr) <= next_state;
        stack_ptr        <= stack_ptr + 1;
      else
        stack_err <= true;
      end if;
    end STK_PUSH;

    procedure STK_RET is
    begin  -- stk_pop
      if stack_ptr > 0 then
        lcd_state <= stack(stack_ptr - 1);
        stack_ptr <= stack_ptr - 1;
      else
        stack_err <= true;
      end if;
    end STK_RET;

    procedure STK_CALL (
      constant called_state, ret_state : in T_LCD_STATE) is
    begin  -- STK_CALL
      STK_PUSH(ret_state);
      lcd_state <= called_state;
    end STK_CALL;

    procedure STK_JMP (
      constant called_state : in T_LCD_STATE) is
    begin  -- STK_CALL
      lcd_state <= called_state;
    end STK_JMP;

    procedure STK_DEL (
      constant delay     : in integer;
      constant ret_state : in T_LCD_STATE) is
    begin  -- stk_pop
      cnt_del <= (delay+T_CLK-1) / T_CLK;
      STK_CALL(L_DELAY, ret_state);
    end STK_DEL;
    
    procedure STK_WRITE4 (
      constant value4    : in integer range 0 to 15;
      constant ret_state : in T_LCD_STATE) is
    begin  -- STK_WRITE4
      lcd_rs              <= '0';
      lcd_cmd(7 downto 4) <= std_logic_vector(to_unsigned(value4, 4));
      STK_CALL(L_WRITE4, ret_state);
    end STK_WRITE4;
    
    procedure STK_WRITE8 (
      constant value8    : in integer range 0 to 255;
      constant ret_state : in T_LCD_STATE) is
    begin  -- STK_WRITE8
      lcd_rs              <= '0';
      lcd_cmd(7 downto 0) <= std_logic_vector(to_unsigned(value8, 8));
      STK_CALL(L_WRITE8, ret_state);
    end STK_WRITE8;

    procedure STK_WRITED (
      constant value8    : in integer range 0 to 255;
      constant ret_state : in T_LCD_STATE) is
    begin  -- STK_WRITED
      lcd_rs              <= '1';
      lcd_cmd(7 downto 0) <= std_logic_vector(to_unsigned(value8, 8));
      STK_CALL(L_WRITED, ret_state);
    end STK_WRITED;

    procedure INIT is
    begin  -- INIT
      lcd_rw          <= '0';
      lcd_e           <= '0';
      lcd             <= (others => '0');
      lcd_state       <= L_START;
      led(6 downto 0) <= (others => '0');
      stack_err       <= false;
      stack_ptr       <= 0;
      cnt_del         <= 0;
    end INIT;
    
  begin  -- process
    if sys_rst = '1' then               -- asynchronous reset (active low)
      INIT;
    elsif main_clk'event and main_clk = '1' then  -- rising clock edge
      if main_rst = '0' then
        INIT;
      else
        led(6 downto 4) <= std_logic_vector(to_unsigned(stack_ptr,3));
        case lcd_state is
          when L_START =>
            STK_DEL(16_000_000, L_INIT0);
            -- Subroutine DELAY
          when L_INIT0 =>
            led(0) <= '1';
            STK_WRITE4(16#3#, L_INIT1);
          when L_INIT1 =>
            STK_DEL(4_200_000, L_INIT2);
          when L_INIT2 =>
            STK_WRITE4(16#3#, L_INIT3);
          when L_INIT3 =>
            STK_DEL(110_000, L_INIT4);
          when L_INIT4 =>
            STK_WRITE4(16#3#, L_INIT5);
          when L_INIT5 =>
            STK_DEL(41_000, L_INIT6);
          when L_INIT6 =>
            STK_WRITE4(16#2#, L_INIT7);
          when L_INIT7 =>
            STK_DEL(41_000, L_INIT8);
          when L_INIT8 =>
            STK_WRITE8(16#28#, L_INIT9);
          when L_INIT9 =>
            STK_DEL(41_000, L_INIT10);
          when L_INIT10 =>
            STK_WRITE8(16#06#, L_INIT11);
          when L_INIT11 =>
            STK_DEL(41_000, L_INIT12);
          when L_INIT12 =>
            STK_WRITE8(16#0C#, L_INIT13);
          when L_INIT13 =>
            STK_DEL(41_000, L_INIT14);
          when L_INIT14 =>
            STK_WRITE8(16#01#, L_INIT15);
          when L_INIT15 =>
            STK_DEL(1_750_000, L_INIT16);
          when L_INIT16 =>
            STK_WRITED(16#45#, L_INIT17);
          when L_INIT17 =>
            STK_WRITED(16#46#, L_INIT18);
          when L_INIT18 =>
            STK_WRITED(16#47#, L_INIT19);
          when L_INIT19 =>
            STK_WRITED(16#48#, L_INIT20);
          when L_INIT20 =>
            STK_WRITED(16#49#, L_INIT21);
          when L_INIT21 =>
            STK_DEL(2_000_000_000,L_INIT20);                       -- we stay here forever
          when L_DELAY =>
            if cnt_del = 0 then
              STK_RET;
            else
              cnt_del <= cnt_del-1;
            end if;
            -- Subroutine WRITE4
          when L_WRITE4 =>
            led(3)          <= '1';
            lcd_rw          <= '0';
            lcd(7 downto 4) <= lcd_cmd(7 downto 4);
            STK_DEL(60, L_WRITE4_1);
          when L_WRITE4_1 =>
            lcd_e <= '1';
            STK_DEL(250, L_WRITE4_2);
          when L_WRITE4_2 =>
            lcd_e <= '0';
            STK_DEL(20, L_WRITE4_3);
          when L_WRITE4_3 =>
            led(3) <= '0';
            STK_RET;
            -- Subroutine WRITE8
          when L_WRITE8 =>
            led(2) <= '1';
            STK_CALL(L_WRITE4, L_WRITE8_1);
          when L_WRITE8_1 =>
            STK_DEL(1_000, L_WRITE8_2);
          when L_WRITE8_2 =>
            lcd_cmd(7 downto 4) <= lcd_cmd(3 downto 0);
            led(2)              <= '0';
            STK_JMP(L_WRITE4);
            -- Subroutine WRITED
          when L_WRITED =>
            led(1) <= '1';
            STK_CALL(L_WRITE4, L_WRITED_1);
          when L_WRITED_1 =>
            STK_DEL(1_000, L_WRITED_2);
          when L_WRITED_2 =>
            lcd_cmd(7 downto 4) <= lcd_cmd(3 downto 0);
            STK_CALL(L_WRITE4, L_WRITED_3);
          when L_WRITED_3 =>
            STK_DEL(41_000, L_WRITED_4);
          when L_WRITED_4 =>
            --lcd_rs <= '0';
            led(1) <= '0';
            STK_RET;
          when others =>
            STK_JMP(L_INIT0);
        end case;
      end if;
    end if;
  end process;
end beh;
