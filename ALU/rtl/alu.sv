import alu_pkg::*;

module alu #(
    parameter WIDTH        = 8
)(
    input  logic [WIDTH - 1: 0] a,
    input  logic [WIDTH - 1: 0] b,
    input  alu_op_e             op,
    output logic [WIDTH - 1: 0] out
);
    localparam SHIFT_BITS = $clog2(WIDTH);
    always_comb begin
       unique case (op)
            ALU_ADD: out = a + b;
            ALU_SUB: out = a - b;   
            ALU_AND: out = a & b;
            ALU_OR : out = a | b;
            ALU_XOR: out = a ^ b;
            ALU_SLL: out = a << b[SHIFT_BITS - 1: 0];
            ALU_SRL: out = a >> b[SHIFT_BITS - 1: 0];
            ALU_SLT: out = (a < b);
            default: out = '0;
        endcase 
    end
    
endmodule