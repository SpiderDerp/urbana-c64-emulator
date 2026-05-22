# optional: new vivado project for urbana c64 hdmi top
# vivado -mode batch -source c64/ip/create_project_urbana.tcl

set ip_dir    [file dirname [info script]]
set repo_root [file normalize [file join $ip_dir .. ..]]

source [file join $ip_dir urbana_part.tcl]

set proj_name c64_urbana
set proj_dir  [file join $repo_root $proj_name]

file mkdir $proj_dir
create_project $proj_name $proj_dir -part $URBANA_PART -force

set_property target_language Verilog [current_project]
set_property default_lib xil_defaultlib [current_project]

source [file join $ip_dir create_clk_wiz_c64.tcl]
source [file join $repo_root c64 add_sources.tcl]

add_files -fileset constrs_1 [file join $repo_root pin_assignment mb_usb_hdmi_top.xdc]

set_property top mb_usb_hdmi_top [current_fileset]

puts "project $proj_name created at $proj_dir (part $URBANA_PART)"
