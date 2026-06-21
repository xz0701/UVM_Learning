# Verification Plan: AXI-Lite Register Block

## 1. Project Overview

This verification plan targets the PULP Platform `axi_lite_regs_intf` wrapper from:

```text
third_party/axi/src/axi_lite_regs.sv
```

The DUT is an AXI4-Lite slave register block. The current verification environment drives the DUT through the PULP `AXI_LITE` interface and checks register behavior using a UVM scoreboard, functional coverage, and protocol assertions.

Current v1 focus:

* AXI-Lite master agent bring-up
* Valid aligned read/write access
* Byte strobe behavior
* Invalid low address response
* Read-after-write checking
* AW/W ordering variation
* B/R response backpressure
* Basic AXI-Lite valid/ready stability assertions
* Functional coverage closure for the implemented scenarios

Planned v2 extensions are listed separately in Section 14.

---

## 2. DUT Description

### 2.1 DUT Name

```text
axi_lite_regs_intf
```

### 2.2 DUT Role

The DUT is an AXI4-Lite slave. It receives single-beat AXI-Lite transactions from a master and returns write/read responses.

```text
UVM AXI-Lite Master Agent
        |
        v
PULP AXI_LITE interface
        |
        v
axi_lite_regs_intf DUT
```

### 2.3 Current Parameters

The current testbench configuration is defined in `tb/pkg/axi_lite_pkg.sv`.

| Name | Value | Description |
| ---- | ----- | ----------- |
| `AXI_LITE_ADDR_WIDTH` | 32 | AXI-Lite address width |
| `AXI_LITE_DATA_WIDTH` | 32 | AXI-Lite data width |
| `AXI_LITE_STRB_WIDTH` | 4 | Byte strobe width |
| `AXI_LITE_REG_NUM_BYTES` | 32 | Register storage size in bytes |
| `AXI_LITE_REG_ADDR_WIDTH` | `$clog2(32)+1` | Internal decoded byte address width used by the model |
| `AXI_LITE_TIMEOUT_CYCLES` | 100 | Driver timeout limit |
| `AXI_LITE_ERR_RDATA` | `32'hBA5E_1E55` | Expected invalid-read data |

### 2.4 Interfaces

AXI-Lite interface:

```systemverilog
AXI_LITE.Slave slv
```

Direct register-side interface:

| Signal | Direction | Current v1 Usage |
| ------ | --------- | ---------------- |
| `reg_d_i` | input | Tied/driven by top-level testbench support logic |
| `reg_load_i` | input | Kept inactive in current v1 AXI-only tests |
| `reg_q_o` | output | Available for future direct-load checks |
| `wr_active_o` | output | Connected, not yet covered directly |
| `rd_active_o` | output | Connected, not yet covered directly |

---

## 3. Verification Scope

### 3.1 Implemented in v1

* Basic AXI-Lite write
* Basic AXI-Lite read
* Read-after-write correctness
* Byte strobe behavior for all nonzero 4-bit WSTRB values
* Valid aligned word address coverage from `0x00` through `0x1c`
* Invalid low address access at offsets above the configured register byte range
* Read-only byte behavior under `AXI_LITE_READ_ONLY_TEST`
* High address alias behavior caused by the DUT's internal address slicing
* AW and W channel ordering:
  * AW and W accepted together
  * AW before W
  * W before AW
* B channel response backpressure
* R channel response backpressure
* Scoreboard data checking
* Functional coverage reporting
* Basic valid/ready stability assertions

### 3.2 Planned for v2

* Direct logic load through `reg_load_i`
* AXI write versus direct load conflict behavior
* `wr_active_o` and `rd_active_o` checking
* Protection checking through `aw_prot` and `ar_prot`
* Reset-value variations beyond the current default configuration
* Larger parameter sweeps for data width and register count

### 3.3 Out of Scope

* Full AXI4 burst behavior
* Multiple outstanding transactions
* AXI ID ordering
* AXI cache, QoS, region, or user field behavior
* SoC-level interconnect verification
* Formal proof of the complete AXI-Lite protocol

---

## 4. Verification Environment

### 4.1 Current UVM Architecture

