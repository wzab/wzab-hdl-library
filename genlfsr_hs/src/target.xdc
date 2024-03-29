create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports ena]
set_input_delay -clock [get_clocks clk] -max -add_delay 4.000 [get_ports ena]
set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports rst]
set_input_delay -clock [get_clocks clk] -max -add_delay 4.000 [get_ports rst]
set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {dout[*]}]
set_output_delay -clock [get_clocks clk] -max -add_delay 3.000 [get_ports {dout[*]}]

set_property IOSTANDARD LVCMOS33 [get_ports {dout[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dout[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports ena]
set_property IOSTANDARD LVCMOS33 [get_ports rst]




set_property PACKAGE_PIN AB18 [get_ports {dout[15]}]
set_property PACKAGE_PIN U17 [get_ports {dout[14]}]
set_property PACKAGE_PIN U18 [get_ports {dout[13]}]
set_property PACKAGE_PIN P14 [get_ports {dout[12]}]
set_property PACKAGE_PIN R14 [get_ports {dout[11]}]
set_property PACKAGE_PIN R18 [get_ports {dout[10]}]
set_property PACKAGE_PIN T18 [get_ports {dout[9]}]
set_property PACKAGE_PIN N17 [get_ports {dout[8]}]
set_property PACKAGE_PIN P17 [get_ports {dout[7]}]
set_property PACKAGE_PIN P15 [get_ports {dout[6]}]
set_property PACKAGE_PIN R16 [get_ports {dout[5]}]
set_property PACKAGE_PIN N13 [get_ports {dout[4]}]
set_property PACKAGE_PIN N14 [get_ports {dout[3]}]
set_property PACKAGE_PIN P16 [get_ports {dout[2]}]
set_property PACKAGE_PIN R17 [get_ports {dout[1]}]
set_property PACKAGE_PIN N15 [get_ports {dout[0]}]
set_property PACKAGE_PIN U20 [get_ports clk]
set_property PACKAGE_PIN AA18 [get_ports ena]
set_property PACKAGE_PIN W17 [get_ports rst]
