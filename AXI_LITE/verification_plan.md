# Verification Plan: AXI-Lite Register Block

## 1. Project Overview

This verification plan targets the PULP Platform `axi_lite_regs` / `axi_lite_regs_intf` module.

The DUT implements an AXI4-Lite accessible register block. The register array is organized at byte granularity and can be accessed from two sides:

1. AXI4-Lite slave interface
2. Direct logic interface through `reg_d_i`, `reg_load_i`, and `reg_q_o`

The main goal of this verification effort is to validate AXI-Lite read/write behavior, byte-level register update behavior, read-only byte handling, protection checking, reset behavior, and response correctness.

---

## 2. DUT Description

### 2.1 DUT Name

```text
axi_lite_regs
axi_lite_regs_intf
```

### 2.2 DUT Role

The DUT is an **AXI4-Lite slave**.

It receives AXI-Lite transactions from a master and returns read/write responses.

```text
AXI-Lite Master Agent
        |
        v
axi_lite_regs DUT
```

### 2.3 Main Parameters

| Parameter                         | Description                      |
| --------------------------------- | -------------------------------- |
| `RegNumBytes` / `REG_NUM_BYTES`   | Number of register bytes         |
| `AxiAddrWidth` / `AXI_ADDR_WIDTH` | AXI-Lite address width           |
| `AxiDataWidth` / `AXI_DATA_WIDTH` | AXI-Lite data width              |
| `AxiReadOnly` / `AXI_READ_ONLY`   | Per-byte read-only configuration |
| `RegRstVal` / `REG_RST_VAL`       | Per-byte reset value             |
| `PrivProtOnly` / `PRIV_PROT_ONLY` | Only allow privileged access     |
| `SecuProtOnly` / `SECU_PROT_ONLY` | Only allow secure access         |

### 2.4 Interfaces

#### AXI-Lite Slave Interface

For `axi_lite_regs_intf`, the interface is:

```systemverilog
AXI_LITE.Slave slv
```

AXI-Lite channels:

```text
AW: write address
W : write data
B : write response
AR: read address
R : read response
```

#### Direct Logic Register Interface

| Signal        | Direction | Description                                     |
| ------------- | --------- | ----------------------------------------------- |
| `reg_d_i`     | input     | Direct byte value loaded from surrounding logic |
| `reg_load_i`  | input     | Per-byte load enable from surrounding logic     |
| `reg_q_o`     | output    | Current byte value of register array            |
| `wr_active_o` | output    | Byte-level AXI write activity                   |
| `rd_active_o` | output    | Byte-level AXI read activity                    |

---

## 3. Verification Scope

### 3.1 In Scope

This plan verifies:

* Basic AXI-Lite write
* Basic AXI-Lite read
* Read-after-write correctness
* Byte strobe behavior
* Multi-register access
* Invalid address / invalid offset response
* Reset value behavior
* Read-only byte behavior
* Direct logic load through `reg_load_i`
* Conflict between AXI write and direct logic load
* `wr_active_o` and `rd_active_o`
* Protection checking through `aw_prot` and `ar_prot`
* Back-to-back access
* AXI-Lite response correctness
* Basic protocol stability rules

### 3.2 Out of Scope

This plan does not verify:

* Full AXI4 burst behavior
* Multiple outstanding transactions
* AXI ID ordering
* AXI cache or QoS fields
* Full SoC-level interconnect behavior
* Performance optimization of the DUT
* Formal proof of the complete AXI-Lite protocol

---

## 4. Verification Environment

### 4.1 Testbench Architecture

```text
axi_lite_test
    |
    v
axi_lite_env
    |
    +-- axi_lite_master_agent
    |       |
    |       +-- sequencer
    |       +-- driver
    |       +-- monitor
    |
    +-- axi_lite_scoreboard
    |
    +-- axi_lite_coverage
```

### 4.2 DUT Connection

The first target should use the interface version:

```text
axi_lite_regs_intf
```

The testbench drives the PULP `AXI_LITE` interface directly through a virtual interface.

```text
UVM Master Driver
        |
        v
virtual AXI_LITE interface
        |
        v
axi_lite_regs_intf DUT
```

---

## 5. UVM Components

