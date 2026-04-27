`ifndef ALU_SCOREBOARD_SV
`define ALU_SCOREBOARD_SV

class alu_scoreboard extends uvm_component;

    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_imp #(alu_item, alu_scoreboard) item_collected_export;

    function new(string name = "alu_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        item_collected_export = new("item_collected_export", this);
    endfunction

    virtual function logic [7:0] calc_expected(alu_item item);

        logic [7 : 0] expected;
        logic [7 : 0] shift_amt;

        shift_amt = item.b[2 : 0];

        unique case (item.op)
            ALU_ADD: expected = item.a + item.b;
            ALU_SUB: expected = item.a - item.b;
            ALU_AND: expected = item.a & item.b;
            ALU_OR : expected = item.a | item.b;
            ALU_XOR: expected = item.a ^ item.b;
            ALU_SLL: expected = item.a << shift_amt;
            ALU_SRL: expected = item.a >> shift_amt;
            ALU_SLT: expected = (item.a < item.b);
            default: expected = '0; 
        endcase

        return expected;

    endfunction
    
    virtual function void write(alu_item item);

        logic [7:0] expected;

        expected = calc_expected(item);

        if (item.out != expected) begin
            `uvm_error("ALU_SCB",
                        $sformatf("Mismatch: a=0x%0h b=0%0h op=%s out=0x%0h",
                                    item.a, item.b, item.op.name(), item.out))
        end
        else begin
            `uvm_info("ALU_SCB",
                        $sformatf("PASS: a=0x%0h b=0x%0h op=%s expected=0x%0h actual=0x%0h",
                                    item.a, item.b, item.op.name(), expected, item.out),
                                    UVM_LOW)
end
    
    endfunction
    
endclass

`endif