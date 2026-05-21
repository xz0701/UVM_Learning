`ifndef SYNC_FIFO_AGENT_SV
`define SYNC_FIFO_AGENT_SV

class sync_fifo_agent extends uvm_agent;

    `uvm_component_utils(sync_fifo_agent)

    sync_fifo_sequencer sequencer;
    sync_fifo_driver    driver;
    sync_fifo_monitor   monitor;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    function new(string name = "sync_fifo_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor   = sync_fifo_monitor::type_id::create("monitor", this);
        if (!uvm_config_db(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
            is_active = UVM_ACTIVE;
        
        if (is_active == UVM_ACTIVE) begin
            sequencer = sync_fifo_sequencer::type_id::create("sequencer", this);
            driver    = sync_fifo_driver::type_id::create("driver", this);
        end
        

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        if (is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);

    endfunction

endclass

`endif