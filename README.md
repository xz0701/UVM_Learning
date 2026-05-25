# 📘 UVM Learning Journey

> 🚀 Hands-on SystemVerilog & UVM Verification Projects  
> 🎯 Goal: Become an industry-ready Design Verification (DV) engineer

---

## 📌 Overview

This repository documents my self-paced learning journey in:

- SystemVerilog
- UVM (Universal Verification Methodology)
- Assertions (SVA)
- Functional Coverage
- Coverage-Driven Verification

The projects focus on building reusable verification environments and practicing real-world DV workflows through progressively more complex designs.

---

## 🎯 Learning Objectives

- Build reusable UVM verification environments
- Develop strong debugging and waveform analysis skills
- Understand coverage-driven verification methodology
- Practice assertion-based verification
- Learn protocol-level verification concepts
- Simulate industry-style regression and verification flows

---

## 🧩 Repository Structure

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

---

# 🔬 Verification Projects

## 🔹 ALU Verification (04/27/2026)

### DUT Features

- Arithmetic and logic operations
- Shift and comparison operations
- Parameterized data width

### Verification Features

- UVM-based verification environment
- Constrained random stimulus generation
- Directed corner-case testing
- Functional coverage collection
- Assertions for ALU behavior verification
- Scoreboard-based functional checking

### Verification Components

- sequence item / transaction
- sequence
- sequencer
- driver
- monitor
- agent
- scoreboard
- environment
- test

### Corner Cases Verified

- Zero operands
- Maximum value operands
- Shift boundary behavior
- Signed comparison behavior

### Verification Results

- Functional coverage closure achieved (100%)
- All planned testcases passed
- No scoreboard mismatch or assertion failure

---

## 🔹 Synchronous FIFO Verification (05/23/2026)

### DUT Features

- Parameterized WIDTH and DEPTH
- Asynchronous active-low reset
- Simultaneous read/write support
- Full/empty flag generation
- Circular buffer architecture

### Verification Features

- Queue-based reference model scoreboard
- Full/empty boundary verification
- Simultaneous read/write corner-case testing
- Assertions for FIFO state correctness
- Functional coverage and scenario coverage
- Parameterized regression testing

### Corner Cases Verified

- Write when full
- Read when empty
- Full + simultaneous read/write
- Empty + simultaneous read/write
- Pointer wrap-around behavior
- Reset during traffic
- Back-to-back read/write operations

### Verification Infrastructure

- UVM environment built from scratch
- Configurable WIDTH/DEPTH regression flow
- Automated regression script
- Log-based PASS/FAIL checking
- Functional coverage collection
- Assertion-based verification

### Verification Results

- Functional coverage closure achieved
- Multi-configuration regression passed
- No scoreboard mismatch or assertion failure


# 🚧 Ongoing Projects

## 🔹 Asynchronous FIFO Verification (In Progress)

### Current Focus

- Dual-clock FIFO architecture
- Gray-code pointer synchronization
- Clock domain crossing (CDC) behavior
- Independent read/write clock generation
- Async reset synchronization

### Planned Verification Features

- Dual-agent UVM architecture
- Independent read/write sequences
- CDC-related assertions
- Full/empty synchronization verification
- Random clock ratio testing
- Parameterized regression flow

---

## 🔜 Planned Projects

### Protocol Verification

- AXI-Lite
- AXI-Stream
- MIPI (concept-level)
- PCIe (concept-level)

### Advanced Verification Topics

- Async FIFO Verification
- Virtual Sequences
- UVM Register Model
- Coverage Closure Flow
- Formal Verification Basics

---

## 🛠 Tools & Environment

- Simulator: VCS
- Language: SystemVerilog
- Methodology: UVM
- Waveform Debug: Verdi / DVE

---

## 📈 Key Focus Areas

- Clean and reusable UVM architecture
- Coverage-driven verification methodology
- Assertion-based verification
- Debugging using logs and waveforms
- Industry-style regression workflows
- Verification planning and coverage closure

---

## 📚 Learning Philosophy

This repository emphasizes:

- Hands-on implementation
- Incremental complexity growth
- Debugging real verification issues
- Building reusable verification components
- Understanding verification intent instead of only syntax

---

## 📬 Notes

This repository is continuously evolving as I progress through more advanced DV topics and protocol verification projects.

---

## ⭐ Feedback

Suggestions and discussions are always welcome.