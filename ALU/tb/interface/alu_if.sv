interface alu_if #(
    parameter int WIDTH = 8
)(
    input logic clk
);

    import alu_pkg::*;

    logic    [WIDTH-1:0] a;
    logic    [WIDTH-1:0] b;
    alu_op_e             op;
    logic    [WIDTH-1:0] out;

endinterface