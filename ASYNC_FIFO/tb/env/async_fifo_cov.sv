class async_fifo_cov extends uvm_component;

    `uvm_component_utils(async_fifo_cov)

    virtual async_fifo_if vif;

    bit wr_en_s;
    bit rd_en_s;
    bit full_s;
    bit empty_s;

    covergroup cg;
        option.per_instance = 1;

        wr_cp: coverpoint wr_en_s {
            bins off = {0};
            bins on  = {1};
        }

        rd_cp: coverpoint rd_en_s {
            bins off = {0};
            bins on  = {1};
        }

        full_cp: coverpoint full_s {
            bins not_full = {0};
            bins full     = {1};
        }

        empty_cp: coverpoint empty_s {
            bins not_empty = {0};
            bins empty     = {1};
        }

        wr_rd_cross: cross wr_cp, rd_cp;

        boundary_cross: cross wr_cp, rd_cp, full_cp, empty_cp {
            ignore_bins illegal_full_empty =
                binsof(full_cp.full) && binsof(empty_cp.empty);
        }

    endgroup

    function new(string name = "async_fifo_cov", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_COV", "Failed to get virtual interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.wr_clk);
            #1step;

            if (!vif.wr_rstn || !vif.rd_rstn) begin
                continue;
            end

            wr_en_s = vif.wr_en;
            rd_en_s = vif.rd_en;
            full_s  = vif.full;
            empty_s = vif.empty;

            cg.sample();
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("ASYNC_FIFO_GLOBAL_COV",
            $sformatf("ASYNC_FIFO global functional coverage = %.2f%%", cg.get_coverage()),
            UVM_LOW)

        `uvm_info("ASYNC_FIFO_GLOBAL_COV",
            $sformatf("wr_rd_cross = %.2f%%", cg.wr_rd_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("ASYNC_FIFO_GLOBAL_COV",
            $sformatf("boundary_cross = %.2f%%", cg.boundary_cross.get_coverage()),
            UVM_LOW)
    endfunction

endclass