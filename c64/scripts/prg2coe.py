#!/usr/bin/env python3
"""convert c64 .prg (load addr + data) to coe fragment lines for merge_ram_coe.py"""

import struct
import sys
from pathlib import Path


def prg_to_bytes(path: Path):
    raw = path.read_bytes()
    if len(raw) < 2:
        raise ValueError("prg too small")
    load_addr = struct.unpack("<H", raw[0:2])[0]
    return load_addr, raw[2:]


def main():
    if len(sys.argv) < 3:
        print(f"usage: {sys.argv[0]} game.prg out.hex")
        sys.exit(1)
    load, data = prg_to_bytes(Path(sys.argv[1]))
    out = Path(sys.argv[2])
    lines = [f"@LOAD_ADDR {load:#06x}", f"@LENGTH {len(data)}"]
    for i, b in enumerate(data):
        lines.append(f"{load + i:04X}:{b:02X}")
    out.write_text("\n".join(lines) + "\n")
    print(f"load={load:#06x} len={len(data)} -> {out}")


if __name__ == "__main__":
    main()
