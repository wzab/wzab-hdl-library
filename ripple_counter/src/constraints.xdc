set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports rd_clk]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_a[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {count_b[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports rst]
set_property IOSTANDARD LVCMOS18 [get_ports sel]
create_clock -period 2.000 -name clk -waveform {0.000 1.000} [get_ports clk]
create_clock -period 25.000 -name rd_clk -waveform {0.000 12.500} [get_ports rd_clk]
set_output_delay -clock [get_clocks rd_clk] -min -add_delay -5.000 [get_ports {count_a[*]}]
set_output_delay -clock [get_clocks rd_clk] -max -add_delay 1.000 [get_ports {count_a[*]}]
set_output_delay -clock [get_clocks rd_clk] -min -add_delay 0.000 [get_ports {count_b[*]}]
set_output_delay -clock [get_clocks rd_clk] -max -add_delay 1.000 [get_ports {count_b[*]}]

set_property PACKAGE_PIN R4 [get_ports clk]
set_property PACKAGE_PIN T5 [get_ports rd_clk]
set_property PACKAGE_PIN R2 [get_ports rst]
set_property PACKAGE_PIN R3 [get_ports sel]
set_property PACKAGE_PIN T1 [get_ports {count_a[7]}]
set_property PACKAGE_PIN W1 [get_ports {count_a[5]}]
set_property PACKAGE_PIN Y1 [get_ports {count_a[4]}]
set_property PACKAGE_PIN AA1 [get_ports {count_a[3]}]
set_property PACKAGE_PIN AB1 [get_ports {count_a[2]}]
set_property PACKAGE_PIN U2 [get_ports {count_a[0]}]
set_property PACKAGE_PIN T3 [get_ports {count_b[7]}]
set_property PACKAGE_PIN U3 [get_ports {count_b[6]}]
set_property PACKAGE_PIN Y2 [get_ports {count_b[3]}]
set_property PACKAGE_PIN Y3 [get_ports {count_b[2]}]
set_false_path -from [get_ports rst] -to [all_registers]
set_false_path -from [get_ports sel] -to [all_registers]
set_false_path -from [get_ports ena] -to [all_registers]
#set_max_delay -datapath_only -from [get_clocks clk_a*] -to [get_ports count_a*] 100.000
#set_max_delay -datapath_only -from [get_clocks clk_b*] -to [get_ports count_b*] 100.000
set_max_delay -datapath_only -from [get_pins *clk_a*_reg*/Q] -to [get_pins count_a*_reg*/D] 15.000
set_max_delay -datapath_only -from [get_pins *clk_b*_reg*/Q] -to [get_pins count_b*_reg*/D] 15.000
set_property PACKAGE_PIN U1 [get_ports {count_a[6]}]
set_property PACKAGE_PIN V2 [get_ports {count_a[1]}]
set_property PACKAGE_PIN AA3 [get_ports {count_b[5]}]
set_property PACKAGE_PIN AB3 [get_ports {count_b[4]}]
set_property PACKAGE_PIN W2 [get_ports {count_b[1]}]
set_property PACKAGE_PIN AB2 [get_ports {count_b[0]}]

set_property PACKAGE_PIN V4 [get_ports ena]

set_property IOSTANDARD LVCMOS18 [get_ports ena]

create_generated_clock -name {clk_a[1]} -source [get_ports clk] -divide_by 2 [get_pins {gen_ff[0].clk_a_reg[1]/Q}]
create_generated_clock -name {clk_a[2]} -source [get_pins {gen_ff[0].clk_a_reg[1]/Q}] -divide_by 2 [get_pins {gen_ff[1].clk_a_reg[2]/Q}]
create_generated_clock -name {clk_a[3]} -source [get_pins {gen_ff[1].clk_a_reg[2]/Q}] -divide_by 2 [get_pins {gen_ff[2].clk_a_reg[3]/Q}]
create_generated_clock -name {clk_a[4]} -source [get_pins {gen_ff[2].clk_a_reg[3]/Q}] -divide_by 2 [get_pins {gen_ff[3].clk_a_reg[4]/Q}]
create_generated_clock -name {clk_a[5]} -source [get_pins {gen_ff[3].clk_a_reg[4]/Q}] -divide_by 2 [get_pins {gen_ff[4].clk_a_reg[5]/Q}]
create_generated_clock -name {clk_a[6]} -source [get_pins {gen_ff[4].clk_a_reg[5]/Q}] -divide_by 2 [get_pins {gen_ff[5].clk_a_reg[6]/Q}]
create_generated_clock -name {clk_a[7]} -source [get_pins {gen_ff[5].clk_a_reg[6]/Q}] -divide_by 2 [get_pins {gen_ff[6].clk_a_reg[7]/Q}]
create_generated_clock -name {clk_b[1]} -source [get_ports clk] -divide_by 2 [get_pins {gen_ff[0].clk_b_reg[1]/Q}]
create_generated_clock -name {clk_b[2]} -source [get_pins {gen_ff[0].clk_b_reg[1]/Q}] -divide_by 2 [get_pins {gen_ff[1].clk_b_reg[2]/Q}]
create_generated_clock -name {clk_b[3]} -source [get_pins {gen_ff[1].clk_b_reg[2]/Q}] -divide_by 2 [get_pins {gen_ff[2].clk_b_reg[3]/Q}]
create_generated_clock -name {clk_b[4]} -source [get_pins {gen_ff[2].clk_b_reg[3]/Q}] -divide_by 2 [get_pins {gen_ff[3].clk_b_reg[4]/Q}]
create_generated_clock -name {clk_b[5]} -source [get_pins {gen_ff[3].clk_b_reg[4]/Q}] -divide_by 2 [get_pins {gen_ff[4].clk_b_reg[5]/Q}]
create_generated_clock -name {clk_b[6]} -source [get_pins {gen_ff[4].clk_b_reg[5]/Q}] -divide_by 2 [get_pins {gen_ff[5].clk_b_reg[6]/Q}]
create_generated_clock -name {clk_b[7]} -source [get_pins {gen_ff[5].clk_b_reg[6]/Q}] -divide_by 2 [get_pins {gen_ff[6].clk_b_reg[7]/Q}]
