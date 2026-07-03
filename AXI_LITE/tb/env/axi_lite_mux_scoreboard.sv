`uvm_analysis_imp_decl(_mux_slv0)
`uvm_analysis_imp_decl(_mux_slv1)
`uvm_analysis_imp_decl(_mux_downstream)

class axi_lite_mux_scoreboard extends uvm_component;

    `uvm_component_utils(axi_lite_mux_scoreboard)

    uvm_analysis_imp_mux_slv0 #(axi_lite_tr, axi_lite_mux_scoreboard) slv0_imp;
    uvm_analysis_imp_mux_slv1 #(axi_lite_tr, axi_lite_mux_scoreboard) slv1_imp;
    uvm_analysis_imp_mux_downstream #(axi_lite_tr, axi_lite_mux_scoreboard) downstream_imp;

    bit [AXI_LITE_DATA_WIDTH-1:0] mem_model [AXI_LITE_MUX_MEM_WORDS];
    int unsigned upstream_checks;
    int unsigned downstream_checks;
    int unsigned read_checks;
    int unsigned error_count;

    function new(string name = "axi_lite_mux_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        slv0_imp = new("slv0_imp", this);
        slv1_imp = new("slv1_imp", this);
        downstream_imp = new("downstream_imp", this);
        clear_model();
    endfunction

    virtual function void clear_model();
        foreach (mem_model[i]) begin
            mem_model[i] = '0;
        end
        upstream_checks = 0;
        downstream_checks = 0;
        read_checks = 0;
        error_count = 0;
    endfunction

    virtual function int unsigned word_index(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        return (addr >> $clog2(AXI_LITE_STRB_WIDTH)) % AXI_LITE_MUX_MEM_WORDS;
    endfunction

    virtual function void update_model(axi_lite_tr tr);
        int unsigned idx;

        idx = word_index(tr.addr);
        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            if (tr.strb[i]) begin
                mem_model[idx][8*i +: 8] = tr.data[8*i +: 8];
            end
        end
    endfunction

    virtual function void check_resp(string where, axi_lite_tr tr);
        if (tr.resp !== AXI_LITE_RESP_OKAY) begin
            error_count++;
            `uvm_error("AXI_LITE_MUX_SCB",
                $sformatf("%s response mismatch: addr=0x%08h resp=0x%0h expected=OKAY",
                    where, tr.addr, tr.resp))
        end
    endfunction

    virtual function void check_upstream(int unsigned master_id, axi_lite_tr tr);
        bit [AXI_LITE_DATA_WIDTH-1:0] expected_data;
        int unsigned idx;

        upstream_checks++;
        idx = word_index(tr.addr);
        check_resp($sformatf("upstream master %0d", master_id), tr);

        if (tr.cmd == AXI_LITE_WRITE) begin
            update_model(tr);
            `uvm_info("AXI_LITE_MUX_SCB",
                $sformatf("Upstream write accepted: master=%0d addr=0x%08h data=0x%08h strb=0x%0h",
                    master_id, tr.addr, tr.data, tr.strb),
                UVM_MEDIUM)
        end else begin
            expected_data = mem_model[idx];
            if (tr.rdata !== expected_data) begin
                error_count++;
                `uvm_error("AXI_LITE_MUX_SCB",
                    $sformatf("Upstream read mismatch: master=%0d addr=0x%08h actual=0x%08h expected=0x%08h",
                        master_id, tr.addr, tr.rdata, expected_data))
            end else begin
                read_checks++;
                `uvm_info("AXI_LITE_MUX_SCB",
                    $sformatf("Upstream read match: master=%0d addr=0x%08h data=0x%08h",
                        master_id, tr.addr, tr.rdata),
                    UVM_MEDIUM)
            end
        end
    endfunction

    virtual function void check_downstream(axi_lite_tr tr);
        downstream_checks++;
        check_resp("downstream", tr);
        `uvm_info("AXI_LITE_MUX_SCB",
            $sformatf("Downstream observed: cmd=%s addr=0x%08h data=0x%08h strb=0x%0h",
                tr.cmd.name(), tr.addr, tr.data, tr.strb),
            UVM_MEDIUM)
    endfunction

    virtual function void write_mux_slv0(axi_lite_tr tr);
        check_upstream(0, tr);
    endfunction

    virtual function void write_mux_slv1(axi_lite_tr tr);
        check_upstream(1, tr);
    endfunction

    virtual function void write_mux_downstream(axi_lite_tr tr);
        check_downstream(tr);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        if (error_count != 0) begin
            `uvm_error("AXI_LITE_MUX_SCB",
                $sformatf("Scoreboard failed: errors=%0d upstream_checks=%0d downstream_checks=%0d read_checks=%0d",
                    error_count, upstream_checks, downstream_checks, read_checks))
        end else begin
            `uvm_info("AXI_LITE_MUX_SCB",
                $sformatf("Scoreboard passed: upstream_checks=%0d downstream_checks=%0d read_checks=%0d",
                    upstream_checks, downstream_checks, read_checks),
                UVM_LOW)
        end
    endfunction

endclass
