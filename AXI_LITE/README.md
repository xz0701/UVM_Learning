# AXI-Lite UVM Verification Project

## Overview

This project builds a UVM-based verification environment for AXI4-Lite components.
The main purpose of this project is to practice protocol-level verification, reusable UVM agent development, scoreboard modeling, functional coverage, and assertion-based verification.

The RTL DUT is based on the open-source PULP Platform AXI IP library.
This project focuses on building my own verification environment around selected AXI-Lite IP modules.

## Project Goals

* Understand the AXI4-Lite protocol and its five independent channels.
* Build a reusable AXI-Lite UVM agent.
* Verify an open-source AXI-Lite register block.
* Develop constrained-random sequences for read/write transactions.
* Build a scoreboard reference model for register behavior.
* Add functional coverage for protocol and register access scenarios.
* Add protocol assertions for AXI-Lite handshake correctness.
* Extend the environment toward AXI-Lite subsystem verification.

## Repository Structure

```text
AXI_Lite_UVM/
├── README.md
├── rtl/
│   └── axi_lite_regs_wrapper.sv
│
├── tb/
│   ├── axi_lite_if.sv
│   ├── axi_lite_pkg.sv
│   ├── axi_lite_item.sv
│   ├── axi_lite_sequence.sv
│   ├── axi_lite_sequencer.sv
│   ├── axi_lite_driver.sv
│   ├── axi_lite_monitor.sv
│   ├── axi_lite_agent.sv
│   ├── axi_lite_scoreboard.sv
│   ├── axi_lite_coverage.sv
│   ├── axi_lite_env.sv
│   ├── axi_lite_test.sv
│   └── top.sv
│
├── sim/
│   ├── filelist.f
│   ├── Makefile
│   └── run.log
│
└── third_party/
    ├── axi/
    └── common_cells/
```

## Third-Party IP

This project uses open-source RTL from the PULP Platform AXI repository.

* Original repository: `pulp-platform/axi`
* License: `SHL-0.51`
* Used as: RTL DUT for verification practice

This project may also use the PULP `common_cells` repository as a dependency.

* Original repository: `pulp-platform/common_cells`
* Used as: supporting RTL dependency for PULP AXI modules

The third-party RTL files are not authored by me.
My main contribution in this project is the UVM verification environment, including the AXI-Lite agent, sequences, monitor, scoreboard, coverage, assertions, tests, and simulation infrastructure.

## DUT

The first DUT target is:

```text
third_party/axi/src/axi_lite_regs.sv
```

This module implements AXI4-Lite accessible registers with optional read-only and protection features.

A wrapper may be added under `rtl/` to convert between the PULP AXI request/response structure and a standard AXI-Lite signal-level interface used by the UVM testbench.

## AXI-Lite Protocol Scope

This project focuses on AXI4-Lite, including the following channels:

```text
AW channel: write address
W  channel: write data
B  channel: write response
AR channel: read address
R  channel: read data
```

Key protocol behaviors to verify:

* `VALID` must remain asserted until the corresponding `READY` handshake.
* Write response must be generated only after both write address and write data are accepted.
* Read response must be generated after a read address is accepted.
* Read and write channels are independent.
* AXI-Lite supports single-beat transactions only.
* Byte write strobes must update only selected bytes.
* Invalid address accesses should return the expected error response.
* Reset should bring the DUT and verification model back to a clean state.

## Verification Environment

The UVM environment contains:

```text
axi_lite_env
├── axi_lite_agent
│   ├── axi_lite_sequencer
│   ├── axi_lite_driver
│   └── axi_lite_monitor
├── axi_lite_scoreboard
└── axi_lite_coverage
```

### AXI-Lite Item

The transaction item represents one AXI-Lite access:

```systemverilog
class axi_lite_item extends uvm_sequence_item;

    rand bit        is_write;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0]  strb;

    bit [31:0]      rdata;
    bit [1:0]       resp;

endclass
```

### Driver

The driver converts sequence items into AXI-Lite bus activity.

Supported operations:

* AXI-Lite write transaction
* AXI-Lite read transaction
* Back-to-back accesses
* Random delay insertion
* Optional backpressure handling

### Monitor

The monitor observes the AXI-Lite interface and reconstructs bus transactions.

It sends observed transactions to:

* Scoreboard
* Functional coverage collector
* Debug logs

### Scoreboard

The scoreboard maintains a reference register model.

