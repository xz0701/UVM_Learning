`uvm_analysis_imp_decl(_mux_cov_slv0)
`uvm_analysis_imp_decl(_mux_cov_slv1)
`uvm_analysis_imp_decl(_mux_cov_downstream)

class axi_lite_mux_cov extends uvm_component;

    `uvm_component_utils(axi_lite_mux_cov)

    uvm_analysis_imp_mux_cov_slv0 #(axi_lite_tr, axi_lite_mux_cov) slv0_imp;
    uvm_analysis_imp_mux_cov_slv1 #(axi_lite_tr, axi_lite_mux_cov) slv1_imp;
    uvm_analysis_imp_mux_cov_downstream #(axi_lite_tr, axi_lite_mux_cov) downstream_imp;

    axi_lite_cmd_e cov_cmd;
    int unsigned cov_master_id;
    bit cov_downstream;
    bit [1:0] cov_resp;

    covergroup upstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        master_cp: coverpoint cov_master_id {
            bins master0 = {0};
            bins master1 = {1};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_master_cross: cross cmd_cp, master_cp;
    endgroup

    covergroup downstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        downstream_seen_cp: coverpoint cov_downstream {
            bins seen = {1'b1};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_downstream_cross: cross cmd_cp, downstream_seen_cp;
    endgroup

    function new(string name = "axi_lite_mux_cov", uvm_component parent);
        super.new(name, parent);
        upstream_cg = new();
        downstream_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        slv0_imp = new("slv0_imp", this);
        slv1_imp = new("slv1_imp", this);
        downstream_imp = new("downstream_imp", this);
    endfunction

    virtual function void sample_upstream(int unsigned master_id, axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_master_id = master_id;
        cov_resp = tr.resp;
        upstream_cg.sample();
    endfunction

    virtual function void sample_downstream(axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_downstream = 1'b1;
        cov_resp = tr.resp;
        downstream_cg.sample();
    endfunction

    virtual function void write_mux_cov_slv0(axi_lite_tr tr);
        sample_upstream(0, tr);
    endfunction

    virtual function void write_mux_cov_slv1(axi_lite_tr tr);
        sample_upstream(1, tr);
    endfunction

    virtual function void write_mux_cov_downstream(axi_lite_tr tr);
        sample_downstream(tr);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        real total_cov;

        super.report_phase(phase);
        total_cov = (upstream_cg.get_coverage() + downstream_cg.get_coverage()) / 2.0;

        `uvm_info("AXI_LITE_MUX_COV",
            $sformatf("AXI-Lite mux functional coverage = %.2f%%", total_cov),
            UVM_LOW)

        `uvm_info("AXI_LITE_MUX_COV",
            $sformatf("upstream_cg = %.2f%%", upstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_MUX_COV",
            $sformatf("downstream_cg = %.2f%%", downstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_MUX_COV",
            $sformatf("cmd_master_cross = %.2f%%", upstream_cg.cmd_master_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_MUX_COV",
            $sformatf("cmd_downstream_cross = %.2f%%",
                downstream_cg.cmd_downstream_cross.get_coverage()),
            UVM_LOW)
    endfunction

endclass
