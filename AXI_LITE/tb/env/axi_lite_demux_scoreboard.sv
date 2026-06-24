`uvm_analysis_imp_decl(_demux_upstream)
`uvm_analysis_imp_decl(_demux_mst0)
`uvm_analysis_imp_decl(_demux_mst1)

class axi_lite_demux_scoreboard extends uvm_component;

    `uvm_component_utils(axi_lite_demux_scoreboard)

    uvm_analysis_imp_demux_upstream #(axi_lite_tr, axi_lite_demux_scoreboard) upstream_imp;
    uvm_analysis_imp_demux_mst0 #(axi_lite_tr, axi_lite_demux_scoreboard) mst0_imp;
    uvm_analysis_imp_demux_mst1 #(axi_lite_tr, axi_lite_demux_scoreboard) mst1_imp;

    bit [AXI_LITE_DATA_WIDTH-1:0] mem_model [AXI_LITE_DEMUX_NUM_MST][AXI_LITE_DEMUX_MEM_WORDS];
    int unsigned upstream_checks;
    int unsigned route_checks;
    int unsigned read_checks;
    int unsigned error_count;

    function new(string name = "axi_lite_demux_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        upstream_imp = new("upstream_imp", this);
        mst0_imp = new("mst0_imp", this);
        mst1_imp = new("mst1_imp", this);
        clear_model();
    endfunction

    virtual function void clear_model();
        foreach (mem_model[p, w]) begin
            mem_model[p][w] = '0;
        end
        upstream_checks = 0;
        route_checks = 0;
        read_checks = 0;
        error_count = 0;
    endfunction

    virtual function int unsigned route_port(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        return addr[AXI_LITE_DEMUX_SELECT_ADDR_BIT];
    endfunction

    virtual function int unsigned word_index(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        return (addr >> $clog2(AXI_LITE_STRB_WIDTH)) % AXI_LITE_DEMUX_MEM_WORDS;
    endfunction

    virtual function void update_model(int unsigned port, axi_lite_tr tr);
        int unsigned idx;

        idx = word_index(tr.addr);
        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            if (tr.strb[i]) begin
                mem_model[port][idx][8*i +: 8] = tr.data[8*i +: 8];
            end
        end
    endfunction

    virtual function void check_resp(string where, axi_lite_tr tr);
        if (tr.resp !== AXI_LITE_RESP_OKAY) begin
            error_count++;
            `uvm_error("AXI_LITE_DEMUX_SCB",
                $sformatf("%s response mismatch: addr=0x%08h resp=0x%0h expected=OKAY",
                    where, tr.addr, tr.resp))
        end
    endfunction

    virtual function void check_downstream(int unsigned observed_port, axi_lite_tr tr);
        int unsigned expected_port;
        int unsigned idx;
        bit [AXI_LITE_DATA_WIDTH-1:0] expected_data;

        expected_port = route_port(tr.addr);
        idx = word_index(tr.addr);
        route_checks++;

        if (observed_port != expected_port) begin
            error_count++;
            `uvm_error("AXI_LITE_DEMUX_SCB",
                $sformatf("Route mismatch: addr=0x%08h observed_port=%0d expected_port=%0d",
                    tr.addr, observed_port, expected_port))
            return;
        end

        check_resp($sformatf("downstream port %0d", observed_port), tr);

        if (tr.cmd == AXI_LITE_WRITE) begin
            `uvm_info("AXI_LITE_DEMUX_SCB",
                $sformatf("Downstream write routed: port=%0d addr=0x%08h data=0x%08h strb=0x%0h",
                    observed_port, tr.addr, tr.data, tr.strb),
                UVM_MEDIUM)
        end else begin
            expected_data = mem_model[observed_port][idx];
            if (tr.rdata !== expected_data) begin
                error_count++;
                `uvm_error("AXI_LITE_DEMUX_SCB",
                    $sformatf("Downstream read data mismatch: port=%0d addr=0x%08h actual=0x%08h expected=0x%08h",
                        observed_port, tr.addr, tr.rdata, expected_data))
            end else begin
                read_checks++;
                `uvm_info("AXI_LITE_DEMUX_SCB",
                    $sformatf("Downstream read match: port=%0d addr=0x%08h data=0x%08h",
                        observed_port, tr.addr, tr.rdata),
                    UVM_MEDIUM)
            end
        end
    endfunction

    virtual function void write_demux_upstream(axi_lite_tr tr);
        int unsigned port;
        int unsigned idx;
        bit [AXI_LITE_DATA_WIDTH-1:0] expected_data;

        upstream_checks++;
        check_resp("upstream", tr);

        port = route_port(tr.addr);
        idx = word_index(tr.addr);

        if (tr.cmd == AXI_LITE_WRITE) begin
            update_model(port, tr);
        end else begin
            expected_data = mem_model[port][idx];

            if (tr.rdata !== expected_data) begin
                error_count++;
                `uvm_error("AXI_LITE_DEMUX_SCB",
                    $sformatf("Upstream read data mismatch: addr=0x%08h port=%0d actual=0x%08h expected=0x%08h",
                        tr.addr, port, tr.rdata, expected_data))
            end
        end
    endfunction

    virtual function void write_demux_mst0(axi_lite_tr tr);
        check_downstream(0, tr);
    endfunction

    virtual function void write_demux_mst1(axi_lite_tr tr);
        check_downstream(1, tr);
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        if (error_count != 0) begin
            `uvm_error("AXI_LITE_DEMUX_SCB",
                $sformatf("Scoreboard failed: errors=%0d upstream_checks=%0d route_checks=%0d read_checks=%0d",
                    error_count, upstream_checks, route_checks, read_checks))
        end else begin
            `uvm_info("AXI_LITE_DEMUX_SCB",
                $sformatf("Scoreboard passed: upstream_checks=%0d route_checks=%0d read_checks=%0d",
                    upstream_checks, route_checks, read_checks),
                UVM_LOW)
        end
    endfunction

endclass
