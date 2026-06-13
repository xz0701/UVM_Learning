class axi_lite_sequencer extends uvm_sequencer #(axi_lite_seq);

    `uvm_component_utils(async_lite_sequencer)

    function new(string name = "async_lite_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass