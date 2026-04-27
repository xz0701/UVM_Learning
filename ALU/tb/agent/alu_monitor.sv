`ifndef ALU_MONITOR_SV
`define ALU_MONITOR_SV

class alu_monitor extends uvm_component;

    `uvm_component_utils(alu_monitor)

    virtual alu_if vif;

    uvm_analysis_port #(alu_item) ap;

    function new(string name = "alu_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ALU_MON", "Failed to get virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);
        alu_item item;

        forever begin
            @(posedge vif.clk);
            #1step;

            item = alu_item::type_id::create("item");

            item.a = vif.a;
            item.b = vif.b;
            item.op = vif.op;
            item.out = vif.out;

            `uvm_info("ALU_MON",
                    $sformatf("Sample item: a=0x%0h b=0x%0h op=%s out=0%0h",
                        item.a, item.b, item.op.name(), item.out),
                        UVM_MEDIUM);

            ap.write(item);
        end

    endtask

endclass
 
`endif