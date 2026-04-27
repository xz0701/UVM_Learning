`ifndef ALU_SEQUENCE_SV
`define ALU_SEQUENCE_SV

class alu_sequence extends uvm_sequence #(alu_item);
    `uvm_object_utils(alu_sequence)

    function new(string name = "alu_sequence");
        super.new(name);
    endfunction

    virtual task body ();
        alu_item req;

        repeat(50) begin
            req = alu_item::type_id::create("req");

            start_item(req);

            if (!req.randomize()) begin
                `uvm_error("ALU_SEQ", "Randomization Failed")
            end

            finish_item(req);

            `uvm_info("ALU_SEQ",
                $sformatf("Generated item: a=0x%0h b=0x%0h op=%s",
                            req.a, req.b, req.op.name()), UVM_MEDIUM);
        end

    endtask

endclass

`endif