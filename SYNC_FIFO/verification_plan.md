# Verification Plan

## 1. DUT Overview

The DUT is a synchronous FIFO with parameterizable data width and depth.
The FIFO supports synchronous write and read operations under a single clock domain.

Main features of the DUT include:

1. Asynchronous active-low reset (`rst_n`) that clears internal states.

2. Write operation when `wr_en` is asserted and the FIFO is not full.

3. Read operation when `rd_en` is asserted and the FIFO is not empty.

4. Full and empty status indication through `full` and `empty` signals.

5. Simultaneous read and write operation support.

---

## 2. Verification Features

| Feature | Description |
|----------|-------------|
| Reset Operation | Verify asynchronous active-low reset behavior |
| Write Operation | Verify correct data write into FIFO |
| Read Operation | Verify correct FIFO read ordering |
| Full Condition | Verify `full assertion and write blocking behavior|
| Empty Condition | Verify `empty assertion and reading blocking behavior|
| Simultaneous R/W | Verify concurrent access |
| FIFO Ordering | Verify first-in first-out data integrity |
| Boundary Conditions | Verify FIFO behavior at empty/full boundaries |

---

## 3. Verification Goals

### Write
- Random write data
- Continuous writes
- Write behavior when FIFO is full
- Counter and pointer update correctness

### Read
- Sequential read ordering
- Read behavior when FIFO is empty
- Counter and poinger update correctness

### Simultaneous Read/Write
- Concurrent accesses
- Occupancy stability

### Reset
- Asynchronus reset
- Reset during traffic
- Pointer and counter reset correctness
- FIFO state recovery after reset

### Boundary Conditions
- empty-to-nonempty transition
- full-to-nonfull transition
- FIFO behavior at depth limits

### Parameter Verification

- Verify FIFO functionality under different WIDTH configurations
- Verify FIFO functionality under different DEPTH configurations
- Verify pointer wrap-around behavior for configurable DEPTH

---

## 4. Checking Mechanism

| Method | Description |
|--------|-------------|
| Scoreboard | Queue-based reference model for FIFO ordering and data integrity checking |
| Assertions | Check reset behavior, full/empty conditions, and illegal read/write operations |
| Functional Coverage | Measure coverage of FIFO operations, status conditions, and boundary scenarios |

---

## 5. Coverage Plan

### Functional Coverage
- write
- empty
- full
- empty
- simultaneous read/write
- wrap-around
- reset
- occupancy

### Cross Coverage
- `wr_en` x `rd_en`
- `full` x `wr_en`
- `empty` x `rd_en`
- `wr_en` x `full` x `rd_en`

---

## 6. Corner Cases

- Write when full
- Read when empty
- Reset during transaction
- Simultaneous read/write at full boundary
- Simultaneous read/write at empty boundary
- Pointer wrap-arround behavior
- Back-to-back write and read operations

---

## 7. Pass Criteria

- No scoreboard mismatch
- No assertion failure
- Functional coverage > 95%
- All planned testcases pass
- No unexpected simulation error or deadlock