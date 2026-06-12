package axi_lite_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum bit {
    AXI_LITE_READ,
    AXI_LITE_WRITE
  } axi_lite_cmd_e;

  `include "axi_lite_tr.sv"

endpackage