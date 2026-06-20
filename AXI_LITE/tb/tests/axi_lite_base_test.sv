class axi_lite_base_test extends uvm_test;

    `uvm_component_utils(axi_lite_base_test)

    axi_lite_env env;
    axi_lite_ctrl_vif_t ctrl_vif;

    function new(string name = "axi_lite_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_lite_env::type_id::create("env", this);

        if (!uvm_config_db #(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_BASE_TEST", "Failed to get control virtual interface")
        end
    endfunction

    virtual task wait_cycles(int unsigned cycles = 10);
        repeat (cycles) @(posedge ctrl_vif.clk);
    endtask

endclass
