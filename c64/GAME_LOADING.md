# Loading C64 games into BRAM

This emulator has **no disk drive**. Games run from a **64 KB RAM image** baked into FPGA block RAM at synthesis time.

## Quick workflow

1. Obtain a game as `.prg` or a **64 KB memory snapshot** (e.g. from VICE after loading the title).
2. Build a RAM COE:
   ```bash
   cd c64/scripts
   python3 prg2coe.py /path/to/game.prg /tmp/game.frag
   python3 merge_ram_coe.py /tmp/game.frag ../roms/games/mygame.coe
   ```
3. Point `c64_memory.sv` parameter `RAM_HEX` at the hex file, or replace `roms/games/default_ram.coe` and regenerate bitstream.
4. Program the Urbana board and use **USB keyboard** + **WASD/Space** as joystick 1.

## Recommended approach for games

**Full RAM snapshot** (easiest for commercial games):

1. In VICE, load the game from disk as you normally would.
2. Save a 64 KB RAM dump (or use a monitor/script to export `$0000–$FFFF`).
3. Convert to COE with `merge_ram_coe.py` after converting binary to fragment format, or use a binary→COE tool.
4. Ensure reset vectors at `$FFFC/$FFFD` point into the game entry point.

## PRG-only (simple homebrew)

```bash
python3 prg2coe.py hello.prg hello.frag
python3 merge_ram_coe.py hello.frag ../roms/games/hello.coe
```

Common load addresses:

| Type | Address |
|------|---------|
| BASIC program | `$0801` |
| Machine language | `$0800`, `$C000`, `$6000` |

BASIC-chain games need **KERNAL + BASIC ROM** enabled (`bios = 2'b01` in `c64_top.sv`).

## Vivado

1. Add `c64/roms/games/<game>.coe` to memory initialization files.
2. Update `RAM_HEX` in `c64_memory.sv` if using `.hex` via `$readmemh`.
3. Re-synthesize and implement.

## Controls (USB HID)

| C64 | USB |
|-----|-----|
| Joystick up/down/left/right | W / S / A / D |
| Fire button | Space |
| Keyboard | Mapped matrix keys (see `c64_hid_matrix.sv`) |

## Example: test pattern (no game)

Default `default_ram.coe` is all zeros — the machine boots KERNAL and shows the BASIC READY prompt after reset. Load a game COE to run titles.

## Example: minimal_test.coe

Built-in smoke-test image (8-byte ML snippet at `$C000`):

```bash
cd c64/scripts
python3 merge_ram_coe.py ../roms/games/minimal_test.frag ../roms/games/minimal_test.coe
```

Point `RAM_HEX` at `minimal_test.hex` (generate from COE) or replace `default_ram.coe` before bitgen. From BASIC after boot: `SYS49152` to enter the test loop (writes `'A'` to screen RAM).
