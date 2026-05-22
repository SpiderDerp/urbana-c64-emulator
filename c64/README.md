# C64 emulator (Urbana / xc7s50csga324-1)

Minimal Commodore 64 in FPGA fabric: NTSC VIC-II, KERNAL/BASIC/chargen ROMs, 64 KB RAM, USB keyboard + joystick, HDMI via 640×480 VGA pipeline.

**Target device:** Xilinx Spartan-7 `xc7s50csga324-1` (Urbana board). BRAM budget ~330 KB on this part is sufficient for the full C64 + framebuffer design.

## Vivado bring-up

1. Open your Urbana Vivado project with part **`xc7s50csga324-1`**, or run `source c64/ip/create_project_urbana.tcl` to create `c64_urbana/`.
2. `source c64/ip/create_clk_wiz_c64.tcl`
3. `source c64/add_sources.tcl`
4. Add `pin_assignment/mb_usb_hdmi_top.xdc`
5. Rebuild MicroBlaze app ([`software/lw_usb_main.c`](../software/lw_usb_main.c) — 6 keys + modifiers on GPIO).
6. Synthesize / implement / program.

See [ip/README.md](ip/README.md) and [GAME_LOADING.md](GAME_LOADING.md).

## Architecture

| Clock | Freq | Use |
|-------|------|-----|
| `Clk` | 100 MHz | MicroBlaze, USB |
| `clk_c64` | ~31.53 MHz | 6510, VIC, SID, CIA |
| `clk_25MHz` | 25 MHz | VGA + HDMI pixel |

## Key RTL (new)

| File | Role |
|------|------|
| `c64_top.sv` | Integrates core, RAM, HID, framebuffer, scaler |
| `c64_core_wrapper.sv` | Ties off IEC/cart on `fpga64_sid_iec` |
| `c64_hid_matrix.sv` | USB HID → CIA matrix + joy1 |
| `c64_memory.sv` | 64 KB dual-port RAM |
| `c64_fb_*` | Framebuffer capture + HDMI 2× scale |

## Demo RAM image

`roms/games/minimal_test.coe` — 8-byte ML loop at `$C000` (smoke test for COE flow; use a full snapshot for real games).
