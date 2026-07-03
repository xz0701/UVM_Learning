class axi_lite_mux_env extends uvm_env;

    `uvm_component_utils(axi_lite_mux_env)

    axi_lite_agent agt [AXI_LITE_MUX_NUM_SLV];
    axi_lite_monitor downstream_mon;
    axi_lite_mux_scoreboard scb;
    axi_lite_mux_cov cov;

    function new(string name = "axi_lite_mux_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        for (int unsigned i = 0; i < AXI_LITE_MUX_NUM_SLV; i++) begin
            agt[i] = axi_lite_agent::type_id::create($sformatf("agt_%0d", i), this);
        end
        downstream_mon = axi_lite_monitor::type_id::create("downstream_mon", this);
        scb = axi_lite_mux_scoreboard::type_id::create("scb", this);
        cov = axi_lite_mux_cov::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agt[0].monitor.ap.connect(scb.slv0_imp);
        agt[1].monitor.ap.connect(scb.slv1_imp);
        downstream_mon.ap.connect(scb.downstream_imp);

        agt[0].monitor.ap.connect(cov.slv0_imp);
        agt[1].monitor.ap.connect(cov.slv1_imp);
        downstream_mon.ap.connect(cov.downstream_imp);
    endfunction

endclass
