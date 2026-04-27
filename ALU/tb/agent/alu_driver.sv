`ifndef ALU_DRIVER_SV
`define ALU_DRIVER_SV

class alu_driver extends uvm_driver #(alu_item);

    `uvm_component_utils(alu_driver)

    virtual alu_if vif;

    function new(string name = "alu_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ALU_DRV", "Failed to get virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);

    alu_item req;

    forever begin
        seq_item_port.get_next_item(req);

        @(posedge vif.clk);
        vif.a <= req.a;
        vif.b <= req.b;
        vif.op <= req.op;

        `uvm_info("ALU_DRV",
            $sformatf("Drive item: a=0x%0h b=0x%0h op=%s",
                        req.a, req.b, req.op.name()),
                        UVM_MEDIUM)
        
        seq_item_port.item_done();
    end

    endtask

endclass

`endif