```text
axi_lite_test / axi_lite_full_cov_test / axi_lite_smoke_test / axi_lite_random_test
    |
    v
axi_lite_env
    |
    +-- axi_lite_agent
    |       |
    |       +-- axi_lite_sequencer
    |       +-- axi_lite_driver
    |       +-- axi_lite_monitor
    |
    +-- axi_lite_scoreboard
    |
    +-- axi_lite_cov
```

The current agent is a single active AXI-Lite master agent, because the DUT is an AXI-Lite slave.

### 4.2 Directory Mapping

| Area | Files |
| ---- | ----- |
| Package | `tb/pkg/axi_lite_pkg.sv` |
| Interface support | `tb/interface/axi_lite_ctrl_if.sv` |
| Agent | `tb/agent/axi_lite_tr.sv`, `axi_lite_sequencer.sv`, `axi_lite_driver.sv`, `axi_lite_monitor.sv`, `axi_lite_agent.sv` |
| Sequences | `tb/seq/axi_lite_base_seq.sv`, `axi_lite_smoke_seq.sv`, `axi_lite_strobe_seq.sv`, `axi_lite_backpressure_seq.sv`, `axi_lite_invalid_addr_seq.sv`, `axi_lite_random_seq.sv`, `axi_lite_full_cov_seq.sv` |
| Environment | `tb/env/axi_lite_env.sv`, `axi_lite_scoreboard.sv`, `axi_lite_cov.sv` |
| Tests | `tb/tests/axi_lite_base_test.sv`, `axi_lite_smoke_test.sv`, `axi_lite_full_cov_test.sv`, `axi_lite_random_test.sv`, `axi_lite_test.sv` |
| Assertions | `tb/assertions/axi_lite_assertions.sv` |
| Top | `tb/top/tb_top.sv` |

---

## 5. UVM Components

### 5.1 Transaction Item

Current transaction class:

```text
axi_lite_tr
```

Main fields:

| Field | Description |
| ----- | ----------- |
| `cmd` | Read or write |
| `addr` | AXI-Lite address |
| `data` | Write data |
| `strb` | Write byte strobe |
| `aw_delay` | Delay before asserting AWVALID |
| `w_delay` | Delay before asserting WVALID |
| `b_ready_delay` | Delay before accepting B response |
| `ar_delay` | Delay before asserting ARVALID |
| `r_ready_delay` | Delay before accepting R response |
| `rdata` | Observed read data |
| `resp` | Observed response |
| `wr_order` | Observed AW/W ordering |
| `b_wait_cycles` | Observed B channel wait |
| `r_wait_cycles` | Observed R channel wait |

### 5.2 Driver

The driver converts `axi_lite_tr` items into AXI-Lite bus activity.

Implemented driver behavior:

* Write transactions
* Read transactions
* Independent AW and W channel launch delay
* BREADY backpressure
* RREADY backpressure
* Timeout protection to avoid silent deadlock

### 5.3 Monitor

The monitor reconstructs bus transactions from AXI-Lite handshakes and publishes them through an analysis port.

Captured write information:

* AW handshake
* W handshake
* B handshake
* address
* write data
* strobe
* response
* AW/W ordering
* B wait cycles

Captured read information:

* AR handshake
* R handshake
* address
* read data
* response
* R wait cycles

### 5.4 Scoreboard

The scoreboard maintains a byte-level reference model:

```systemverilog
bit [7:0] reg_model [AXI_LITE_REG_NUM_BYTES];
```

Model rules:

* Legal writes update selected bytes according to WSTRB.
* Legal reads compare DUT RDATA against the byte model.
* Invalid low-offset accesses expect `SLVERR`.
* Invalid reads expect `AXI_LITE_ERR_RDATA`.
* High address bits are modeled using the same effective address slicing as the DUT.

### 5.5 Coverage Collector

The coverage collector samples observed transactions from the monitor.

Current coverpoints:

* command type
* valid word address
* write strobe category
* response value
* write data pattern
* read data pattern
* AW/W ordering
* B wait cycles
* R wait cycles

Current crosses:

* command x address
* address x strobe
* command x response
* write ordering x strobe

---

## 6. Sequence Plan

### 6.1 Base Sequence

`axi_lite_base_seq` provides reusable helper tasks:

```text
send_write()
send_read()
send_random_access()
```

### 6.2 Implemented Sequences

