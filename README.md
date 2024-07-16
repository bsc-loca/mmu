# Memory Management Unit (MMU)

This repository includes a Translation Lookaside Buffer (TLB) and a Page Table Walker, both forming a Memory Management Unit. The modules are designed to be used in a RISC-V processor, following the page-based 39-bit Virtual-Memory System specification (SV39).

<p align="center">
	<img src="./doc/block_diagram.png" alt="block" width="400"/> 
</p>

#### - TLB characteristics:
- Page-based SV39 mode by default
- Virtual Address (39-bit) to Physical Address (56-bit) translation
- TLB entries are parametrizable (8 by default) in includes/mmu_pkg.sv
- Checks Access Permissions
- Raises Page Fault Exceptions

#### - PTW characteristics:
- Support for kilo (4KB), mega (2MB) and giga (1GB) page-size
- 3 level tree hierarchy   
- Mealy FSM following the steps mentioned in the "Virtual Address Translation Process" chapter (4.3.2) of the [RISC-V privileged specs](https://riscv.org/technical/specifications/):

<p align="center">
	<img src="./doc/PTW_fsm.png" alt="block" width="400"/> 
</p>

## Directory Structure
The top-level directories of this repo:
* **hw**: Source code used by MMU.
* **target**: Auto-generated QuestaSim project.

## Tools Used
- QuestaSim >= 2022.3 

## Building
To build different parts of MMU, run make followed by these targets:

- hw-all: generated hardware.
- sim-all: scripts and external models for simulation.
- run_sim: compiles and launches a simulation without gui

## Simulation
After building MMU, start QuestaSim in target/sim/vsim and run:

      # Compile design
      source compile.mmu.tcl

      # Start and run simulation
      source start_mmu.tcl
      run -all