### 5.1 Transaction Item

The AXI-Lite transaction item should contain:

```systemverilog
class axi_lite_item extends uvm_sequence_item;

  rand bit        is_write;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit [3:0]  strb;
  rand bit [2:0]  prot;

  bit [31:0]      rdata;
  bit [1:0]       resp;

endclass
```

### 5.2 Master Driver

The master driver generates AXI-Lite bus activity.

Supported operations:

* Write transaction
* Read transaction
* Back-to-back access
* Optional random delay
* Optional response backpressure

For the first version, the write driver should drive `AWVALID` and `WVALID` together because the DUT write logic accepts write address and write data when both are valid.

### 5.3 Monitor

The monitor observes AXI-Lite bus activity and reconstructs transactions.

It should capture:

* Write address handshake
* Write data handshake
* Write response handshake
* Read address handshake
* Read response handshake
* Read data
* Response code
* Byte strobe

### 5.4 Scoreboard

The scoreboard maintains a byte-level reference model.

```text
byte model[REG_NUM_BYTES]
```

For writes:

```text
if response == OKAY:
    update model bytes according to WSTRB and read-only configuration
```

For reads:

```text
expected data = model bytes selected by address
compare expected data with RDATA
```

For invalid accesses:

```text
expected response = SLVERR
```

### 5.5 Coverage Collector

The coverage collector samples transactions and important DUT behaviors.

Coverage should include:

* Access type
* Address offset
* Byte strobe
* Response code
* Protection value
* Read-only access
* Direct load access
* Read/write cross
* Address/strobe cross
* Response/access cross

---

## 6. Reference Model

### 6.1 Register Model

The reference model is byte-based:

```systemverilog
bit [7:0] reg_model [REG_NUM_BYTES];
```

At reset:

```text
reg_model[i] = REG_RST_VAL[i]
```

For direct logic load:

```text
if reg_load_i[i] == 1:
    reg_model[i] = reg_d_i[i]
```

For AXI write:

```text
for each byte selected by WSTRB:
    if byte is valid and not read-only:
        reg_model[byte_index] = WDATA byte
```

For AXI read:

```text
RDATA byte = reg_model[byte_index]
```

### 6.2 Response Model

Expected response behavior:

| Scenario                           | Expected Response |
| ---------------------------------- | ----------------- |
| Valid write to writable byte       | `OKAY`            |
| Valid read from mapped byte        | `OKAY`            |
| Invalid address offset             | `SLVERR`          |
| Write only to read-only bytes      | `SLVERR`          |
| Access violates protection setting | `SLVERR`          |

---

## 7. Test Scenarios

### 7.1 Reset Test

Objective:

* Verify all registers reset to `REG_RST_VAL`.
* Verify no invalid AXI output after reset.
* Verify read after reset returns reset values.

Stimulus:

```text
reset DUT
read all register chunks
compare with reset values
```

Checks:

* `reg_q_o` matches expected reset bytes
* AXI read data matches reset values
* Response is `OKAY`

---

### 7.2 Basic Write/Read Test

Objective:

* Verify simple write and read operation.

Stimulus:

```text
write addr 0x00 = 32'h1234_5678
read  addr 0x00
```

Checks:

```text
RDATA == 32'h1234_5678
BRESP == OKAY
RRESP == OKAY
```

---

### 7.3 Multiple Address Test

Objective:

* Verify address decoding across all register chunks.

Stimulus:

```text
write every aligned register address
read every aligned register address
```

Checks:

* Each address stores independent data
* No data corruption between chunks

---

### 7.4 Byte Strobe Test

Objective:

* Verify `WSTRB` updates only selected bytes.

Stimulus:

```text
write 0x00 = 32'hAAAA_AAAA with WSTRB = 4'b1111
write 0x00 = 32'h1234_5678 with WSTRB = 4'b0011
read  0x00
```

Expected:

```text
upper two bytes remain from old value
lower two bytes update from new value
```

Additional cases:

```text
WSTRB = 4'b0001
WSTRB = 4'b0010
WSTRB = 4'b0100
WSTRB = 4'b1000
WSTRB = 4'b1111
WSTRB = random nonzero pattern
```

---

