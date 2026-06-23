class axi_lite_cov extends uvm_component;

    `uvm_component_utils(axi_lite_cov)

    uvm_analysis_imp #(axi_lite_tr, axi_lite_cov) analysis_imp;

    axi_lite_tr cov_tr;
    bit [1:0] cov_ro_kind;

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
        }

        strb_cp: coverpoint cov_tr.strb iff (cov_tr.cmd == AXI_LITE_WRITE) {
            bins full       = {4'hf};
            bins single[]   = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
            bins half[]     = {4'b0011, 4'b1100};
            bins sparse[]   = {4'b0101, 4'b1010};
            bins partial[]  = {4'b0110, 4'b0111, 4'b1001, 4'b1011, 4'b1101, 4'b1110};
        }

        resp_cp: coverpoint cov_tr.resp {
            bins okay   = {AXI_LITE_RESP_OKAY};
            bins slverr = {AXI_LITE_RESP_SLVERR};
            ignore_bins reserved_or_unused = {2'b01, 2'b11};
        }

        prot_cp: coverpoint cov_tr.prot {
            option.weight = 0;
            bins user_nonsecure = {3'b000};
`ifdef AXI_LITE_PROT_TEST
            bins priv_only      = {3'b001};
            bins secure_only    = {3'b010};
            bins priv_secure    = {3'b011};
            bins bit2_set[]     = {[3'b100:3'b111]};
`else
            ignore_bins disabled_prot_bins = {[3'b001:3'b111]};
`endif
        }

        ro_kind_cp: coverpoint cov_ro_kind iff (cov_tr.cmd == AXI_LITE_WRITE) {
            option.weight = 0;
            bins no_read_only = {2'd0};
`ifdef AXI_LITE_READ_ONLY_TEST
            bins read_only_only = {2'd1};
            bins mixed = {2'd2};
`else
            ignore_bins disabled_ro_bins = {2'd1, 2'd2};
`endif
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

        wr_order_cp: coverpoint cov_tr.wr_order iff (cov_tr.cmd == AXI_LITE_WRITE) {
            bins same_cycle  = {AXI_LITE_AW_W_SAME};
            bins aw_before_w = {AXI_LITE_AW_BEFORE_W};
            bins w_before_aw = {AXI_LITE_W_BEFORE_AW};
        }

        b_wait_cp: coverpoint cov_tr.b_wait_cycles iff (cov_tr.cmd == AXI_LITE_WRITE) {
            bins no_wait = {0};
            bins short   = {[1:2]};
            bins long    = {[3:8]};
        }

        r_wait_cp: coverpoint cov_tr.r_wait_cycles iff (cov_tr.cmd == AXI_LITE_READ) {
            bins no_wait = {0};
            bins short   = {[1:2]};
            bins long    = {[3:8]};
        }

        cmd_addr_cross: cross cmd_cp, addr_cp;
        addr_strb_cross: cross addr_cp, strb_cp;
        cmd_resp_cross: cross cmd_cp, resp_cp;
        wr_order_strb_cross: cross wr_order_cp, strb_cp;
        prot_resp_cross: cross prot_cp, resp_cp {
            option.weight = 0;
        }
        ro_kind_resp_cross: cross ro_kind_cp, resp_cp {
            option.weight = 0;
        }

    endgroup

    function new(string name = "axi_lite_cov", uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_imp = new("analysis_imp", this);
    endfunction

    virtual function bit [1:0] calc_read_only_kind(axi_lite_tr tr);
        bit saw_read_only;
        bit saw_writable;
        bit [AXI_LITE_REG_ADDR_WIDTH-1:0] eff_addr;

        if (tr.cmd != AXI_LITE_WRITE) begin
            return 2'd0;
        end

        eff_addr = tr.addr[AXI_LITE_REG_ADDR_WIDTH-1:0];

        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            if (tr.strb[i] && ((eff_addr + i) < AXI_LITE_REG_NUM_BYTES)) begin
                if (AXI_LITE_READ_ONLY_MASK[eff_addr + i]) begin
                    saw_read_only = 1'b1;
                end else begin
                    saw_writable = 1'b1;
                end
            end
        end

        if (saw_read_only && saw_writable) begin
            return 2'd2;
        end

        if (saw_read_only) begin
            return 2'd1;
        end

        return 2'd0;
    endfunction

    virtual function void write(axi_lite_tr tr);
        cov_tr = tr;
        cov_ro_kind = calc_read_only_kind(tr);
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

        `uvm_info("AXI_LITE_COV",
            $sformatf("wdata_cp = %.2f%%", cg.wdata_cp.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("rdata_cp = %.2f%%", cg.rdata_cp.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("wr_order_cp = %.2f%%", cg.wr_order_cp.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("b_wait_cp = %.2f%%", cg.b_wait_cp.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("r_wait_cp = %.2f%%", cg.r_wait_cp.get_coverage()),
            UVM_LOW)

        `uvm_info("AXI_LITE_COV",
            $sformatf("wr_order_strb_cross = %.2f%%", cg.wr_order_strb_cross.get_coverage()),
            UVM_LOW)

        if (AXI_LITE_READ_ONLY_MASK != '0) begin
            `uvm_info("AXI_LITE_COV",
                $sformatf("ro_kind_cp = %.2f%%", cg.ro_kind_cp.get_coverage()),
                UVM_LOW)

            `uvm_info("AXI_LITE_COV",
                $sformatf("ro_kind_resp_cross = %.2f%%", cg.ro_kind_resp_cross.get_coverage()),
                UVM_LOW)
        end

        if (AXI_LITE_PRIV_PROT_ONLY || AXI_LITE_SECU_PROT_ONLY) begin
            `uvm_info("AXI_LITE_COV",
                $sformatf("prot_cp = %.2f%%", cg.prot_cp.get_coverage()),
                UVM_LOW)

            `uvm_info("AXI_LITE_COV",
                $sformatf("prot_resp_cross = %.2f%%", cg.prot_resp_cross.get_coverage()),
                UVM_LOW)
        end
    endfunction

endclass
