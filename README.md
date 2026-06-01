# 📘 UVM Learning Journey

> 🚀 Hands-on SystemVerilog & UVM Verification Projects
> 🎯 Goal: Become an industry-ready Design Verification (DV) engineer

---

## 📌 Overview

This repository documents my self-paced learning journey in:

* SystemVerilog
* UVM (Universal Verification Methodology)
* SystemVerilog Assertions (SVA)
* Functional Coverage
* Coverage-Driven Verification
* Regression Automation

The projects focus on building reusable verification environments and practicing industry-style DV workflows through progressively more complex designs.

---

## 🎯 Learning Objectives

* Build reusable UVM verification environments from scratch
* Develop strong debugging and waveform analysis skills
* Understand coverage-driven verification methodology
* Practice assertion-based verification
* Learn protocol-level verification concepts
* Build industry-style regression and verification flows

---

## 🧩 Repository Structure

```text
UVM_Projects/
├── ALU/
│   ├── rtl/
│   ├── tb/
│   ├── sim/
│   └── script/
│
├── Sync_FIFO/
│   ├── rtl/
│   ├── tb/
│   ├── sim/
│   └── script/
│
└── ASYNC_FIFO/
    ├── rtl/
    ├── tb/
    ├── sim/
    ├── script/
    └── run_regression.sh
```

---

# 🔬 Verification Projects

## 🔹 ALU Verification (04/27/2026)

### DUT Features

* Arithmetic and logic operations
* Shift and comparison operations
* Parameterized data width

### Verification Features

* UVM-based verification environment
* Constrained random stimulus generation
* Directed corner-case testing
* Functional coverage collection
* Assertions for ALU behavior verification
* Scoreboard-based functional checking

### Verification Components

* sequence item / transaction
* sequence
* sequencer
* driver
* monitor
* agent
* scoreboard
* environment
* test

### Corner Cases Verified

* Zero operands
* Maximum value operands
* Shift boundary behavior
* Signed comparison behavior

### Verification Results

* Functional coverage closure achieved
* All planned testcases passed
* No scoreboard mismatch or assertion failure

---

## 🔹 Synchronous FIFO Verification (05/23/2026)

### DUT Features

* Parameterized WIDTH and DEPTH
* Active-low reset
* Simultaneous read/write support
* Full/empty flag generation
* Circular buffer architecture

### Verification Features

* Queue-based reference model scoreboard
* Full/empty boundary verification
* Simultaneous read/write corner-case testing
* Assertions for FIFO state correctness
* Functional coverage and scenario coverage
* Parameterized regression testing

### Corner Cases Verified

* Write when full
* Read when empty
* Full + simultaneous read/write
* Empty + simultaneous read/write
* Pointer wrap-around behavior
* Back-to-back read/write operations

### Verification Infrastructure

* UVM environment built from scratch
* Configurable WIDTH/DEPTH regression flow
* Automated regression script
* Log-based PASS/FAIL checking
* Functional coverage collection
* Assertion-based verification

### Verification Results

* Functional coverage closure achieved
* Multi-configuration regression passed
* No scoreboard mismatch or assertion failure

---

## 🔹 Asynchronous FIFO Verification (05/31/2026)

### DUT Features

* Parameterized WIDTH and DEPTH
* Independent write and read clock domains
* Independent asynchronous active-low resets
* Dual-port RAM storage
* Binary pointer and Gray-code pointer architecture
* Two-flop pointer synchronization across clock domains
* Full flag generation in the write clock domain
* Empty flag generation in the read clock domain
* Pointer wrap-around support for power-of-two FIFO depth

### Verification Features

* Dual-agent UVM architecture
* Active write agent and active read agent
* Independent write/read sequences
* Queue-based scoreboard reference model
* Accepted-write based scoreboard update
* Delayed read-data monitor for correct read sampling
* Interface-level SVA checks
* Local write/read functional coverage
* Global FIFO scenario coverage
* Full/empty boundary coverage
* WIDTH/DEPTH parameter regression
* Clock-ratio regression testing

### Verification Components

