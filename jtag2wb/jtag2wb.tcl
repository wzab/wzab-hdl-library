# Script prepared by Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl or
# wzab01<at>gmail.com) to drive the jtag2wb.vhd Wishbone controller.
# This code is published as PUBLIC DOMAIN or under Creative Commons
# CC0 license.

# Set two constants below according to the address and data width
# in the instantiated controller
set d_width 32
set a_width 32

set ad_width [ expr max($d_width, $a_width)]
set s_width [ expr $ad_width + 2 ]
set a_mask [ expr ( 1 << $a_width) - 1 ]
set d_mask [ expr ( 1 << $d_width) - 1 ]

proc bus_init { } {
    close_hw
    catch open_hw
    catch {connect_hw_server -url localhost:3121}
    # You may need to adjust the lines below!
    #set JTAG */xilinx_tcf/Xilinx/*
    set JTAG */Digilent/*
    current_hw_target [get_hw_targets $JTAG]
    open_hw_target -jtag_mode 1
    get_hw_devices
    run_state_hw_jtag reset
    run_state_hw_jtag idle
    # The length of the shift should correspond to the length of the instruction register of your FPGA
    # The shifted value should correspond to the USER command, that selects
    # your BSCANE2 as the data register
    scan_ir_hw_jtag 6 -tdi 02
}

proc bus_write { address value } {
    global ad_width
    global s_width
    global a_mask
    global d_mask
    set shval [ expr ( 3 << $ad_width ) | ( $address & $a_mask ) ]
    scan_dr_hw_jtag $s_width -tdi [format %x $shval]
    set shval [ expr ( 1 << $ad_width ) | ( $value & $d_mask ) ]
    scan_dr_hw_jtag $s_width -tdi [format %x $shval]    
    #wait for operation to be completed
    while { true } {
      set shval [ scan_dr_hw_jtag $s_width -tdi 0x0 ]
      set shval [expr 0x$shval ]
      if { $shval & 0x200000000 } break 
    }
    if { $shval & 0x100000000 } {
      puts OK
    } else {
      puts ERROR
    }
    #puts [format %x $shval]
}

proc bus_read { address } {
    global ad_width
    global s_width
    global a_mask
    global d_mask
    set shval [ expr ( 2 << $ad_width ) | ( $address & $a_mask ) ]
    scan_dr_hw_jtag $s_width -tdi [format %x $shval]
    while { true } {
       set shval [ scan_dr_hw_jtag $s_width -tdi 0x0 ]
       set shval [expr 0x$shval ]
       #puts [format %x $shval]    
       if { $shval & 0x200000000 } break 
    }
    if { $shval & 0x100000000 } {
      puts OK
    } else {
      puts ERROR
    }
    return [expr $shval & $d_mask]
}

