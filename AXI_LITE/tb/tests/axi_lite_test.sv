class axi_lite_test extends uvm_test;
    `uvm_component_utils(axi_lite_test)

    axi_lite_env env;
    axi_lite_seq seq;
    axi_lite_ctrl_vif_t ctrl_vif;

    function new(string name = "axi_lite_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_lite_env::type_id::create("env", this);

        if (!uvm_config_db #(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_TEST", "Failed to get control virtual interface")
        end

    endfunction

    virtual task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        seq = axi_lite_seq::type_id::create("seq");

        seq.start(env.agt.sequencer);

        repeat (10) @(posedge ctrl_vif.clk);

        phase.drop_objection(this);
    endtask
endclass
