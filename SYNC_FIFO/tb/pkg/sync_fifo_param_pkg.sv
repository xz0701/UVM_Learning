`ifndef SYNC_FIFO_PARAM_PKG_SV
`define SYNC_FIFO_PARAM_PKG_SV

package sync_fifo_param_pkg;

`ifndef WIDTH
    parameter int WIDTH = 8;
`else
    parameter int WIDTH = `WIDTH;
`endif

`ifndef DEPTH
    parameter int DEPTH = 16;
`else
    parameter int DEPTH = `DEPTH;
`endif

endpackage

`endif