# Commodore 64 FPGA Emulator (Urbana)

A minimal Commodore 64 implemented in programmable logic on the **Urbana** board (Xilinx Spartan-7). Programs are loaded from block RAM initialization files (`.coe` / `.hex`); the machine boots KERNAL ROM and runs games or demos over **HDMI**, with **USB keyboard** input and joystick emulation on the keyboard.

**Device:** `xc7s50csga324-1`  
**Top module:** [`mb_usb_hdmi_top.sv`](mb_usb_hdmi_top.sv)

## Features

- NTSC VIC-II video (6567-class timing), scaled to **640×480** HDMI
- 6510 CPU, SID, CIA, KERNAL / BASIC / character ROMs
- 64 KB system RAM (BRAM, per-game init image)
- USB HID keyboard → C64 matrix + **port 1 joystick** (WASD + Space)
- MicroBlaze + MAX3421E USB stack (existing ECE 385 lab infrastructure)

## Not included

Save states, disk drives (1541), cartridges, REU, paddles/mouse, PAL mode, and DDR3 are out of scope for this build. Games are provided as **static RAM snapshots** or merged `.prg` images, not loaded from a filesystem at runtime.

## Repository layout

```
├── mb_usb_hdmi_top.sv      # Top-level (USB, HDMI, C64)
├── c64_top.sv              # C64 + video pipeline wrapper
├── c64_*.sv                # Memory, HID, framebuffer, scaler
├── VGA_controller.sv       # 640×480 timing
├── hex_driver.sv           # Debug HEX displays (keycodes)
├── pin_assignment/         # Urbana XDC constraints
├── software/               # MicroBlaze USB keyboard firmware
├── key-reference/          # USB HID scan codes
├── ip-repo/hdmi_tx_1.0/    # RealDigital HDMI encoder IP
├── c64/
│   ├── rtl/                # C64 core (VHDL/SV, MiSTer/FPGA64 lineage)
│   ├── roms/               # KERNAL/chargen COE/HEX + game RAM images
│   ├── scripts/            # mif2coe, prg2coe, merge_ram_coe
│   ├── ip/                 # clk_wiz_c64, Vivado TCL helpers
│   ├── README.md           # Core + Vivado details
│   └── GAME_LOADING.md     # How to build game BRAM images
└── ddr3-stuff/             # Reference only (not used by C64 build)
```

## Quick start (Vivado)

1. Create or open a Vivado project for **`xc7s50csga324-1`** with the ECE 385 **`mb_usb`** block design and **`hdmi_tx`** IP in the project.
2. Add sources and constraints:
   ```tcl
   source c64/add_sources.tcl
   add_files -fileset constrs_1 pin_assignment/mb_usb_hdmi_top.xdc
   set_property top mb_usb_hdmi_top [current_fileset]
   ```
3. Generate the C64 clock IP:
   ```tcl
   source c64/ip/create_clk_wiz_c64.tcl
   ```
   Or create a new project in one step:
   ```tcl
   source c64/ip/create_project_urbana.tcl
   ```
4. Rebuild the MicroBlaze application from [`software/lw_usb_main.c`](software/lw_usb_main.c) (6 keycodes + modifier byte on GPIO).
5. Synthesize, implement, and program the board.

More detail: [`c64/README.md`](c64/README.md), [`c64/ip/README.md`](c64/ip/README.md).

## Controls

| C64 function | USB |
|--------------|-----|
| Joystick 1 up / down / left / right | W / S / A / D |
| Fire button | Space |
| Keyboard | Mapped via [`c64_hid_matrix.sv`](c64_hid_matrix.sv) |

HID codes are defined in [`key-reference/usb_hid_keys.h`](key-reference/usb_hid_keys.h).

## Running programs and games

There is no floppy drive. Bake a **64 KB RAM image** into the bitstream:

```bash
cd c64/scripts
python3 prg2coe.py /path/to/game.prg /tmp/game.frag
python3 merge_ram_coe.py /tmp/game.frag ../roms/games/mygame.coe
```

Then point `c64_memory.sv` at the generated hex file or swap in `c64/roms/games/default_ram.coe` before synthesis.

Full workflow (snapshots, VICE dumps, `SYS` test): [`c64/GAME_LOADING.md`](c64/GAME_LOADING.md).

## Architecture (clocks)

| Clock | Frequency | Domain |
|-------|-----------|--------|
| `Clk` | 100 MHz | MicroBlaze, USB, GPIO |
| `clk_c64` | ~31.53 MHz | 6510, VIC-II, SID, CIA, framebuffer capture |
| `clk_25MHz` / `clk_125MHz` | 25 / 125 MHz | VGA timing and HDMI serialization |

```
USB keyboard → MicroBlaze → GPIO → c64_hid_matrix → C64 core → framebuffer → 2× scaler → VGA → HDMI
```

## Core RTL license

Chip-level sources under [`c64/rtl/`](c64/rtl/) are derived from the [MiSTer C64](https://github.com/mister-devel/C64_MiSTer) / FPGA64 project (GPL). New integration logic (`c64_top`, memory, HID, video glue) is written for the Urbana platform.

## Lab dependencies (not all in this tree)

- Vivado block design **`mb_usb`** (MicroBlaze + USB GPIO + SPI)
- Clock wizard **`clk_wiz_0`** (25 MHz + 125 MHz for HDMI)
- Generated **`hdmi_tx_0`** from [`ip-repo/hdmi_tx_1.0/`](ip-repo/hdmi_tx_1.0/)