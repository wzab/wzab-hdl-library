-------------------------------------------------------------------------------
--  The code below is a very simple implementation of the UNI/O controller
--  It was developed to allow reading the MAC address from 11AA02E48T memory,
--  but probably may be used also for other communication with 11AA02EXX chips.
--  The code has been written by Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl
--  or wzab01<at>gmail.com) on 13.06.2019.
--  The code is published as PUBLIC DOMAIN or under Creative Commons CC0
--  1.0 Universal license.
--  There is no warranty of any kind. You use it on your own risk.
--  You also need to make sure that your usage of UNI/O does not violate
--  any related patents.
--
--  The input data:
--  cmd(22 downto 20) - length of the transfer - 1 (including the start header
--                                                  byte)
--  cmd(18 downto 16) - number of the last transmitted byte (after that byte
--                      the controller switches to reception)
--  cmd(15 downto 8)  - device address (0xa0 for 11AA02EXXX)
--  cmd(7 downto 0)   - command to be executed
--  din(31 downto 0)  - bytes to be transfered (least significant byte is sent
--                      first)
--  dout(31)          - repeated busy flag
--  dout(30)          - error flag
--  dout(27 downto 24)- number of the byte at which error (NoSAK) occured
--  dout(23 downto 0) - received bytes (least significant byte is stored first)
--
--  Command is executed after cmd_wr is asserted in idle state
--
--  Examples:
--  To read the status: set cmd to 0x0032a005, status will be available
--                      in bits 7..0 of dout
--  To read the 6 bytes from locations 0xfa to 0xff:
--                      a1) set din to 0x0000fa00, set cmd to 0x0074a003
--                         first three bytes will be stored in dout
--                      a2) set cmd to 0x0052a006
--                         next three bytes will be stored in dout
--  The above may be also done in three steps:
--                      b1) set din to 0x0000fa00, set cmd to 0x0064a003
--                         first two bits will be in bits 7..0 and 15..8 in dout
--                      b2) set cmd to 0x0042a006
--                         next two bytes will be stored in dout
--                      b3) set cmd to 0x0042a006
--                         last two bytes will be stored in dout
--  To enable writing: set cmd to 0x0022a096
--  To write bytes 0x34 and 0x12 starting from address 0:
--                      a1) set din to 0x12340000
--                      a2) set cmd to 0x0066a06c
--  To read the written values:
--                      a1) set din to 0x00000000
--                      a2) set cmd to 0x0074a003
--                      the dout will contain 0x00FF1234 (ff is the not
--                          overwritten contents at position 0x02)
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity unio0 is
  generic (
    clk_freq : integer);
  port (
    -- Ports - to be defined
    clk    : in    std_logic;           --! System clock 
    rst_n  : in    std_logic;           --! reset signal
    busy   : out   std_logic;           --! previous command still executed
    cmd    : in    std_logic_vector(31 downto 0);  --! address, command, direction and length
    cmd_wr : in    std_logic;           --! Write command strobe
    din    : in    std_logic_vector(31 downto 0);  --! data to be sent (bytes 0-2)
    dout   : out   std_logic_vector(31 downto 0);  --! received data (bytes 0-2, and status (byte 3)
    scio   : inout std_logic            -- Serial clock & I/O line
    );

end unio0;


architecture rtl of unio0 is

  type T_STATE is (S_POWERUP, S_IDLE, S_STDB_PULSE, S_HDR_LOW,
                   S_TX_BYTE, S_TX_BYTE_2H, S_MAK, S_MAK_2H,
                   S_SAK, S_SAK_1H, S_SAK_2H,
                   S_RX_BYTE, S_RX_BYTE_2H,
                   S_ERROR);
  signal state                       : T_STATE                       := S_POWERUP;
  signal scio_o, scio_oe             : std_logic                     := '0';
  signal bit_nr                      : integer range 0 to 7;
  signal delay_cnt                   : integer;
  signal byte_nr                     : integer range 0 to 10;
  signal ignore_sak                  : std_logic                     := '0';
  signal s_dout                      : std_logic_vector(31 downto 0) := (others => '0');
  signal byte_to_send, received_byte : std_logic_vector(7 downto 0)  := (others => '0');

  constant c_stdb_pulse_del : integer := clk_freq * 1 / 1000;      -- 1 ms
  constant c_hdr_low_del    : integer := clk_freq * 20 / 1000000;  -- 20 us
  constant c_1_4_bit_del    : integer := clk_freq * 10 / 1000000;  -- 10 us - 25 Kb/s
  constant c_half_bit_del   : integer := 2*c_1_4_bit_del;
  constant c_3_4_bit_del    : integer := 3*c_1_4_bit_del;

  signal cmd_last_byte : integer;
  signal cmd_last_wr   : integer;

  signal s_busy : std_logic := '0';

begin  -- rtl

  cmd_last_wr   <= to_integer(unsigned(cmd(18 downto 16)));
  cmd_last_byte <= to_integer(unsigned(cmd(22 downto 20)));

  scio              <= scio_o when scio_oe = '1' else 'Z';
  dout(31)          <= s_busy;
  dout(30 downto 0) <= s_dout(30 downto 0);
  busy              <= s_busy;

  unio : process (clk, rst_n)
    variable bselect : integer;
  begin  -- process timing
    if clk'event and clk = '1' then     -- rising clock edge
      if rst_n = '0' then
        state <= S_POWERUP;
      -- reset actions
      else
        case state is
          when S_POWERUP =>
            scio_o  <= '0';
            scio_oe <= '1';
            state   <= S_IDLE;
          when S_IDLE =>
            s_busy  <= '0';
            scio_o  <= '0';
            scio_oe <= '1';
            if cmd_wr = '1' then
              s_dout    <= (others => '0');
              s_busy    <= '1';
              scio_o    <= '1';
              scio_oe   <= '1';
              delay_cnt <= c_stdb_pulse_del;
              state     <= S_STDB_PULSE;
            end if;
          when S_STDB_PULSE =>
            if delay_cnt = 0 then
              scio_o    <= '0';
              state     <= S_HDR_LOW;
              delay_cnt <= c_hdr_low_del;
            else
              delay_cnt <= delay_cnt - 1;
            end if;
          when S_HDR_LOW =>
            if delay_cnt = 0 then
              -- Start sending the start_header
              byte_to_send <= "01010101";
              ignore_sak   <= '1';
              byte_nr      <= 0;
              bit_nr       <= 7;
              delay_cnt    <= c_half_bit_del;
              state        <= S_TX_BYTE;
            else
              delay_cnt <= delay_cnt - 1;
            end if;
          -- Sending or receiving the byte
          -- First 3 bytes are always sent (hdr, addr, cmd)
          when S_TX_BYTE =>
            if delay_cnt = 0 then
              delay_cnt <= c_half_bit_del;
              state     <= S_TX_BYTE_2H;
            else
              -- in the first half of the bit we send the negated data
              scio_oe   <= '1';
              scio_o    <= not byte_to_send(7);
              delay_cnt <= delay_cnt - 1;
            end if;
          when S_TX_BYTE_2H =>
            if delay_cnt = 0 then
              -- Check if all bits are sent
              if bit_nr > 0 then
                -- send next bit
                byte_to_send <= byte_to_send(6 downto 0) & '0';
                bit_nr       <= bit_nr - 1;
                delay_cnt    <= c_half_bit_del;
                state        <= S_TX_BYTE;
              else
                -- we need to go through the acknowledge sequence
                delay_cnt <= c_half_bit_del;
                state     <= S_MAK;
              end if;
            else
              delay_cnt <= delay_cnt - 1;
              scio_o    <= byte_to_send(7);
            end if;
          when S_MAK =>
            if delay_cnt = 0 then
              delay_cnt <= c_half_bit_del;
              state     <= S_MAK_2H;
            else
              delay_cnt <= delay_cnt - 1;
              if byte_nr < cmd_last_byte then
                scio_oe <= '1';
                scio_o  <= '0';
              else
                scio_oe <= '1';
                scio_o  <= '1';
              end if;
            end if;
          when S_MAK_2H =>
            if delay_cnt = 0 then
              delay_cnt <= c_1_4_bit_del;
              state     <= S_SAK;
            else
              delay_cnt <= delay_cnt - 1;
              if byte_nr < cmd_last_byte then
                scio_oe <= '1';
                scio_o  <= '1';
              else
                scio_oe <= '1';
                scio_o  <= '0';
              end if;
            end if;
          when S_SAK =>
            if delay_cnt = 0 then
              if ignore_sak = '1' or (scio = '0') then
                -- 1 st half of SAK received or ignored
                delay_cnt <= c_half_bit_del;
                state     <= S_SAK_1H;
              else
                state <= S_ERROR;
              end if;
            else
              delay_cnt <= delay_cnt - 1;
              scio_oe   <= '0';
            end if;
          when S_SAK_1H =>
            if delay_cnt = 0 then
              if ignore_sak = '1' or (scio = '1') then
                -- 2 nd half of SAK received or ignored
                delay_cnt <= c_1_4_bit_del;
                state     <= S_SAK_2H;
              else
                state <= S_ERROR;
              end if;
            else
              delay_cnt <= delay_cnt - 1;
              scio_oe   <= '0';
            end if;
          when S_SAK_2H =>
            if delay_cnt = 0 then
              -- Transmission of the byte is finished
              case byte_nr is
                when 0 =>
                  byte_nr      <= byte_nr + 1;
                  -- Transmit the device address
                  byte_to_send <= cmd(15 downto 8);
                  ignore_sak   <= '0';
                  bit_nr       <= 7;
                  delay_cnt    <= c_half_bit_del;
                  state        <= S_TX_BYTE;
                when 1 =>
                  byte_nr      <= byte_nr + 1;
                  -- Transmit the command
                  byte_to_send <= cmd(7 downto 0);
                  ignore_sak   <= '0';
                  bit_nr       <= 7;
                  delay_cnt    <= c_half_bit_del;
                  state        <= S_TX_BYTE;
                when others =>
                  -- Check if the transmission is not finished
                  if byte_nr = cmd_last_byte then
                    scio_oe <= '1';
                    scio_o  <= '0';
                    s_busy  <= '0';
                    state   <= S_IDLE;
                  elsif byte_nr >= cmd_last_wr then
                    byte_nr    <= byte_nr + 1;
                    -- That byte must be received, not sent
                    delay_cnt  <= c_3_4_bit_del;
                    ignore_sak <= '0';
                    bit_nr     <= 7;
                    state      <= S_RX_BYTE;
                  else
                    byte_nr      <= byte_nr + 1;
                    -- Transmit the next byte.
                    bselect      := (byte_nr-2)*8;
                    byte_to_send <= din((bselect+7) downto bselect);
                    ignore_sak   <= '0';
                    bit_nr       <= 7;
                    delay_cnt    <= c_half_bit_del;
                    state        <= S_TX_BYTE;
                  end if;
              end case;
            else
              delay_cnt <= delay_cnt - 1;
            end if;
          when S_RX_BYTE =>
            if delay_cnt = 0 then
              -- Read the bit
              received_byte <= received_byte(6 downto 0) & scio;
              delay_cnt     <= c_1_4_bit_del;
              state         <= S_RX_BYTE_2H;
            else
              scio_oe   <= '0';
              delay_cnt <= delay_cnt - 1;
            end if;
          when S_RX_BYTE_2H =>
            if delay_cnt = 0 then
              if bit_nr = 0 then
                -- It was the last bit, so store the byte and go to ACK
                bselect                            := (byte_nr-cmd_last_wr-1)*8;
                s_dout((bselect+7) downto bselect) <= received_byte;
                delay_cnt                          <= c_half_bit_del;
                state                              <= S_MAK;
              else
                -- Receive the next bit
                bit_nr    <= bit_nr - 1;
                delay_cnt <= c_3_4_bit_del;
                state     <= S_RX_BYTE;
              end if;
            else
              delay_cnt <= delay_cnt - 1;
            end if;
          when S_ERROR =>
            -- Here we should handle the transmission error
            s_dout(30)           <= '1';
            s_dout(27 downto 24) <= std_logic_vector(to_unsigned(byte_nr, 4));
            s_busy               <= '0';
            scio_o               <= '0';
            scio_oe              <= '1';
            state                <= S_IDLE;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process unio;

end rtl;
