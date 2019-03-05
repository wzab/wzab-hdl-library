# This is the Tcl file providing the read and write 
# procedures for my JTAG to Wishbone bridge
# The implementation is inspired by the help
# for "help_device_dr_shift" from Intel Quartus suite,
# also by my previous post:
# https://groups.google.com/d/msg/alt.sources/Rh5yEuF2YGE/p6UB0RdRS-AJ
# and finally by:
# http://idlelogiclabs.com/2012/04/15/talking-to-the-de0-nano-using-the-virtual-jtag-interface/
#
global programmer_name
global device_name
puts "Programming Hardware:"
foreach hardware_name [get_hardware_names] {
	puts $hardware_name
        #You may need to change the line below to match your hardware
	if { [string match "DE-SoC*" $hardware_name] } {
		set programmer_name $hardware_name
	}
}
puts "\nSelect JTAG chain connected to $programmer_name.\n";
# List all devices on the chain, and select the second device on the chain.
puts "\nDevices on the JTAG chain:"
foreach device_name [get_device_names -hardware_name $programmer_name] {
	puts $device_name
        #You may need to change the line below to select the right FPGA
        #in your hardware
	if { [string match "@2*" $device_name] } {
		set test_device $device_name
	}
}
puts "\nSelect device: $test_device.\n";

# Open device 
open_device -hardware_name $programmer_name -device_name $test_device

set d_width 32
set a_width 32

set ad_width [ expr max($d_width, $a_width)]
set s_width [ expr $ad_width + 2 ]
set a_mask [ expr ( 1 << $a_width) - 1 ]
set d_mask [ expr ( 1 << $d_width) - 1 ]

proc bus_write { address value } {
    global ad_width
    global s_width
    global a_mask
    global d_mask
    set shval [ expr ( 3 << $ad_width ) | ( $address & $a_mask ) ]
    device_virtual_dr_shift -instance_index 0 -length $s_width -dr_value [format %x $shval] -value_in_hex
    set shval [ expr ( 1 << $ad_width ) | ( $value & $d_mask ) ]
    device_virtual_dr_shift -instance_index 0 -length $s_width -dr_value [format %x $shval] -value_in_hex
    #wait for operation to be completed
    while { true } {
      # Length of the constants in lines below should match the "s_width" value.
      set shval [ device_virtual_dr_shift -instance_index 0 -length $s_width -dr_value 000000000 -value_in_hex ]
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
    device_virtual_dr_shift -instance_index 0 -length $s_width -dr_value [format %x $shval] -value_in_hex
    while { true } {
       set shval [ device_virtual_dr_shift -instance_index 0 -length $s_width -dr_value 000000000 -value_in_hex ]
       #puts $shval
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

proc bus_open {} {
  device_lock -timeout 10000
  device_virtual_ir_shift -instance_index 0 -ir_value 1 -no_captured_ir_value
}
proc bus_close {} {
  device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
  device_unlock
}
# Below we perform a few accesses.
# Of course you may also source that file and then work interactively
bus_open
puts [format %x [bus_read 0x01080]]
puts [format %x [bus_read 0x01081]]
puts [format %x [bus_read 0x00]]
puts [format %x [bus_read 0x01]]
bus_write 0x1004 0x123
bus_write 0x1005 0x64
bus_write 0x1006 0x755
bus_write 0x1007 0x897
puts [format %x [bus_read 0x1005]]
puts [format %x [bus_read 0x1007]]
puts [format %x [bus_read 0x1006]]
puts [format %x [bus_read 0x1004]]
bus_close