### 7.5 Read-Only Byte Test

Objective:

* Verify bytes configured as read-only cannot be modified through AXI writes.

Configuration:

```text
AXI_READ_ONLY contains one or more read-only bytes
```

Stimulus:

```text
read initial read-only byte
attempt AXI write to read-only byte
read again
```

Checks:

* Read-only byte value does not change
* If write strobes select only read-only bytes, response is `SLVERR`
* If write strobes select both writable and read-only bytes, writable bytes update and read-only bytes remain unchanged

---

### 7.6 Direct Logic Load Test

Objective:

* Verify `reg_load_i` and `reg_d_i` can directly update register bytes.

Stimulus:

```text
drive reg_d_i[i]
assert reg_load_i[i]
read corresponding AXI address
```

Checks:

* `reg_q_o[i]` updates
* AXI read returns the loaded value

---

### 7.7 AXI Write vs Direct Load Conflict Test

Objective:

* Verify behavior when direct logic load conflicts with AXI write.

Stimulus:

```text
assert reg_load_i for a writable byte
attempt AXI write to the same byte
```

Checks:

* AXI write should stall while direct load conflict exists
* After conflict is removed, AXI write can complete
* Final register value matches expected model behavior

---

### 7.8 Invalid Address Test

Objective:

* Verify invalid offsets return `SLVERR`.

Stimulus:

```text
access offset above RegNumBytes but within decoded address slice
```

Checks:

* Read response is `SLVERR`
* Write response is `SLVERR`
* Register model is not incorrectly modified

---

### 7.9 Protection Test

Objective:

* Verify privileged and secure access filtering.

Configurations:

```text
PRIV_PROT_ONLY = 1
SECU_PROT_ONLY = 1
```

Stimulus:

```text
access with different aw_prot/ar_prot values
```

Checks:

* Allowed protection values return `OKAY`
* Disallowed protection values return `SLVERR`
* Disallowed writes do not update registers

---

### 7.10 Back-to-Back Transaction Test

Objective:

* Verify consecutive reads and writes.

Stimulus:

```text
write addr0
write addr1
write addr2
read addr0
read addr1
read addr2
```

Checks:

* All responses are correct
* No transaction is lost
* Read data matches scoreboard model

---

### 7.11 Random Register Access Test

Objective:

* Verify randomized register access behavior.

Stimulus:

```text
random read/write
random address
random data
random WSTRB
random protection value
```

Constraints:

* Address should include both valid and invalid offsets
* WSTRB should include common and random patterns
* Protection should include valid and invalid values if protection mode is enabled

Checks:

* Scoreboard comparison
* Response checking
* No timeout or deadlock

---

### 7.12 Response Backpressure Test

Objective:

* Verify DUT holds response valid until master ready.

Stimulus:

```text
deassert BREADY after write
deassert RREADY after read
```

Checks:

* `BVALID` remains asserted until `BREADY`
* `RVALID` remains asserted until `RREADY`
* Response data remains stable while waiting

---

## 8. Assertions

### 8.1 AXI-Lite Protocol Assertions

Recommended assertions:

```text
AWVALID remains stable until AWREADY
WVALID remains stable until WREADY
ARVALID remains stable until ARREADY
BVALID remains stable until BREADY
RVALID remains stable until RREADY
RDATA remains stable while RVALID && !RREADY
BRESP remains stable while BVALID && !BREADY
```

### 8.2 DUT-Specific Assertions

Recommended assertions:

```text
reset drives register values to REG_RST_VAL
read-only bytes do not change due to AXI writes
write response only occurs after write address and write data are accepted
read response only occurs after read address is accepted
no unknown values on AXI response channels when valid
```

### 8.3 Liveness / Timeout Checks

Recommended checks:

```text
valid write eventually receives BVALID
valid read eventually receives RVALID
simulation must not hang on legal access
```

---

## 9. Functional Coverage Plan

### 9.1 Covergroups

#### Access Type Coverage

```text
read
write
```

#### Address Coverage

```text
first register chunk
middle register chunk
last register chunk
invalid offset
```

#### WSTRB Coverage

```text
4'b0001
4'b0010
4'b0100
4'b1000
4'b0011
4'b1100
4'b1111
random mixed pattern
```

