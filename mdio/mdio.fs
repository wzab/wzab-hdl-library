\
\ That code implements simple MDIO clause 22 controller
\ compatible with Swapforth running on James Bowman's J1B CPU 
\ That code is written by Wojciech M. Zabolotny 7.06.2019
\ (wzab<at>ise.pw.edu.pl or wzab01<at>gmail.com)
\ The code is published without any warranty 
\ as PUBLIC DOMAIN or under Creative Commons CC0 1.0 Universal
\ Public Dedication
\
\ The MDIO_REG implements the following functions:
\ bit 0 (RW) - controls or reads the MDIO line
\ bit 1 (WO) - OE for MDIO line, 1 - MDIO is output, 0 - input 
\ bit 2 (WO) - controls the MDC line

$1020 constant MDIO_REG

: mdio_clk ( mdio_reg_val -- mdio_reg_val )
   \ The value on stack contains the data line setting and OE
   \ Set the clock to 0 (it is inverted)
   dup MDIO_REG io!
   \ Set the clock to 1
   dup 4 or MDIO_REG io!
   \ Set the clock to 0
   dup 4 or 4 xor MDIO_REG io!
;

: mdio_setup ( mdio_addr reg_addr -- setup_val_to_send ) 
   \ We prepare the control bits  
   2 lshift 
   swap 7 lshift or
   $4002 or
;

: mdio_sndbit
  ( val_to_send mdio_reg_val -- shifted_val_to_send mdio_reg_val )
   \ The MSB is sent, and the value is shifted
   over $8000 and if
     1 or
   else
     1 or 1 xor
   then
   mdio_clk
   swap 1 lshift swap
;

: mdio_rcvbit
  ( rcvd_val -- shifted_rcvd_val )
   \ The value is shifted and the received bit is stored in bit 0
   1 lshift 
   MDIO_REG io@
   1 and or
   0 mdio_clk drop \ here we assume that the MDIO_REG value should be 0 (adjust to your implementation!)
;


: mdio@ ( mdio_addr reg_addr )
   3 \ MDIO_REG value - send 1s
   $20 0 DO
     mdio_clk
   LOOP
   drop
   mdio_setup
   ( control_bits )
   $2000 or \ modify control bits for READ
   $0002 \ MDIO_REG value - switch on the MDIO as output
   ( setup_val_to_send mdio_reg_val )
   \ Send the first 14 bits with DIO as output
   $0e 0 DO
     mdio_sndbit
   LOOP
   drop
   0 \ MDIO_REG value - switch the MDIO to input
   \ Send the next 2 bits 
   $02 0 DO
     mdio_sndbit
   LOOP
   2drop
   \ Now receive the bits
   0 \ Initialize the received value on stack
   $10 0 DO
     mdio_rcvbit
   LOOP
;

: mdio! ( val mdio_addr reg_addr )
   \ Send the preamble
   3 \ MDIO_REG value - send 1s
   $20 0 DO
     mdio_clk
   LOOP
   drop
   \ Prepare the control bits
   mdio_setup
   $1000 or
   \ Send the setup value
   $0002 \ Switch on the DIO as output
   \ Send 16 bits of setup value
   $10 0 DO
     mdio_sndbit
   LOOP
   \ Discard the values used for setup
   2drop 
   $0002 \ DIO must be used as output
   \ Now send the value
   $10 0 DO
     mdio_sndbit
   LOOP
   2drop
   \ It is not required by the spec, but it seems that one more clock 
   \ pulse is needed to really store the data.
   1 or mdio_sndbit
   $0000 MDIO_REG io! \ Switch off the DIO  
;

