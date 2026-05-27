class async_fifo_wr_driver extends uvm_driver #(async_fifo_wr_tr);

    `uvm_component_utils(async_fifo_wr_driver)

    virtual async_fifo_if vif;

    function new(string name = "async_fifo_wr_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual async_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("ASYNC_FIFO_WR_DRV", "Failed to get virtual interface");
        end
    endfunction

    virtual task wait_reset_release();
        wait (vif.wr_rstn === 1'b1);
        repeat (2) @(posedge vif.wr_clk);
    endtask

    virtual task run_phase(uvm_phase phase);

        async_fifo_wr_tr tr;
        
        vif.wr_en <= 1'b0;
        vif.wr_data <= '0;

        wait_reset_release();

        forever begin
            seq_item_port.get_next_item(tr);

            @(negedge vif.wr_clk);
            vif.wr_en <= tr.wr_en;
            vif.wr_data <= tr.wr_data;

            `uvm_info("ASYNC_FIFO_WR_DRV",                          
                $sformatf("WR Drive item: wr_en=%0b wr_data=0x%0h",
                    tr.wr_en, tr.wr_data),
                    UVM_MEDIUM)
            
            seq_item_port.item_done();
        end
    endtask
endclass