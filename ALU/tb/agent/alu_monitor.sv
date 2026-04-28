`ifndef ALU_MONITOR_SV
`define ALU_MONITOR_SV

class alu_monitor extends uvm_component;

    `uvm_component_utils(alu_monitor)
    
    alu_item cov_item;
    
    covergroup cg;

        option.per_instance = 1;

        op_cp: coverpoint cov_item.op {
            bins add    = {ALU_ADD};
            bins sub    = {ALU_SUB};
            bins and_op = {ALU_AND};
            bins or_op  = {ALU_OR};
            bins xor_op = {ALU_XOR};
            bins sll    = {ALU_SLL};
            bins srl    = {ALU_SRL};
            bins slt    = {ALU_SLT};
        }

        a_cp: coverpoint cov_item.a{
            bins zero = {8'h00};
            bins one = {8'h01};
            bins max = {8'hff};
            bins others = default;
        }

         b_cp: coverpoint cov_item.b{
            bins zero = {8'h00};
            bins one = {8'h01};
            bins max = {8'hff};
            bins others = default;
        }

        op_a_cross: cross op_cp, a_cp;
        op_b_cross: cross op_cp, b_cp;

    endgroup

    virtual alu_if vif;

    uvm_analysis_port #(alu_item) ap;

    function new(string name = "alu_monitor", uvm_component parent);
        super.new(name, parent);
        cg = new();
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

            cov_item = item;
            cg.sample();

            `uvm_info("ALU_MON",
                    $sformatf("Sample item: a=0x%0h b=0x%0h op=%s out=0x%0h",
                        item.a, item.b, item.op.name(), item.out),
                        UVM_MEDIUM);

            ap.write(item);
        end

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("ALU_COV",
                $sformatf("ALU functional coverage = %.2f%%", cg.get_coverage()),
                UVM_LOW)
    endfunction

endclass
 
`endif