* write transaction
* read transaction
* write sequence
* read sequence
* write sequencer
* read sequencer
* write driver
* read driver
* write monitor
* read monitor
* write agent
* read agent
* scoreboard
* coverage collector
* environment
* test
* top-level testbench
* regression script

### Corner Cases Verified

* Write when FIFO is full
* Read when FIFO is empty
* Full boundary behavior
* Empty boundary behavior
* Simultaneous read/write
* Full + simultaneous read/write
* Empty + simultaneous read/write
* Write clock faster than read clock
* Read clock faster than write clock
* Same-frequency write/read clocks
* Non-aligned asynchronous clock edges
* Pointer wrap-around after multiple FIFO cycles
* FIFO ordering preservation across clock domains

### Assertions

Interface-level SVA checks were added for:

* No unknown values on write control signals after reset release
* No unknown values on read control signals after reset release
* Read data validity after accepted reads
* Full flag known after write reset release
* Empty flag known after read reset release
* Full reset behavior
* Empty reset behavior

### Functional Coverage

Coverage includes:

* Write enable coverage
* Read enable coverage
* Full flag coverage
* Empty flag coverage
* Write enable × full cross coverage
* Read enable × empty cross coverage
* Write enable × read enable cross coverage
* Full/empty boundary scenario coverage
* Simultaneous read/write coverage

### Regression

Automated regression covers multiple configurations of:

* WIDTH
* DEPTH
* Write clock period
* Read clock period

Example regression cases:

```text
WIDTH=8   DEPTH=4   WR_CLK=10ns RD_CLK=10ns
WIDTH=8   DEPTH=16  WR_CLK=10ns RD_CLK=20ns
WIDTH=16  DEPTH=8   WR_CLK=20ns RD_CLK=10ns
WIDTH=32  DEPTH=16  WR_CLK=10ns RD_CLK=17ns
WIDTH=64  DEPTH=4   WR_CLK=13ns RD_CLK=29ns
```

### Verification Results

* Main functional coverage closure achieved
* Local write/read coverage achieved
* Global boundary coverage achieved
* Multi-configuration regression passed
* Clock-ratio regression passed
* No UVM_ERROR
* No UVM_FATAL
* No scoreboard mismatch
* No assertion failure

---

# 🚧 Ongoing Projects

## 🔹 AXI-Lite Verification (Planned / Next)

### Current Focus

* AXI-Lite protocol understanding
* Address, data, and response channel behavior
* Master/slave handshake verification
* Protocol timing and ordering rules

### Planned Verification Features

* AXI-Lite master agent
* AXI-Lite slave/memory model
* Protocol-aware monitor
* Scoreboard for register read/write checking
* Assertion-based protocol checking
* Functional coverage for channel handshakes and response types
* Directed and random transaction testing

---

## 🔜 Planned Projects

### Protocol Verification

* AXI-Lite
* AXI-Stream
* APB
* UART / SPI
* MIPI concept-level study
* PCIe concept-level study

### Advanced Verification Topics

* Virtual Sequences
* UVM Register Model
* Coverage Closure Flow
* Protocol Assertions
* Formal Verification Basics
* CDC Verification Concepts

---

## 🛠 Tools & Environment

* Simulator: VCS
* Language: SystemVerilog
* Methodology: UVM
* Assertions: SystemVerilog Assertions
* Waveform Debug: Verdi / DVE
* Regression: Makefile + Bash scripts

---

## 📈 Key Focus Areas

* Clean and reusable UVM architecture
* Coverage-driven verification methodology
* Assertion-based verification
* Debugging using logs and waveforms
* Industry-style regression workflows
* Verification planning and coverage closure
* Clock-domain crossing verification concepts

---

## 📚 Learning Philosophy

This repository emphasizes:

* Hands-on implementation
* Incremental complexity growth
* Debugging real verification issues
* Building reusable verification components
* Understanding verification intent instead of only syntax
* Practicing industry-style verification methodology

---

## 📬 Notes

This repository is continuously evolving as I progress through more advanced DV topics and protocol verification projects.

---

## ⭐ Feedback

Suggestions and discussions are always welcome.