| Sequence | Purpose |
| -------- | ------- |
| `axi_lite_smoke_seq` | Reset/default reads plus full-word write/read across all valid addresses |
| `axi_lite_strobe_seq` | All nonzero WSTRB values across all valid word addresses |
| `axi_lite_backpressure_seq` | AW/W ordering plus B/R wait coverage |
| `axi_lite_invalid_addr_seq` | Invalid low offsets and high address alias check |
| `axi_lite_random_seq` | Constrained-random valid read/write tail |
| `axi_lite_read_only_seq` | Read-only chunk, mixed read-only/writable chunk, and normal writable chunk accesses |
| `axi_lite_full_cov_seq` | Runs smoke, strobe, backpressure, invalid address, and random sequences |
| `axi_lite_seq` | Compatibility alias for full coverage behavior |

---

## 7. Test Plan

### 7.1 Implemented Tests

| Test Name | Sequence | Purpose |
| --------- | -------- | ------- |
| `axi_lite_smoke_test` | `axi_lite_smoke_seq` | Fast bring-up and basic read/write sanity |
| `axi_lite_full_cov_test` | `axi_lite_full_cov_seq` | Main coverage-closure test |
| `axi_lite_read_only_test` | `axi_lite_read_only_seq` | Read-only byte behavior |
| `axi_lite_random_test` | `axi_lite_random_seq` | Longer random valid-access test |
| `axi_lite_test` | `axi_lite_full_cov_seq` | Default compatibility test |

### 7.2 Run Commands

Default full coverage run:

```bash
make run
```

Specific tests:

```bash
make TEST=axi_lite_smoke_test run
make TEST=axi_lite_full_cov_test run
make TEST=axi_lite_read_only_test run
make TEST=axi_lite_random_test run
```

### 7.3 Directed Scenario Mapping

| Scenario | Implemented By |
| -------- | -------------- |
| Read after reset/default state | `axi_lite_smoke_seq` |
| Basic write/read | `axi_lite_smoke_seq` |
| All valid word addresses | `axi_lite_smoke_seq`, `axi_lite_strobe_seq` |
| Byte strobe writes | `axi_lite_strobe_seq` |
| AW/W ordering variation | `axi_lite_backpressure_seq` |
| BREADY/RREADY backpressure | `axi_lite_backpressure_seq`, strobe/random delay fields |
| Invalid low address response | `axi_lite_invalid_addr_seq` |
| Read-only byte behavior | `axi_lite_read_only_seq` |
| High address alias behavior | `axi_lite_invalid_addr_seq` |
| Random valid accesses | `axi_lite_random_seq` |

---

## 8. Assertions

Current assertion module:

```text
tb/assertions/axi_lite_assertions.sv
```

Implemented assertion intent:

* AW channel payload remains stable while `AWVALID && !AWREADY`
* W channel payload remains stable while `WVALID && !WREADY`
* AR channel payload remains stable while `ARVALID && !ARREADY`
* B channel payload remains stable while `BVALID && !BREADY`
* R channel payload remains stable while `RVALID && !RREADY`

Planned assertion extensions:

* No unknown values on active response channels
* B response occurs only after AW and W are accepted
* R response occurs only after AR is accepted
* Reset-specific output checks
* Direct-load conflict checks

---

## 9. Functional Coverage Plan

### 9.1 Current Coverage Goals

The current coverage model targets closure on the v1 AXI-only scenarios:

| Coverage Item | Goal |
| ------------- | ---- |
| command type | read and write observed |
| address | all valid word addresses observed |
| strobe | all nonzero strobe categories observed |
| response | `OKAY` and `SLVERR` observed |
| write ordering | same-cycle, AW-before-W, W-before-AW observed |
| B wait | no wait, short wait, longer wait observed |
| R wait | no wait, short wait, longer wait observed |
| command x address | reads and writes across valid address bins |
| address x strobe | strobe behavior across address bins |
| command x response | legal and illegal response behavior observed |
| write ordering x strobe | ordering variation across strobe bins |

### 9.2 Latest Observed Coverage

Latest passing run reported:

