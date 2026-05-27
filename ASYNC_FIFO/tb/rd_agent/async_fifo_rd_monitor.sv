class async_fifo_rd_monitor extends uvm_monitor;

    `uvm_component_utils(async_fifo_rd_monitor)

    virtual async_fifo_if vif;
    async_fifo_rd_tr cov_tr;

    uvm_analysis_port #(async_fifo_rd_tr) ap;

    covergroup cg;
        option.per_instance = 1;

        rd_cp: coverpoint cov_tr.rd_en {
            bins rd_off = {0};
            bins rd_on  = {1};
        }

        empty_cp: coverpoint cov_tr.empty {
            bins not_empty = {0};
            bins empty = {1};
        }

        rd_empty_cross: cross rd_cp, empty_cp;
    endgroup

    function new(string name = "async_fifo_rd_monitor", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_RD_MON", "Failed to get virtual interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        
        async_fifo_rd_tr tr;

        forever begin
            @(posedge vif.rd_clk);
            #1step;

            if (!vif.rd_rstn) begin
                continue;
            end

            tr = async_fifo_rd_tr::type_id::create("tr");

            tr.rd_en = vif.rd_en;
            tr.rd_data = vif.rd_data;
            tr.empty = vif.empty;

            cov_tr = tr;
            cg.sample();

            `uvm_info("ASYNC_FIFO_RD_MON",
                $sformatf("RD sample item: rd_en=%0b rd_data=0x%0h empty=%0b", 
                    tr.rd_en, tr.rd_data, tr.empty),
                    UVM_MEDIUM)

            ap.write(tr);
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("ASYNC_FIFO_RD_COV",
            $sformatf("ASYNC_FIFO_RD functional coverage = %.2f%%", cg.get_coverage()),
            UVM_LOW)
    endfunction

endclass