class axi_lite_mux_smoke_test extends uvm_test;

    `uvm_component_utils(axi_lite_mux_smoke_test)

    axi_lite_mux_env env;
    axi_lite_ctrl_vif_t ctrl_vif;

    function new(string name = "axi_lite_mux_smoke_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_lite_mux_env::type_id::create("env", this);

        if (!uvm_config_db #(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_MUX_TEST", "Failed to get control virtual interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        axi_lite_mux_smoke_seq seq0;
        axi_lite_mux_smoke_seq seq1;

        phase.raise_objection(this);
        seq0 = axi_lite_mux_smoke_seq::type_id::create("seq0");
        seq1 = axi_lite_mux_smoke_seq::type_id::create("seq1");
        seq0.master_id = 0;
        seq1.master_id = 1;

        fork
            seq0.start(env.agt[0].sequencer);
            begin
                repeat (2) @(posedge ctrl_vif.clk);
                seq1.start(env.agt[1].sequencer);
            end
        join

        repeat (30) @(posedge ctrl_vif.clk);
        phase.drop_objection(this);
    endtask

endclass
