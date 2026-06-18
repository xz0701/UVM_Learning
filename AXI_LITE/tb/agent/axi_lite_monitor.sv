class axi_lite_monitor extends uvm_monitor;

    `uvm_component_utils(axi_lite_monitor)

    axi_lite_vif_t      axi_vif;
    axi_lite_ctrl_vif_t ctrl_vif;

    uvm_analysis_port #(axi_lite_tr) ap;

    function new(string name = "axi_lite_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(axi_lite_vif_t)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_LITE_MON", "Failed to get AXI-Lite virtual interface")
        end

        if (!uvm_config_db#(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_MON", "Failed to get control virtual interface")
        end
    endfunction

    virtual task wait_reset_release();
        wait (ctrl_vif.rst_n === 1'b1);
        @(posedge ctrl_vif.clk);
    endtask

    virtual task monitor_write();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;
        bit [AXI_LITE_DATA_WIDTH/8-1:0] strb;
        bit have_aw;
        bit have_w;
        bit seen_aw_valid;
        bit seen_w_valid;
        int unsigned cycle_count;
        int unsigned aw_valid_cycle;
        int unsigned w_valid_cycle;
        int unsigned b_wait_cycles;
        axi_lite_tr tr;

        forever begin
            have_aw = 1'b0;
            have_w  = 1'b0;
            addr    = '0;
            data    = '0;
            strb    = '0;
            cycle_count = 0;
            seen_aw_valid = 1'b0;
            seen_w_valid = 1'b0;
            aw_valid_cycle = 0;
            w_valid_cycle = 0;

            while (!(have_aw && have_w)) begin
                @(posedge ctrl_vif.clk);

                if (!ctrl_vif.rst_n) begin
                    have_aw = 1'b0;
                    have_w  = 1'b0;
                    seen_aw_valid = 1'b0;
                    seen_w_valid = 1'b0;
                    cycle_count = 0;
                    continue;
                end

                if (!seen_aw_valid && axi_vif.aw_valid) begin
                    addr = axi_vif.aw_addr;
                    seen_aw_valid = 1'b1;
                    aw_valid_cycle = cycle_count;
                end

                if (!seen_w_valid && axi_vif.w_valid) begin
                    data = axi_vif.w_data;
                    strb = axi_vif.w_strb;
                    seen_w_valid = 1'b1;
                    w_valid_cycle = cycle_count;
                end

                if (!have_aw && axi_vif.aw_valid && axi_vif.aw_ready) begin
                    have_aw = 1'b1;
                end

                if (!have_w && axi_vif.w_valid && axi_vif.w_ready) begin
                    have_w = 1'b1;
                end

                cycle_count++;
            end

            b_wait_cycles = 0;
            forever begin
                @(posedge ctrl_vif.clk);

                if (!ctrl_vif.rst_n) begin
                    break;
                end

                if (axi_vif.b_valid && axi_vif.b_ready) begin
                    tr = axi_lite_tr::type_id::create("wr_tr", this);
                    tr.cmd  = AXI_LITE_WRITE;
                    tr.addr = addr;
                    tr.data = data;
                    tr.strb = strb;
                    tr.resp = axi_vif.b_resp;
                    tr.b_wait_cycles = b_wait_cycles;

                    if (aw_valid_cycle == w_valid_cycle) begin
                        tr.wr_order = AXI_LITE_AW_W_SAME;
                    end else if (aw_valid_cycle < w_valid_cycle) begin
                        tr.wr_order = AXI_LITE_AW_BEFORE_W;
                    end else begin
                        tr.wr_order = AXI_LITE_W_BEFORE_AW;
                    end

                    `uvm_info("AXI_LITE_MON",
                        $sformatf("WRITE addr=0x%08h data=0x%08h strb=0x%0h resp=0x%0h order=%s b_wait=%0d",
                            tr.addr, tr.data, tr.strb, tr.resp, tr.wr_order.name(), tr.b_wait_cycles),
                        UVM_MEDIUM)

                    ap.write(tr);
                    break;
                end

                b_wait_cycles++;
            end
        end
    endtask

    virtual task monitor_read();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        int unsigned r_wait_cycles;
        axi_lite_tr tr;

        forever begin
            addr = '0;

            do begin
                @(posedge ctrl_vif.clk);
            end while (ctrl_vif.rst_n && !(axi_vif.ar_valid && axi_vif.ar_ready));

            if (!ctrl_vif.rst_n) begin
                continue;
            end

            addr = axi_vif.ar_addr;
            r_wait_cycles = 0;

            forever begin
                @(posedge ctrl_vif.clk);

                if (!ctrl_vif.rst_n) begin
                    break;
                end

                if (axi_vif.r_valid && axi_vif.r_ready) begin
                    tr = axi_lite_tr::type_id::create("rd_tr", this);
                    tr.cmd   = AXI_LITE_READ;
                    tr.addr  = addr;
                    tr.rdata = axi_vif.r_data;
                    tr.resp  = axi_vif.r_resp;
                    tr.r_wait_cycles = r_wait_cycles;

                    `uvm_info("AXI_LITE_MON",
                        $sformatf("READ addr=0x%08h rdata=0x%08h resp=0x%0h r_wait=%0d",
                            tr.addr, tr.rdata, tr.resp, tr.r_wait_cycles),
                        UVM_MEDIUM)

                    ap.write(tr);
                    break;
                end

                r_wait_cycles++;
            end
        end
    endtask

    virtual task run_phase(uvm_phase phase);
        wait_reset_release();

        fork
            monitor_write();
            monitor_read();
        join
    endtask

endclass
