`ifndef SYNC_FIFO_IF_SV
`define SYNC_FIFO_IF_SV

interface sync_fifo_if #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 64
)(
    input logic clk,
    input logic rst_n
);

    logic             rd_en;
    logic             wr_en;
    logic [WIDTH-1:0] rd_data;
    logic [WIDTH-1:0] wr_data;
    logic             empty;
    logic             full;

endinterface

`endif