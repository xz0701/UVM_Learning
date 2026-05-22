`ifndef SYNC_FIFO_PKG_SV
`define SYNC_FIFO_PKG_SV

package sync_fifo_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import sync_fifo_param_pkg::*;

    `include "sync_fifo_transaction.sv"
    `include "sync_fifo_sequence.sv"
    `include "sync_fifo_sequencer.sv"
    `include "sync_fifo_driver.sv"
    `include "sync_fifo_monitor.sv"
    `include "sync_fifo_agent.sv"
    `include "sync_fifo_scoreboard.sv"
    `include "sync_fifo_env.sv"
    `include "sync_fifo_test.sv"

endpackage

`endif