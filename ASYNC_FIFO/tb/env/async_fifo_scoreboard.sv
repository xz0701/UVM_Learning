`uvm_analysis_imp_decl(_wr)
`uvm_analysis_imp_decl(_rd)

class async_fifo_scoreboard extends uvm_component;

    `uvm_component_utils(async_fifo_scoreboard)

    uvm_analysis_imp_wr #(async_fifo_wr_tr, async_fifo_scoreboard) wr_imp;
    uvm_analysis_imp_rd #(async_fifo_rd_tr, async_fifo_scoreboard) rd_imp;

    bit [WIDTH-1:0] model_q[$];

    virtual async_fifo_if vif;

    function new(string name = "async_fifo_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        wr_imp = new("wr_imp", this);
        rd_imp = new("rd_imp", this);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_SCB", "Failed to get virtual interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge vif.wr_rstn or negedge vif.rd_rstn);
            model_q.delete();
            
            `uvm_info("ASYNC_FIFO_SCB",
                "Reset detected, model queue cleared",
                UVM_LOW)
        end
    endtask

    virtual function void write_wr(async_fifo_wr_tr tr);

        if (!vif.wr_rstn) begin
            return;
        end

        if (tr.wr_accept) begin
            model_q.push_back(tr.wr_data);

            `uvm_info("ASYNC_FIFO_SCB",
                $sformatf("Model Push: 0x%0h depth=%0d",
                        tr.wr_data, model_q.size()),
                UVM_MEDIUM)
        end
        else if (tr.wr_en) begin
            `uvm_info("ASYNC_FIFO_SCB",
                "Write ignored because write side was full before edge",
                UVM_MEDIUM)
        end

    endfunction

    virtual function void write_rd(async_fifo_rd_tr tr_rd);
        bit [WIDTH-1:0] exp_data;

        if (!vif.rd_rstn) begin
            return;
        end

        if (model_q.size() == 0) begin
            `uvm_error("ASYNC_FIFO_SCB",
                "Model queue underflow: read data returned but model is empty")
            return;
        end

        exp_data = model_q.pop_front();

        if (tr_rd.rd_data !== exp_data) begin
            `uvm_error("ASYNC_FIFO_SCB",
                $sformatf("Data mismatch: expected=0x%0h actual=0x%0h",
                        exp_data, tr_rd.rd_data))
        end
    endfunction
endclass