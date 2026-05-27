class async_fifo_wr_sequencer extends uvm_sequencer #(async_fifo_wr_tr);

    `uvm_component_utils(async_fifo_wr_sequencer)

    function new(string name = "async_fifo_wr_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass