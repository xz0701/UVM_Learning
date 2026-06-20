package axi_lite_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned AXI_LITE_ADDR_WIDTH = 32;
  localparam int unsigned AXI_LITE_DATA_WIDTH = 32;
  localparam int unsigned AXI_LITE_STRB_WIDTH = AXI_LITE_DATA_WIDTH / 8;
  localparam int unsigned AXI_LITE_REG_NUM_BYTES = 32;
  localparam int unsigned AXI_LITE_REG_ADDR_WIDTH = $clog2(AXI_LITE_REG_NUM_BYTES) + 1;
  localparam int unsigned AXI_LITE_TIMEOUT_CYCLES = 100;
  localparam bit [1:0] AXI_LITE_RESP_OKAY = 2'b00;
  localparam bit [1:0] AXI_LITE_RESP_SLVERR = 2'b10;
  localparam bit [AXI_LITE_DATA_WIDTH-1:0] AXI_LITE_ERR_RDATA = 32'hBA5E_1E55;

  typedef virtual AXI_LITE #(
    .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
  ) axi_lite_vif_t;

  typedef virtual axi_lite_ctrl_if axi_lite_ctrl_vif_t;

  typedef enum bit {
    AXI_LITE_READ,
    AXI_LITE_WRITE
  } axi_lite_cmd_e;

  typedef enum bit [1:0] {
    AXI_LITE_AW_W_SAME,
    AXI_LITE_AW_BEFORE_W,
    AXI_LITE_W_BEFORE_AW
  } axi_lite_wr_order_e;

  `include "axi_lite_tr.sv"
  `include "axi_lite_base_seq.sv"
  `include "axi_lite_smoke_seq.sv"
  `include "axi_lite_strobe_seq.sv"
  `include "axi_lite_backpressure_seq.sv"
  `include "axi_lite_invalid_addr_seq.sv"
  `include "axi_lite_random_seq.sv"
  `include "axi_lite_full_cov_seq.sv"
  `include "axi_lite_seq.sv"
  `include "axi_lite_sequencer.sv"
  `include "axi_lite_driver.sv"
  `include "axi_lite_monitor.sv"
  `include "axi_lite_agent.sv"
  `include "axi_lite_scoreboard.sv"
  `include "axi_lite_cov.sv"
  `include "axi_lite_env.sv"
  `include "axi_lite_base_test.sv"
  `include "axi_lite_smoke_test.sv"
  `include "axi_lite_full_cov_test.sv"
  `include "axi_lite_random_test.sv"
  `include "axi_lite_test.sv"

endpackage