```text
AXI-Lite functional coverage = 100.00%
cmd_addr_cross              = 100.00%
addr_strb_cross             = 100.00%
cmd_resp_cross              = 100.00%
wr_order_cp                 = 100.00%
b_wait_cp                   = 100.00%
r_wait_cp                   = 100.00%
wr_order_strb_cross         = 100.00%
Scoreboard passed: read_checks=182
UVM_WARNING                 = 0
UVM_ERROR                   = 0
UVM_FATAL                   = 0
```

### 9.3 Planned v2 Coverage

Future coverpoints/crosses:

* protection value x response
* read-only byte x write strobe
* direct load x AXI access
* `wr_active_o` and `rd_active_o`
* reset value variation
* parameter sweep coverage

---

## 10. Reference Model

### 10.1 Byte-Level Model

The current scoreboard model is byte-based:

```text
reg_model[byte_index]
```

For a valid write:

```text
for each byte lane selected by WSTRB:
    reg_model[effective_addr + lane] = WDATA byte
```

For a valid read:

```text
expected RDATA = bytes from reg_model[effective_addr +: AXI_LITE_STRB_WIDTH]
```

For an invalid low-offset access:

```text
expected response = SLVERR
invalid read data = AXI_LITE_ERR_RDATA
model is not updated by invalid write
```

### 10.2 DUT-Specific Address Note

`axi_lite_regs` decodes only the internal register-byte address slice. High address bits outside that slice are ignored by the DUT. The scoreboard therefore uses an effective address derived from the same low address bits.

Example:

```text
0x0000_0100 aliases to 0x0000_0000 in the current configuration
```

This behavior is intentionally checked by `axi_lite_invalid_addr_seq`.

---

## 11. Pass / Fail Criteria

The v1 verification run is considered passing when:

* Compilation and elaboration complete successfully.
* The selected UVM test completes without timeout.
* Scoreboard reports zero mismatches.
* UVM reports zero `UVM_ERROR` and zero `UVM_FATAL`.
* Protocol assertions do not fail.
* Functional coverage reaches the target for the selected test.

Current v1 target:

```text
axi_lite_full_cov_test functional coverage: 100%
assertion failures: 0
scoreboard mismatches: 0
UVM_ERROR: 0
UVM_FATAL: 0
```

---

## 12. Regression List

| Test Name | Status | Description |
| --------- | ------ | ----------- |
| `axi_lite_smoke_test` | Implemented | Fast sanity test for default reads and full-word read/write |
| `axi_lite_full_cov_test` | Implemented | Main coverage closure test |
| `axi_lite_random_test` | Implemented | Longer constrained-random valid access test |
| `axi_lite_test` | Implemented | Default alias for full coverage behavior |
| `axi_lite_read_only_test` | Implemented | Read-only byte configuration |
| `axi_lite_direct_load_test` | Planned | Direct logic load through `reg_load_i` |
| `axi_lite_load_conflict_test` | Planned | AXI write versus direct load conflict |
| `axi_lite_prot_test` | Planned | Privileged/secure protection behavior |
| `axi_lite_param_sweep_test` | Planned | Wider data/register parameter variations |

---

## 13. Current Status

Current environment status:

```text
Compile/elaboration: PASS
Default UVM run: PASS
Scoreboard: PASS
Functional coverage: 100%
UVM_WARNING: 0
UVM_ERROR: 0
UVM_FATAL: 0
```

Current deliverables:

* Reusable AXI-Lite master agent
* Scenario-based sequence library
* Test hierarchy with smoke/full/random tests
* Byte-level scoreboard
* Functional coverage collector
* AXI-Lite protocol assertion module
* VCS Makefile flow

---

## 14. Future Extensions

Recommended next steps:

1. Expand read-only tests to cover more masks and reset values.
2. Add direct-load tests for `reg_d_i` and `reg_load_i`.
3. Add conflict testing between AXI writes and direct logic loads.
4. Add protection-mode tests for `PrivProtOnly` and `SecuProtOnly`.
5. Add a small regression script that runs smoke, full coverage, read-only, and random tests.
6. Add parameter sweeps for register byte count and data width.
7. Reuse the AXI-Lite master agent on a second DUT, such as an AXI-Lite xbar, decoder, or small control/status register block.

Longer-term subsystem direction:

```text
UVM AXI-Lite Master Agent
        |
        v
AXI-Lite Decoder / Xbar
   |                  |
   v                  v
Control Regs       Status Regs
```
