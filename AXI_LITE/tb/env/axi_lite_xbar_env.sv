class axi_lite_xbar_env extends uvm_env;

    `uvm_component_utils(axi_lite_xbar_env)

    axi_lite_agent slv_agt [AXI_LITE_XBAR_NUM_SLV];
    axi_lite_monitor mst_mon [AXI_LITE_XBAR_NUM_MST];
    axi_lite_xbar_scoreboard scb;
    axi_lite_xbar_cov cov;

    function new(string name = "axi_lite_xbar_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        for (int unsigned i = 0; i < AXI_LITE_XBAR_NUM_SLV; i++) begin
            slv_agt[i] = axi_lite_agent::type_id::create($sformatf("slv_agt_%0d", i), this);
        end

        for (int unsigned i = 0; i < AXI_LITE_XBAR_NUM_MST; i++) begin
            mst_mon[i] = axi_lite_monitor::type_id::create($sformatf("mst_mon_%0d", i), this);
        end

        scb = axi_lite_xbar_scoreboard::type_id::create("scb", this);
        cov = axi_lite_xbar_cov::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        slv_agt[0].monitor.ap.connect(scb.slv0_imp);
        slv_agt[1].monitor.ap.connect(scb.slv1_imp);
        mst_mon[0].ap.connect(scb.mst0_imp);
        mst_mon[1].ap.connect(scb.mst1_imp);

        slv_agt[0].monitor.ap.connect(cov.slv0_imp);
        slv_agt[1].monitor.ap.connect(cov.slv1_imp);
        mst_mon[0].ap.connect(cov.mst0_imp);
        mst_mon[1].ap.connect(cov.mst1_imp);
    endfunction

endclass
