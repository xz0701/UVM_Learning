`ifndef SYNC_FIFO_MONITOR_SV
`define SYNC_FIFO_MONITOR_SV

class sync_fifo_monitor extends uvm_component;

    `uvm_component_utils(sync_fifo_monitor)
    
    sync_fifo_transaction cov_tr;
    
    virtual sync_fifo_if vif;
    bit prev_full;
    bit prev_empty;

    uvm_analysis_port #(sync_fifo_transaction) ap;

    covergroup cg;

        option.per_instance = 1;

        rd_cp: coverpoint cov_tr.rd_en {
            bins rd_off = {0};
            bins rd_on  = {1};
        }

        wr_cp: coverpoint cov_tr.wr_en {
            bins wr_off = {0};
            bins wr_on  = {1};
        }

        full_cp: coverpoint cov_tr.full {
            bins not_full = {0};
            bins full     = {1};
        }

        empty_cp: coverpoint cov_tr.empty {
            bins not_empty = {0};
            bins empty     = {1};
        }

        wr_rd_cross:    cross wr_cp, rd_cp;
        full_wr_cross:  cross wr_cp, full_cp;
        empty_rd_cross: cross rd_cp, empty_cp;
        scenario_cp: coverpoint {prev_empty, prev_full, cov_tr.rd_en, cov_tr.wr_en} {
            bins normal_idle  = {4'b0000};
            bins empty_idle   = {4'b1000};
            bins normal_write = {4'b0001};
            bins normal_read  = {4'b0010};
            bins normal_rw    = {4'b0011};
            bins empty_read   = {4'b1010};
            bins empty_rw     = {4'b1011};
            bins full_write   = {4'b0101};
            bins full_rw      = {4'b0111};
        }

    endgroup


    function new(string name = "sync_fifo_monitor", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual sync_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SYNC_FIFO_MON", "Failed to get virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);
        
        sync_fifo_transaction tr;

        forever begin
            @(posedge vif.clk);
            #1step;

            if (!vif.rst_n) begin
                continue;
            end

            tr = sync_fifo_transaction::type_id::create("tr");

            tr.rd_en   = vif.rd_en;
            tr.wr_en   = vif.wr_en;
            tr.wr_data = vif.wr_data;
            tr.rst_n   = vif.rst_n;
            tr.rd_data = vif.rd_data;
            tr.full    = vif.full;
            tr.empty   = vif.empty;

            cov_tr = tr;
            cg.sample();

            prev_full  = vif.full;
            prev_empty = vif.empty;

            `uvm_info("SYNC_FIFO_MON",
                    $sformatf("Sample item: rd_en=%0b rd_data=0x%0h empty=%0b wr_en=%0b wr_data=0x%0h full=%0b",
                            tr.rd_en, tr.rd_data, tr.empty, 
                            tr.wr_en, tr.wr_data, tr.full),
                            UVM_MEDIUM)

            ap.write(tr);
        end

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SYNC_FIFO_COV",
                $sformatf("SYNC_FIFO functional coverage = %.2f%%", cg.get_coverage()),
                UVM_LOW)
    endfunction

endclass
 
`endif