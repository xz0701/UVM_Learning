`ifndef SYNC_FIFO_DRIVER_SV
`define SYNC_FIFO_DRIVER_SV

class sync_fifo_driver extends uvm_driver #(sync_fifo_transaction);

    `uvm_component_utils(sync_fifo_driver)

    virtual sync_fifo_if vif;

    function new(string name = "sync_fifo_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual sync_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SYNC_FIFO_DRV", "Failed to get virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);

        sync_fifo_transaction tr;

        vif.rd_en   <= 1'b0;
        vif.wr_en   <= 1'b0;
        vif.wr_data <= '0;

        forever begin

            seq_item_port.get_next_item(tr);

            @(posedge vif.clk);
            vif.rd_en   <= tr.rd_en;
            vif.wr_en   <= tr.wr_en;
            vif.wr_data <= tr.wr_data;

            `uvm_info("SYNC_FIFO_DRV",
                $sformatf("Drive item: rd_en=%0b wr_en=%0b wr_data=0x%0h",
                            tr.rd_en, tr.wr_en, tr.wr_data),
                            UVM_MEDIUM)
        
            seq_item_port.item_done();
        end

    endtask

endclass

`endif