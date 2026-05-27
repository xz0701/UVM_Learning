class async_fifo_rd_driver extends uvm_driver #(async_fifo_rd_tr);

    `uvm_component_utils(async_fifo_rd_driver);

    virtual async_fifo_if vif;

    function new(string name = "async_fifo_rd_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_RD_DRV", "Failed to get virtual interface");
        end
    endfunction

    virtual task wait_reset_release();
        wait (vif.rd_rstn == 1'b1);
        repeat (2) @(posedge vif.rd_clk);
    endtask

    virtual task run_phase(uvm_phase phase);
        
        async_fifo_rd_tr tr;

        vif.rd_en <= 1'b0;
    
        wait_reset_release();

        forever begin
            seq_item_port.get_next_item(tr);

            @(negedge vif.rd_clk);
            vif.rd_en <= tr.rd_en;

            `uvm_info("ASYNC_FIFO_RD_DRV",
                $sformatf("RD Drive item: rd_en=%0b", tr.rd_en), UVM_MEDIUM);

            seq_item_port.item_done();
        end
    endtask
endclass