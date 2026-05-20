`ifndef SYNC_FIFO_SEQUENCER_SV
`define SYNC_FIFO_SEQUENCER_SV

class sync_fifo_sequencer extends uvm_sequencer #(sync_fifo_transaction);

    `uvm_component_utils(sync_fifo_sequencer)

    function new(string name = "sync_fifo_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass

`endif