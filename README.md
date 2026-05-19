# 📘 UVM Learning Journey

> 🚀 Self-paced learning project for SystemVerilog & UVM-based Design Verification
> 🎯 Goal: Become an industry-ready DV (Design Verification) engineer

---

## 📌 Overview

This repository documents my journey of learning **SystemVerilog, UVM, Assertions, and Coverage** through hands-on projects.

The focus is on:

* Building reusable **UVM testbenches**
* Understanding **verification methodology**
* Practicing **debugging and coverage-driven verification**
* Simulating real-world DV workflows

---

## 🎯 Learning Goals

* Master **SystemVerilog for verification**
* Build complete **UVM environments from scratch**
* Understand **protocol-level verification (AXI, MIPI, etc.)**
* Develop strong **debugging & waveform analysis skills**
* Learn **coverage-driven verification methodology**

---

## 🧩 Project Structure

```bash
UVM_Projects/
├── ALU/
│   ├── rtl/        # DUT design
│   ├── tb/         # Testbench (SV/UVM)
│   ├── sim/        # Simulation scripts
│   └── scripts/    # VCS Sripts

```

---

## 🔬 Current Progress

#### 🔹 ALU Verification (04/27/2026)

* UVM-based verification environment (driver, monitor, scoreboard)
* Constrained random stimulus generation
* Directed corner-case tesing (zero/one/max)
* Functional checking with scoreboard
* Coverage closure achieved 100%

#### (Ongoing) Stage 2: Sync FIFO Verification

* Sync FIFO corner cases
* Overflow / Underflow detection
* Data integrity checking
* Multi-channel support

---

---

### 🔜 Stage 3: Protocol Verification

* AXI-Lite
* MIPI
* PCIe (concept-level)

---

## 🛠 Tools & Environment

* Simulator: VCS

---

## 📈 What I Focus On

* Writing **clean and readable SV/UVM code**
* Building **scalable verification environments**
* Debugging using **waveforms and logs**
* Understanding **real industry workflows**

---

## 📚 Learning Approach

Instead of only reading theory, this repo emphasizes:

✔ Hands-on implementation
✔ Incremental complexity (ALU → FIFO → Protocols)
✔ Debugging real issues
✔ Writing reusable components

---

## 🚧 Future Work

* Add **coverage collection (functional + code)**
* Integrate **SystemVerilog Assertions (SVA)**
* Build **full UVM agents for protocols**
* Add **performance and stress tests**
* Improve **documentation and diagrams**

---

## 📬 Notes

This is an evolving repository.
Updates will follow my learning progress.

---

## ⭐ If you find this useful

Feel free to ⭐ the repo or share suggestions!
