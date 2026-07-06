`uvm_analysis_imp_decl(_xbar_cov_slv0)
`uvm_analysis_imp_decl(_xbar_cov_slv1)
`uvm_analysis_imp_decl(_xbar_cov_mst0)
`uvm_analysis_imp_decl(_xbar_cov_mst1)

class axi_lite_xbar_cov extends uvm_component;

    `uvm_component_utils(axi_lite_xbar_cov)

    uvm_analysis_imp_xbar_cov_slv0 #(axi_lite_tr, axi_lite_xbar_cov) slv0_imp;
    uvm_analysis_imp_xbar_cov_slv1 #(axi_lite_tr, axi_lite_xbar_cov) slv1_imp;
    uvm_analysis_imp_xbar_cov_mst0 #(axi_lite_tr, axi_lite_xbar_cov) mst0_imp;
    uvm_analysis_imp_xbar_cov_mst1 #(axi_lite_tr, axi_lite_xbar_cov) mst1_imp;

    axi_lite_cmd_e cov_cmd;
    int unsigned cov_slv_port;
    int unsigned cov_expected_mst_port;
    int unsigned cov_observed_mst_port;
    bit cov_route_match;
    bit [1:0] cov_resp;

    covergroup upstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        slv_port_cp: coverpoint cov_slv_port {
            bins slv0 = {0};
            bins slv1 = {1};
        }

        expected_mst_port_cp: coverpoint cov_expected_mst_port {
            bins mst0 = {0};
            bins mst1 = {1};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_slv_mst_cross: cross cmd_cp, slv_port_cp, expected_mst_port_cp;
    endgroup

    covergroup downstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        observed_mst_port_cp: coverpoint cov_observed_mst_port {
            bins mst0 = {0};
            bins mst1 = {1};
        }

        route_match_cp: coverpoint cov_route_match {
            bins match = {1'b1};
            ignore_bins mismatch = {1'b0};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_observed_mst_cross: cross cmd_cp, observed_mst_port_cp;
        route_observed_mst_cross: cross route_match_cp, observed_mst_port_cp;
    endgroup

    function new(string name = "axi_lite_xbar_cov", uvm_component parent);
        super.new(name, parent);
        upstream_cg = new();
        downstream_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        slv0_imp = new("slv0_imp", this);
        slv1_imp = new("slv1_imp", this);
        mst0_imp = new("mst0_imp", this);
        mst1_imp = new("mst1_imp", this);
    endfunction

    virtual function int unsigned route_port(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        if ((addr >= AXI_LITE_XBAR_MST1_BASE) &&
            (addr < (AXI_LITE_XBAR_MST1_BASE + AXI_LITE_XBAR_REGION_SIZE))) begin
            return 1;
        end
        return 0;
    endfunction

    virtual function void sample_upstream(int unsigned slv_port, axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_slv_port = slv_port;
        cov_expected_mst_port = route_port(tr.addr);
        cov_resp = tr.resp;
        upstream_cg.sample();
    endfunction

    virtual function void sample_downstream(int unsigned observed_mst_port, axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_expected_mst_port = route_port(tr.addr);
        cov_observed_mst_port = observed_mst_port;
        cov_route_match = (observed_mst_port == cov_expected_mst_port);
        cov_resp = tr.resp;
        downstream_cg.sample();
    endfunction

    virtual function void write_xbar_cov_slv0(axi_lite_tr tr);
        sample_upstream(0, tr);
    endfunction

    virtual function void write_xbar_cov_slv1(axi_lite_tr tr);
        sample_upstream(1, tr);
    endfunction

    virtual function void write_xbar_cov_mst0(axi_lite_tr tr);
        sample_downstream(0, tr);
    endfunction

    virtual function void write_xbar_cov_mst1(axi_lite_tr tr);
        sample_downstream(1, tr);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        real total_cov;

        super.report_phase(phase);
        total_cov = (upstream_cg.get_coverage() + downstream_cg.get_coverage()) / 2.0;

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("AXI-Lite xbar functional coverage = %.2f%%", total_cov),
            UVM_LOW)

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("upstream_cg = %.2f%%", upstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("downstream_cg = %.2f%%", downstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("cmd_slv_mst_cross = %.2f%%",
                upstream_cg.cmd_slv_mst_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("cmd_observed_mst_cross = %.2f%%",
                downstream_cg.cmd_observed_mst_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_XBAR_COV",
            $sformatf("route_observed_mst_cross = %.2f%%",
                downstream_cg.route_observed_mst_cross.get_coverage()),
            UVM_LOW)
    endfunction

endclass
