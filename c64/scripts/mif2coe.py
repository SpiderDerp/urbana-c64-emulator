#!/usr/bin/env python3
"""convert altera/quartus .mif memory init files to xilinx .coe and .hex"""

import re
import sys
from pathlib import Path


def parse_mif(path: Path):
    width = depth = None
    radix = 16
    data = {}
    in_data = False
    for line in path.read_text(errors="ignore").splitlines():
        line = line.split("--")[0].strip()
        if not line or line.startswith(";"):
            continue
        m = re.match(r"WIDTH\s*=\s*(\d+)", line, re.I)
        if m:
            width = int(m.group(1))
            continue
        m = re.match(r"DEPTH\s*=\s*(\d+)", line, re.I)
        if m:
            depth = int(m.group(1))
            continue
        m = re.match(r"ADDRESS_RADIX\s*=\s*(\w+)", line, re.I)
        if m:
            radix = {"HEX": 16, "DEC": 10, "BIN": 2, "UNS": 10}[m.group(1).upper()]
            continue
        if line.upper().startswith("CONTENT"):
            in_data = True
            continue
        if not in_data:
            continue
        if ":" in line:
            addr_s, val_s = line.split(":", 1)
            addr_s = addr_s.strip().rstrip(":")
            val_s = val_s.strip().rstrip(";")
            vals = [int(x, radix) for x in val_s.split()]
            if addr_s.startswith("[") and ".." in addr_s:
                lo_s, hi_s = addr_s[1:-1].split("..")
                lo = int(lo_s, radix)
                hi = int(hi_s, radix)
                for i, v in enumerate(vals):
                    data[lo + i] = v
            else:
                addr = int(addr_s, radix)
                if len(vals) == 1:
                    data[addr] = vals[0]
                else:
                    for i, v in enumerate(vals):
                        data[addr + i] = v
    if width is None or depth is None:
        raise ValueError(f"invalid mif: {path}")
    return width, depth, data


def write_coe(path: Path, width: int, depth: int, data: dict):
    mask = (1 << width) - 1
    lines = [
        "memory_initialization_radix=16;",
        "memory_initialization_vector=",
    ]
    vals = []
    for i in range(depth):
        v = data.get(i, 0) & mask
        nibbles = (width + 3) // 4
        vals.append(format(v, f"0{nibbles}X"))
    lines.append(",".join(vals) + ";")
    path.write_text("\n".join(lines) + "\n")


def write_hex(path: Path, width: int, depth: int, data: dict):
    mask = (1 << width) - 1
    nbytes = (width + 7) // 8
    out = []
    for i in range(depth):
        v = data.get(i, 0) & mask
        out.append(format(v, f"0{nbytes * 2}X"))
    path.write_text("\n".join(out) + "\n")


def main():
    if len(sys.argv) < 2:
        print(f"usage: {sys.argv[0]} file.mif [out_dir=../rtl]")
        sys.exit(1)
    src = Path(sys.argv[1])
    out_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else src.parent
    out_dir.mkdir(parents=True, exist_ok=True)
    w, d, data = parse_mif(src)
    stem = src.stem
    write_coe(out_dir / f"{stem}.coe", w, d, data)
    write_hex(out_dir / f"{stem}.hex", w, d, data)
    print(f"wrote {stem}.coe and {stem}.hex ({d} x {w})")


if __name__ == "__main__":
    main()
