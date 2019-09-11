# ECP5 Toolchain

This repository contains prebuilt versions of all the tools you will need to develop for an ECP5 board.

## Usage

Download the [latest release](https://github.com/xobs/ecp5-toolchain/releases/latest) for your platform and extract it somewhere on your disk.  Then set your PATH:

* MacOS: `export PATH=[path-to-bin]:$PATH`
* Linux: `export PATH=[path-to-bin]:$PATH`
* Windows Powershell: `$ENV:PATH = "[path-to-bin];" + $ENV:PATH`
* Windows cmd.exe: `PATH=[path-to-bin];%PATH%`

To confirm installation, run a command such as `nextpnr-ice40` or `yosys`.

## What's included

This contains _almost_ everything you'll need to develop on Fomu:

* **yosys** -- synthesis
* **nextpnr-ecp5** -- place-and-route
* **dfu-util** -- upload bitstream to the FPGA
* **python3** -- required for `nextpnr-ice40` and to build litex projects
* **riscv-gcc** -- compile code for Risc-V CPUs, such as the Risc-V softcore
* **wishbone-tool** -- access the Wishbone debug bus over USB or SPI

Additionally, the macOS and Windows versions include `make`.

It is strongly recommended that you install `git` to manage repositories and check out code, though it is not strictly necessary.
