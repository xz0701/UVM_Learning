`ifndef ALU_ITEM_SV
`define ALU_ITEM_SV

class alu_item extends uvm_sequence_item;
    rand logic [7 : 0] a;
    rand logic [7 : 0] b;
    rand alu_op_e     op;
    
    logic [7 : 0] out;

    `uvm_object_utils_begin(alu_item)
        `uvm_field_int(a, UVM_ALL_ON)
        `uvm_field_int(b, UVM_ALL_ON)
        `uvm_field_enum(alu_op_e, op, UVM_ALL_ON);
        `uvm_field_int(out, UVM_ALL_ON);
    `uvm_object_utils_end

    function new (string name = "alu_item");
        super.new(name);
    endfunction

endclass

`endif