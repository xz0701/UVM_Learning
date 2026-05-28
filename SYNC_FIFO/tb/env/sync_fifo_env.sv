`ifndef SYNC_FIFO_ENV_SV
`define SYNC_FIFO_ENV_SV

class sync_fifo_env extends uvm_env;
    `uvm_component_utils(sync_fifo_env)

    sync_fifo_agent      agent;
    sync_fifo_scoreboard scb;

    function new(string name = "sync_fifo_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent = sync_fifo_agent::type_id::create("agent", this);
        scb   = sync_fifo_scoreboard::type_id::create("scb", this);

    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.ap.connect(scb.imp);

    endfunction

endclass

`endif