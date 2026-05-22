# add c64 emulator sources to vivado project (run from repository root)
# requires project part xc7s50csga324-1 — see c64/ip/urbana_part.tcl

set script_dir [file dirname [info script]]
set repo_root  [file normalize [file join $script_dir ..]]

source [file join $script_dir ip urbana_part.tcl]
puts "urbana part: $URBANA_PART"

set rtl_dir [file join $repo_root c64 rtl]

add_files [glob -nocomplain \
    $repo_root/c64_*.sv \
    $repo_root/c64/*.sv \
    $repo_root/mb_usb_hdmi_top.sv \
    $repo_root/VGA_controller.sv \
    $repo_root/hex_driver.sv]

add_files [glob -nocomplain $rtl_dir/*.vhd $rtl_dir/t65/*.vhd]
add_files [glob -nocomplain $rtl_dir/sid/*.sv]
add_files [glob -nocomplain $rtl_dir/*.sv]

set_property file_type {Memory Initialization Files} [get_files -quiet \
    [glob -nocomplain $repo_root/c64/roms/*.hex $rtl_dir/*.hex]]
set_property file_type {Memory Initialization Files} [get_files -quiet \
    [glob -nocomplain $repo_root/c64/roms/games/*.coe]]

set_property VHDL_VERSION {VHDL-2008} [current_fileset]
