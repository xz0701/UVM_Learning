class async_fifo_wr_monitor extends uvm_monitor;

    `uvm_component_utils(async_fifo_wr_monitor)

    async_fifo_wr_tr cov_tr;
    virtual async_fifo_if vif;

    uvm_analysis_port #(async_fifo_wr_tr) ap;
    
    covergroup cg;
        option.per_instance = 1;

        wr_cp: coverpoint cov_tr.wr_en {
            bins wr_off = {0};
            bins wr_on  = {1};
        }

        full_cp: coverpoint cov_tr.full {
            bins not_full = {0};
            bins full = {1};
        }

        wr_full_cross: cross wr_cp, full_cp;
    endgroup

    function new(string name = "async_fifo_wr_moniter", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_WR_MON", "Failed to get virtual interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);

        async_fifo_wr_tr tr;

        forever begin
            @(posedge vif.wr_clk);
            #1step;

            if (!vif.wr_rstn) begin
                continue;
            end

            tr = async_fifo_wr_tr::type_id::create("tr");

            tr.wr_en = vif.wr_en;
            tr.wr_data = vif.wr_data;
            tr.full = vif.full;

            cov_tr = tr;
            cg.sample();

            `uvm_info("ASYNC_FIFO_WR_MON",
                $sformatf("WR sample item: wr_en=%0b wr_data=0x%0h full=%0b", 
                    tr.wr_en, tr.wr_data, tr.full),
                    UVM_MEDIUM)

            ap.write(tr);
            
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("ASYNC_FIFO_WR_COV",
            $sformatf("ASYNC_FIFO_WR functional coverage = %.2f%%", cg.get_coverage()),
            UVM_LOW)
    endfunction

endclass