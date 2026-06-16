class axi_lite_env extends uvm_env;

    `uvm_component_utils(axi_lite_env)

    axi_lite_agent agt;
    axi_lite_scoreboard scb;
    axi_lite_cov cov;

    function new(string name = "axi_lite_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt = axi_lite_agent::type_id::create("agt", this);
        scb = axi_lite_scoreboard::type_id::create("scb", this);
        cov = axi_lite_cov::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.monitor.ap.connect(scb.analysis_imp);
        agt.monitor.ap.connect(cov.analysis_imp);
    endfunction

endclass
