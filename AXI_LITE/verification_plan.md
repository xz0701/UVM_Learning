# Verification Plan

## 1. DUT Overview

The DUT is an asynchronous FIFO with parameterizable data width and depth.

The FIFO supports independent write and read operations across two different clock domains:

- Write clock domain: `wr_clk`
- Read clock domain: `rd_clk`

The DUT uses binary pointers, Gray-coded pointers, and two-flop synchronizers to safely transfer pointer information across clock domains.

Main features of the DUT include:

1. Independent asynchronous active-low reset signals:
   - `wr_rstn`
   - `rd_rstn`

2. Write operation when `wr_en` is asserted and the FIFO is not full.

3. Read operation when `rd_en` is asserted and the FIFO is not empty.

4. Full status indication through the `full` signal in the write clock domain.

5. Empty status indication through the `empty` signal in the read clock domain.

6. Dual-port RAM storage with independent write and read clocks.

7. FIFO ordering preservation across asynchronous clock domains.

8. Pointer wrap-around support for power-of-two FIFO depth.

---

## 2. Verification Features

| Feature | Description |
|----------|-------------|
| Write Reset Operation | Verify write-side asynchronous active-low reset behavior |
| Read Reset Operation | Verify read-side asynchronous active-low reset behavior |
| Write Operation | Verify correct accepted write transactions |
| Read Operation | Verify correct FIFO read ordering |
| Full Condition | Verify `full` assertion and write blocking behavior |
| Empty Condition | Verify `empty` assertion and read blocking behavior |
| Asynchronous Clock Operation | Verify FIFO behavior under independent write/read clocks |
| Cross-Domain Synchronization | Verify safe behavior with Gray pointer synchronization |
| FIFO Ordering | Verify first-in first-out data integrity |
| Boundary Conditions | Verify FIFO behavior at empty/full boundaries |
| Pointer Wrap-Around | Verify pointer wrap-around after multiple FIFO cycles |
| Reset During Traffic | Verify reset behavior during active write/read traffic |

---

## 3. Verification Goals

### Write

- Random write data
- Continuous writes
- Write behavior when FIFO is full
- Write pointer update only for accepted write transactions
- Write-side Gray pointer update correctness
- Full flag generation in the write clock domain
- Write behavior when read pointer synchronization is delayed
- Pointer wrap-around on the write side

### Read

- Read data matches the oldest accepted write transaction
- Read behavior when FIFO is empty
- Read pointer update only for accepted read transactions
- Read-side Gray pointer update correctness
- Empty flag generation in the read clock domain
- Read behavior when write pointer synchronization is delayed
- Pointer wrap-around on the read side

### Asynchronous Clock Operation

- Same write and read clock frequency
- Write clock faster than read clock
- Read clock faster than write clock
- Different clock periods with non-aligned edges
- Random write/read traffic under independent clocks
- Long random traffic with many pointer wrap-arounds

### Reset

- Asynchronous write-side reset
- Asynchronous read-side reset
- Reset during write traffic
- Reset during read traffic
- Reset during simultaneous write/read traffic
- Independent reset of one clock domain while the other domain is active
- Pointer and Gray pointer reset correctness
- FIFO state recovery after reset

### Boundary Conditions

- Empty-to-nonempty transition
- Nonempty-to-empty transition
- Nonfull-to-full transition
- Full-to-nonfull transition
- Simultaneous read/write at full boundary
- Simultaneous read/write at empty boundary
- FIFO behavior at depth limits
- Back-to-back write and read operations

### Parameter Verification

- Verify FIFO functionality under different `WIDTH` configurations
- Verify FIFO functionality under different `DEPTH` configurations
- Verify pointer wrap-around behavior for configurable `DEPTH`
- Verify correct operation when `DEPTH` is a power of two

---

## 4. Checking Mechanism

| Method | Description |
|--------|-------------|
| Scoreboard | Queue-based reference model for FIFO ordering and data integrity checking |
| Write Monitor | Samples accepted write transactions and sends them to the scoreboard |
| Read Monitor | Samples valid read data and sends it to the scoreboard |
| Assertions | Check reset behavior, flag behavior, and protocol assumptions |
| Functional Coverage | Measure coverage of FIFO operations, status conditions, boundary cases, and clock scenarios |

---

## 5. Scoreboard Strategy

The scoreboard uses a queue-based reference model to verify FIFO ordering.

Accepted write condition:

```systemverilog
wr_real = wr_en && !full;