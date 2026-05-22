# vivado tcl: create clk_wiz_c64 for ~31.527956 mhz from 100mhz input
# run in vivado (project part must be xc7s50csga324-1):
#   source c64/ip/urbana_part.tcl
#   source c64/ip/create_clk_wiz_c64.tcl

source [file join [file dirname [info script]] urbana_part.tcl]

if {![info exists ::current_project]} {
    puts "WARNING: no project open. create/open a vivado project with part $URBANA_PART first."
} else {
    set proj_part [get_property PART [current_project]]
    if { $proj_part ne $URBANA_PART } {
        puts "WARNING: project part is $proj_part (expected $URBANA_PART)"
    }
}

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_c64
set_property -dict [list \
  CONFIG.PRIM_IN_FREQ {100.000} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {31.527956} \
  CONFIG.NUM_OUT_CLK {1} \
  CONFIG.USE_RESET {true} \
  CONFIG.RESET_TYPE {ACTIVE_HIGH} \
  CONFIG.CLKIN1_JITTER_PS {100.0} \
] [get_ips clk_wiz_c64]

generate_target all [get_ips clk_wiz_c64]
puts "clk_wiz_c64 generated for part $URBANA_PART"
