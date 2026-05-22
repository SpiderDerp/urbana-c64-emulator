# Vivado IP setup

**Board part:** `xc7s50csga324-1` (Spartan-7, CSGA324). Defined in [`urbana_part.tcl`](urbana_part.tcl).

## clk_wiz_c64

Create the C64 system clock IP before synthesis:

```tcl
source c64/ip/create_clk_wiz_c64.tcl
```

Target output: **31.527956 MHz** on `clk_out1` from **100 MHz** `Clk`.

## Block memory (optional)

`c64_memory.sv` and `c64_fb_bram.sv` use inferred block RAM. To use Xilinx `blk_mem_gen` instead, replace those modules with generated IP and keep port names compatible.

## ROM init files

Add to Vivado **Memory Initialization Files** (or set synthesis `-include_dirs`):

- `c64/rtl/*.hex` — KERNAL/chargen ROM init (`c64_xilinx_rom` / buslogic)
- `c64/roms/games/default_ram.hex` — 64 KB RAM image (`RAM_HEX` in `c64_memory.sv`)

## Source files to add

Add all files under `c64/rtl/` (VHDL + Verilog/SV), plus top-level `c64_*.sv` and `mb_usb_hdmi_top.sv` (or run `c64/add_sources.tcl`).

Set VHDL version to **VHDL-2008** for the project.
