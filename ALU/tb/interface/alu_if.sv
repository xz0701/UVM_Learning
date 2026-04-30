`ifndef ALU_IF_SV
`define ALU_IF_SV

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

    // Enable assertions after initial startup cycles.
    bit assert_en;

    initial begin
        assert_en = 1'b0;
        repeat (2) @(posedge clk);
        assert_en = 1'b1;
    end

    // Check no X/Z on ALU interface signals.
    property p_no_unknown;
        @(posedge clk) disable iff (!assert_en)
        !$isunknown({a, b, op, out});
    endproperty

    a_no_unknown: assert property (p_no_unknown)
        else $error("ALU_ASSERT: ALU interface has X/Z value");

    // Check op is always legal.
    property p_valid_op;
        @(posedge clk) disable iff (!assert_en)
        op inside {
            ALU_ADD, ALU_SUB, ALU_AND, ALU_OR,
            ALU_XOR, ALU_SLL, ALU_SRL, ALU_SLT
        };
    endproperty

    a_valid_op: assert property (p_valid_op)
        else $error("ALU_ASSERT: ALU op is illegal");

    // Check combinational behavior:
    // If inputs are stable, output should also remain stable.
    property p_comb_stable;
        @(posedge clk) disable iff (!assert_en)
        $stable(a) && $stable(b) && $stable(op) |-> $stable(out);
    endproperty

    a_comb_stable: assert property (p_comb_stable)
        else $error("ALU_ASSERT: ALU output changed while inputs were stable");

endinterface

`endif