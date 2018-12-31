# Script prepared by Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl)
# to drive the jtag_bus_ctl.vhd core (published in the
# https://groups.google.com/d/msg/alt.sources/Rh5yEuF2YGE/rAzJMOFDNz8J
# thread on alt.sources usenet group
#



proc ju_init { } {
    catch close_hw
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

proc srv_proc {channel clientaddr clientport} {
   puts "Connection from $clientaddr registered"
   fconfigure $channel -blocking 0
   while { true } {
     set char [read $channel 1]
     if {$char ne ""} {
        set code [expr 0x100 | [scan $char %c]]
     } else {
        set code 0
     }
     set shval [scan_dr_hw_jtag 9 -tdi [format %x $code]]
     set shval [expr 0x$shval ]
     if { ( $shval & 0x100 ) > 0} {
       set shval [expr $shval & 0xff]
       puts -nonewline $channel [binary format c* $shval]
       flush $channel
     }
   }
}

ju_init
socket -server srv_proc 9900
vwait forever

