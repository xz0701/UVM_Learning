`ifndef ALU_SEQUENCE_SV
`define ALU_SEQUENCE_SV

class alu_sequence extends uvm_sequence #(alu_item);
    `uvm_object_utils(alu_sequence)

    function new(string name = "alu_sequence");
        super.new(name);
    endfunction

    virtual task body ();
        alu_item req;
        alu_op_e ops[$] = '{ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, 
                            ALU_XOR, ALU_SLL, ALU_SRL, ALU_SLT};
        logic [7:0] vals[$] = '{8'h00, 8'h01, 8'hff};

        // 1. Random Test
        repeat(100) begin
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

        // 2. Directed corner test: op x a corner
        foreach (ops[i]) begin
            foreach (vals[j]) begin
                req = alu_item::type_id::create("req");

                start_item(req);

                req.a  = vals[j];
                req.b  = 8'h55;
                req.op = ops[i];

                finish_item(req);
            end
        end

        // 3. Directed corner test: op x b corner
        foreach (ops[i]) begin
            foreach (vals[j]) begin
                req = alu_item::type_id::create("req");

                start_item(req);

                req.a  = 8'haa;
                req.b  = vals[j];
                req.op = ops[i];

                finish_item(req);
            end
        end

    endtask

endclass

`endif