`ifndef ALU_TEST_SV
`define ALU_TEST_SV

class alu_test extends uvm_test;

    `uvm_component_utils(alu_test)
    
    alu_env env;
    alu_sequence seq;

    function new(string name = "alu_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = alu_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        repeat (1) @(posedge env.agent.monitor.vif.clk);
        phase.drop_objection(this);

    endtask
    
endclass

`endif