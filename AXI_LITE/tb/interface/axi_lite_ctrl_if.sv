interface axi_lite_ctrl_if #(
    parameter int unsigned REG_NUM_BYTES = 32,
    parameter int unsigned DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_n
);

    typedef logic [7:0] byte_t;

    logic [REG_NUM_BYTES-1:0] wr_active;
    logic [REG_NUM_BYTES-1:0] rd_active;

    byte_t [REG_NUM_BYTES-1:0] reg_d;
    logic  [REG_NUM_BYTES-1:0] reg_load;
    byte_t [REG_NUM_BYTES-1:0] reg_q;

endinterface
