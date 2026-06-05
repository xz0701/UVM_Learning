class async_fifo_rd_sequencer extends uvm_sequencer #(async_fifo_rd_tr);

    `uvm_component_utils(async_fifo_rd_sequencer)

    function new(string name = "async_fifo_rd_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass