package alu_pkg

    typedef enum logic [2: 0] {
        ALU_ADD          = 3'd0;
        ALU_SUB          = 3'd1;
        ALU_AND          = 3'd2;
        ALU_OR           = 3'd3;
        ALU_XOR          = 3'd4;
        ALU_SLL          = 3'd5;
        ALU_SRL          = 3'd6;
        ALU_SLT          = 3'd7
    } alu_op_e;

endpackage