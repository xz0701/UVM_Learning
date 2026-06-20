class axi_lite_full_cov_test extends axi_lite_base_test;

    `uvm_component_utils(axi_lite_full_cov_test)

    function new(string name = "axi_lite_full_cov_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_lite_full_cov_seq seq;

        phase.raise_objection(this);

        seq = axi_lite_full_cov_seq::type_id::create("seq");
        seq.start(env.agt.sequencer);
        wait_cycles();

        phase.drop_objection(this);
    endtask

endclass
