package axi_lite_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int unsigned AXI_LITE_ADDR_WIDTH = 32;
  localparam int unsigned AXI_LITE_DATA_WIDTH = 32;
  localparam int unsigned AXI_LITE_STRB_WIDTH = AXI_LITE_DATA_WIDTH / 8;
  localparam int unsigned AXI_LITE_REG_NUM_BYTES = 32;

  typedef virtual AXI_LITE #(
    .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
    .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
  ) axi_lite_vif_t;

  typedef virtual axi_lite_ctrl_if axi_lite_ctrl_vif_t;

  typedef enum bit {
    AXI_LITE_READ,
    AXI_LITE_WRITE
  } axi_lite_cmd_e;

  `include "axi_lite_tr.sv"
  `include "axi_lite_seq.sv"
  `include "axi_lite_sequencer.sv"
  `include "axi_lite_driver.sv"
  `include "axi_lite_monitor.sv"
  `include "axi_lite_agent.sv"
  `include "axi_lite_scoreboard.sv"
  `include "axi_lite_cov.sv"
  `include "axi_lite_env.sv"
  `include "axi_lite_test.sv"

endpackage