#### Response Coverage

```text
OKAY
SLVERR
```

#### Protection Coverage

```text
prot = 3'b000
prot with privileged bit set
prot with secure bit set
invalid protection combinations
```

#### Read-Only Coverage

```text
write to writable byte
write to read-only byte
write to mixed writable/read-only bytes
```

#### Direct Load Coverage

```text
direct load only
AXI write only
direct load and AXI write conflict
```

### 9.2 Cross Coverage

Recommended crosses:

```text
access_type x address
access_type x response
write x WSTRB
write x read_only_region
protection x response
address x response
direct_load x AXI_write
```

---

## 10. Pass / Fail Criteria

The verification is considered passing when:

* All directed tests pass
* Random test runs without mismatch or timeout
* Scoreboard reports zero data mismatches
* No assertion failure occurs
* Functional coverage reaches target percentage
* All planned response scenarios are observed
* All legal accesses return correct data and response
* All illegal accesses return expected error response

Suggested coverage target:

```text
Functional coverage: >= 90%
Assertion failures: 0
Scoreboard mismatches: 0
Simulation fatal errors: 0
```

---

## 11. Regression List

| Test Name                     | Description                        |
| ----------------------------- | ---------------------------------- |
| `axi_lite_reset_test`         | Reset and reset-value readback     |
| `axi_lite_basic_rw_test`      | Basic write/read                   |
| `axi_lite_all_addr_test`      | Access all register chunks         |
| `axi_lite_wstrb_test`         | Byte strobe writes                 |
| `axi_lite_read_only_test`     | Read-only byte behavior            |
| `axi_lite_direct_load_test`   | Direct logic load                  |
| `axi_lite_load_conflict_test` | AXI write vs direct load conflict  |
| `axi_lite_invalid_addr_test`  | Invalid offset access              |
| `axi_lite_prot_test`          | Protection checking                |
| `axi_lite_back_to_back_test`  | Back-to-back read/write            |
| `axi_lite_backpressure_test`  | B/R response backpressure          |
| `axi_lite_random_test`        | Constrained-random register access |

---

## 12. Implementation Milestones

### Milestone 1: Compile and Smoke Test

* Compile PULP `axi_lite_regs_intf`
* Instantiate PULP `AXI_LITE` interface
* Run simple non-UVM write/read task
* Confirm waveform behavior

### Milestone 2: Basic UVM Bring-up

* Implement `axi_lite_item`
* Implement master driver
* Implement monitor
* Implement basic sequence
* Run basic write/read test

### Milestone 3: Scoreboard

* Build byte-level register model
* Add WSTRB support
* Add read/write compare
* Add invalid response checking

### Milestone 4: Directed Tests

* Reset
* Basic RW
* WSTRB
* Invalid address
* Read-only
* Direct load

### Milestone 5: Coverage and Assertions

* Add functional coverage
* Add protocol assertions
* Add DUT-specific assertions

### Milestone 6: Random Regression

* Add constrained-random tests
* Add random delays
* Add regression script
* Collect coverage report

---

## 13. Known DUT-Specific Notes

The DUT register array is byte-addressed internally.

The AXI write path checks `aw_valid`, `w_valid`, and response readiness before accepting a write. Therefore, the first master driver version should drive AW and W together to avoid unnecessary bring-up complexity.

The read path uses a spill register on the R channel, and the write response path uses a spill register on the B channel. Therefore, responses may appear one cycle after request acceptance.

The DUT ignores address bits outside the internal register-byte address slice. Verification should focus on offsets within the decoded slice and offsets above the valid byte range.

---

## 14. Future Extensions

After this register block verification is complete, the environment can be extended to:

```text
AXI-Lite xbar verification
Multiple AXI-Lite slave register blocks
AXI-Lite subsystem verification
AXI-Lite controlled accelerator verification
Tiny matrix-multiply accelerator verification
```

Possible next subsystem:

```text
UVM AXI-Lite Master Agent
        |
        v
AXI-Lite Xbar / Decoder
   |                  |
   v                  v
Control Regs       Status Regs
```

This provides a path from AXI-Lite IP verification toward AI accelerator verification.