For write transactions:

```text
model[address] = write_data, updated according to WSTRB
```

For read transactions:

```text
expected_data = model[address]
actual_data   = RDATA
compare expected vs actual
```

The scoreboard also checks response correctness for legal and illegal accesses.

### Functional Coverage

Coverage goals include:

* Read access coverage
* Write access coverage
* Address coverage
* Byte strobe coverage
* Response coverage
* Read/write cross coverage
* Back-to-back transaction coverage
* Reset scenario coverage

Example coverage points:

```text
coverpoint addr
coverpoint is_write
coverpoint strb
coverpoint resp
cross addr, is_write
cross is_write, strb
```

### Assertions

Planned protocol assertions:

* `AWVALID` remains stable until `AWREADY`
* `WVALID` remains stable until `WREADY`
* `ARVALID` remains stable until `ARREADY`
* `BVALID` remains stable until `BREADY`
* `RVALID` remains stable until `RREADY`
* No unknown values on valid bus transactions
* Reset clears valid outputs
* Write response occurs only after write address and write data are accepted

## Test Plan

### Directed Tests

* Reset test
* Basic write/read test
* Multiple register write/read test
* Byte strobe write test
* Invalid address test
* Back-to-back write test
* Back-to-back read test
* Read-after-write test

### Random Tests

* Random read/write sequence
* Random address sequence
* Random data sequence
* Random byte strobe sequence
* Random delay and backpressure sequence

### Corner Cases

* Write address arrives before write data
* Write data arrives before write address
* Read and write happen close together
* Reset during transaction
* Access to unmapped address
* Partial byte write followed by full read
* Consecutive accesses to the same register
* Consecutive accesses to different registers

## Simulation

Example simulation flow:

```bash
cd sim
make clean
make run
```

The filelist should include:

```text
+incdir+../third_party/axi/include
+incdir+../third_party/common_cells/include

../third_party/axi/src/axi_pkg.sv
../third_party/axi/src/axi_intf.sv
../third_party/axi/src/axi_lite_regs.sv

../rtl/axi_lite_regs_wrapper.sv

../tb/axi_lite_if.sv
../tb/axi_lite_pkg.sv
../tb/top.sv
```

Additional files from `common_cells` may be required depending on the selected DUT and compile errors.

## Current Project Stage

* [ ] Clone third-party AXI IP
* [ ] Clone third-party common_cells dependency
* [ ] Compile selected AXI-Lite DUT
* [ ] Create AXI-Lite signal-level interface
* [ ] Create DUT wrapper if needed
* [ ] Bring up simple non-UVM directed test
* [ ] Build UVM transaction item
* [ ] Build UVM master driver
* [ ] Build UVM monitor
* [ ] Build scoreboard
* [ ] Add directed UVM tests
* [ ] Add constrained-random tests
* [ ] Add functional coverage
* [ ] Add protocol assertions
* [ ] Run regression
* [ ] Generate coverage report

## Future Extensions

After verifying a single AXI-Lite register block, this project can be extended to:

```text
AXI-Lite master agent
AXI-Lite slave agent
AXI-Lite xbar verification
Multiple AXI-Lite slaves
Address decoding and routing verification
AXI-Lite controlled accelerator
Tiny AI accelerator verification
```

Possible next subsystem:

```text
UVM AXI-Lite Master Agent
        |
        v
AXI-Lite Crossbar
   |          |
   v          v
Reg Block 0  Reg Block 1
```

A later accelerator-oriented system may look like:

```text
AXI-Lite Control Registers
        |
        v
Tiny Matrix Multiply Accelerator
        |
        v
Result Registers / SRAM
```

## Resume Description

Possible resume bullet:

```text
Built a UVM-based AXI-Lite verification environment for an open-source AXI-Lite register IP, including reusable master agent, constrained-random sequences, scoreboard reference model, functional coverage, and protocol assertions.
```

Extended version:

```text
Verified an open-source AXI-Lite register subsystem using SystemVerilog UVM, developing reusable AXI-Lite agents, protocol checkers, constrained-random tests, and a register-model-based scoreboard to validate read/write behavior, byte strobes, backpressure, reset, and invalid address responses.
```

## Notes

This project is for learning and portfolio demonstration.
Third-party IP is used only as the DUT/reference design.
All verification components under `tb/`, simulation scripts under `sim/`, and project-specific wrappers under `rtl/` are developed as part of this project.
