`uvm_analysis_imp_decl(_demux_cov_upstream)
`uvm_analysis_imp_decl(_demux_cov_mst0)
`uvm_analysis_imp_decl(_demux_cov_mst1)

class axi_lite_demux_cov extends uvm_component;

    `uvm_component_utils(axi_lite_demux_cov)

    uvm_analysis_imp_demux_cov_upstream #(axi_lite_tr, axi_lite_demux_cov) upstream_imp;
    uvm_analysis_imp_demux_cov_mst0 #(axi_lite_tr, axi_lite_demux_cov) mst0_imp;
    uvm_analysis_imp_demux_cov_mst1 #(axi_lite_tr, axi_lite_demux_cov) mst1_imp;

    axi_lite_cmd_e cov_cmd;
    int unsigned cov_expected_port;
    int unsigned cov_observed_port;
    bit cov_route_match;
    bit [1:0] cov_resp;

    covergroup upstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        expected_port_cp: coverpoint cov_expected_port {
            bins port0 = {0};
            bins port1 = {1};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_expected_port_cross: cross cmd_cp, expected_port_cp;
    endgroup

    covergroup downstream_cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        observed_port_cp: coverpoint cov_observed_port {
            bins port0 = {0};
            bins port1 = {1};
        }

        route_match_cp: coverpoint cov_route_match {
            bins match = {1'b1};
            ignore_bins mismatch = {1'b0};
        }

        resp_cp: coverpoint cov_resp {
            bins okay = {AXI_LITE_RESP_OKAY};
        }

        cmd_observed_port_cross: cross cmd_cp, observed_port_cp;
        route_observed_port_cross: cross route_match_cp, observed_port_cp;
    endgroup

    function new(string name = "axi_lite_demux_cov", uvm_component parent);
        super.new(name, parent);
        upstream_cg = new();
        downstream_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        upstream_imp = new("upstream_imp", this);
        mst0_imp = new("mst0_imp", this);
        mst1_imp = new("mst1_imp", this);
    endfunction

    virtual function int unsigned route_port(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        return addr[AXI_LITE_DEMUX_SELECT_ADDR_BIT];
    endfunction

    virtual function void sample_upstream(axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_expected_port = route_port(tr.addr);
        cov_resp = tr.resp;
        upstream_cg.sample();
    endfunction

    virtual function void sample_downstream(int unsigned observed_port, axi_lite_tr tr);
        cov_cmd = tr.cmd;
        cov_expected_port = route_port(tr.addr);
        cov_observed_port = observed_port;
        cov_route_match = (observed_port == cov_expected_port);
        cov_resp = tr.resp;
        downstream_cg.sample();
    endfunction

    virtual function void write_demux_cov_upstream(axi_lite_tr tr);
        sample_upstream(tr);
    endfunction

    virtual function void write_demux_cov_mst0(axi_lite_tr tr);
        sample_downstream(0, tr);
    endfunction

    virtual function void write_demux_cov_mst1(axi_lite_tr tr);
        sample_downstream(1, tr);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        real total_cov;

        super.report_phase(phase);
        total_cov = (upstream_cg.get_coverage() + downstream_cg.get_coverage()) / 2.0;

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("AXI-Lite demux functional coverage = %.2f%%", total_cov),
            UVM_LOW)

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("upstream_cg = %.2f%%", upstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("downstream_cg = %.2f%%", downstream_cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("cmd_expected_port_cross = %.2f%%",
                upstream_cg.cmd_expected_port_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("cmd_observed_port_cross = %.2f%%",
                downstream_cg.cmd_observed_port_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_DEMUX_COV",
            $sformatf("route_observed_port_cross = %.2f%%",
                downstream_cg.route_observed_port_cross.get_coverage()),
            UVM_LOW)
    endfunction

endclass
