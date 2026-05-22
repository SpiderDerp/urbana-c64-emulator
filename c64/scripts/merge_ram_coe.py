#!/usr/bin/env python3
"""merge 64kb ram template with prg fragment into vivado .coe"""

import re
import sys
from pathlib import Path


def load_fragment(path: Path):
    load_addr = 0
    entries = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if line.startswith("@LOAD_ADDR"):
            load_addr = int(line.split()[1], 0)
        elif line.startswith("@LENGTH"):
            pass
        elif ":" in line:
            addr_s, val_s = line.split(":", 1)
            entries[int(addr_s, 16)] = int(val_s, 16)
    return entries


def write_ram_coe(path: Path, mem: list):
    lines = [
        "memory_initialization_radix=16;",
        "memory_initialization_vector=",
    ]
    lines.append(",".join(f"{b:02X}" for b in mem) + ";")
    path.write_text("\n".join(lines) + "\n")


def main():
    if len(sys.argv) < 3:
        print(f"usage: {sys.argv[0]} [fragment.hex ...] out.coe")
        sys.exit(1)
    *frags, out = sys.argv[1:]
    mem = [0] * 65536
    for f in frags:
        for addr, val in load_fragment(Path(f)).items():
            if addr < 65536:
                mem[addr] = val & 0xFF
    write_ram_coe(Path(out), mem)
    print(f"wrote {out} ({sum(1 for x in mem if x)} non-zero bytes)")


if __name__ == "__main__":
    main()
