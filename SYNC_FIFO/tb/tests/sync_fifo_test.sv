`ifndef SYNC_FIFO_TEST_SV
`define SYNC_FIFO_TEST_SV

class sync_fifo_test extends uvm_test;

    `uvm_component_utils(sync_fifo_test)
    
    sync_fifo_env env;
    sync_fifo_sequence seq;
    virtual sync_fifo_if vif;

    function new(string name = "sync_fifo_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = sync_fifo_env::type_id::create("env", this);

        if (!uvm_config_db#(virtual sync_fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("SYNC_FIFO_TEST", "Failed to get virtual interface")
        end

        uvm_config_db#(uvm_active_passive_enum)::set(
            this,
            "env.agent",
            "is_active",
            UVM_ACTIVE
        );
    endfunction

    virtual task run_phase(uvm_phase phase);
    
        phase.raise_objection(this);
        seq = sync_fifo_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        repeat (5) @(posedge env.agent.monitor.vif.clk);
        phase.drop_objection(this);

    endtask
    
endclass

`endif