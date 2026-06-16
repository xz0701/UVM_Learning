class axi_lite_cov extends uvm_component;

    `uvm_component_utils(axi_lite_cov)

    uvm_analysis_imp #(axi_lite_tr, axi_lite_cov) analysis_imp;

    axi_lite_tr cov_tr;

    covergroup cg;
        option.per_instance = 1;

        cmd_cp: coverpoint cov_tr.cmd {
            bins read  = {AXI_LITE_READ};
            bins write = {AXI_LITE_WRITE};
        }

        addr_cp: coverpoint cov_tr.addr {
            bins addr_00 = {32'h0000_0000};
            bins addr_04 = {32'h0000_0004};
            bins addr_08 = {32'h0000_0008};
            bins addr_0c = {32'h0000_000c};
            bins addr_10 = {32'h0000_0010};
            bins addr_14 = {32'h0000_0014};
            bins addr_18 = {32'h0000_0018};
            bins addr_1c = {32'h0000_001c};
            bins others  = default;
        }

        strb_cp: coverpoint cov_tr.strb iff (cov_tr.cmd == AXI_LITE_WRITE) {
            bins full      = {4'hf};
            bins byte0     = {4'b0001};
            bins byte1     = {4'b0010};
            bins byte2     = {4'b0100};
            bins byte3     = {4'b1000};
            bins half_low  = {4'b0011};
            bins half_high = {4'b1100};
            bins partial[] = {[4'h1:4'he]};
        }

        resp_cp: coverpoint cov_tr.resp {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }

        wdata_cp: coverpoint cov_tr.data iff (cov_tr.cmd == AXI_LITE_WRITE) {
            bins zero     = {32'h0000_0000};
            bins all_ones = {32'hffff_ffff};
            bins alt_a    = {32'haaaa_aaaa};
            bins alt_5    = {32'h5555_5555};
            bins others   = default;
        }

        rdata_cp: coverpoint cov_tr.rdata iff (cov_tr.cmd == AXI_LITE_READ) {
            bins zero     = {32'h0000_0000};
            bins all_ones = {32'hffff_ffff};
            bins alt_a    = {32'haaaa_aaaa};
            bins alt_5    = {32'h5555_5555};
            bins others   = default;
        }

        cmd_addr_cross: cross cmd_cp, addr_cp;
        addr_strb_cross: cross addr_cp, strb_cp;
        cmd_resp_cross: cross cmd_cp, resp_cp;

    endgroup

    function new(string name = "axi_lite_cov", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_imp = new("analysis_imp", this);
    endfunction

    virtual function void write(axi_lite_tr tr);
        cov_tr = tr;
        cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("AXI_LITE_COV",
            $sformatf("AXI-Lite functional coverage = %.2f%%", cg.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("cmd_addr_cross = %.2f%%", cg.cmd_addr_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("addr_strb_cross = %.2f%%", cg.addr_strb_cross.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("cmd_resp_cross = %.2f%%", cg.cmd_resp_cross.get_coverage()),
            UVM_LOW)
    endfunction

endclass
