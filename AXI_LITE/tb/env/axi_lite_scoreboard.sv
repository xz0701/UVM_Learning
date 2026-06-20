class axi_lite_scoreboard extends uvm_component;

    `uvm_component_utils(axi_lite_scoreboard)

    axi_lite_ctrl_vif_t ctrl_vif;

    uvm_analysis_imp #(axi_lite_tr, axi_lite_scoreboard) analysis_imp;

    bit [7:0] reg_model [AXI_LITE_REG_NUM_BYTES];
    int unsigned pass_count;
    int unsigned error_count;

    function new(string name = "axi_lite_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        analysis_imp = new("analysis_imp", this);

        if (!uvm_config_db#(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_SCB", "Failed to get control virtual interface")
        end

        clear_model();
        pass_count  = 0;
        error_count = 0;
    endfunction

    virtual function void clear_model();
        foreach (reg_model[i]) begin
            reg_model[i] = '0;
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge ctrl_vif.rst_n);
            clear_model();
            `uvm_info("AXI_LITE_SCB", "Reset detected, model cleared", UVM_LOW)
        end
    endtask

    virtual function bit [AXI_LITE_REG_ADDR_WIDTH-1:0] effective_addr(
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr
    );
        return addr[AXI_LITE_REG_ADDR_WIDTH-1:0];
    endfunction

    virtual function bit addr_in_range(bit [AXI_LITE_REG_ADDR_WIDTH-1:0] addr, int unsigned byte_idx);
        return ((addr + byte_idx) < AXI_LITE_REG_NUM_BYTES);
    endfunction

    virtual function bit access_in_range(bit [AXI_LITE_ADDR_WIDTH-1:0] addr);
        return (effective_addr(addr) < AXI_LITE_REG_NUM_BYTES);
    endfunction

    virtual function void model_write(axi_lite_tr tr);
        bit [AXI_LITE_REG_ADDR_WIDTH-1:0] eff_addr;

        eff_addr = effective_addr(tr.addr);

        if (!access_in_range(tr.addr)) begin
            if (tr.resp !== AXI_LITE_RESP_SLVERR) begin
                error_count++;
                `uvm_error("AXI_LITE_SCB",
                    $sformatf("Invalid write response mismatch: addr=0x%08h actual=0x%0h expected=SLVERR",
                        tr.addr, tr.resp))
            end else begin
                `uvm_info("AXI_LITE_SCB",
                    $sformatf("Invalid write returned SLVERR as expected: addr=0x%08h",
                        tr.addr),
                    UVM_MEDIUM)
            end
            return;
        end

        if (tr.resp !== AXI_LITE_RESP_OKAY) begin
            error_count++;
            `uvm_error("AXI_LITE_SCB",
                $sformatf("Unexpected valid write response: addr=0x%08h resp=0x%0h",
                    tr.addr, tr.resp))
            return;
        end

        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            if (tr.strb[i]) begin
                if (addr_in_range(eff_addr, i)) begin
                    reg_model[eff_addr + i] = tr.data[8*i +: 8];
                end else begin
                    error_count++;
                    `uvm_error("AXI_LITE_SCB",
                        $sformatf("Write byte out of range: addr=0x%08h effective_addr=0x%0h byte_lane=%0d",
                            tr.addr, eff_addr, i))
                end
            end
        end

        `uvm_info("AXI_LITE_SCB",
            $sformatf("Model write: addr=0x%08h effective_addr=0x%0h data=0x%08h strb=0x%0h",
                tr.addr, eff_addr, tr.data, tr.strb),
            UVM_MEDIUM)
    endfunction

    virtual function bit [AXI_LITE_DATA_WIDTH-1:0] model_read_data(
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr
    );
        bit [AXI_LITE_DATA_WIDTH-1:0] expected;
        bit [AXI_LITE_REG_ADDR_WIDTH-1:0] eff_addr;

        expected = '0;
        eff_addr = effective_addr(addr);

        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            if (addr_in_range(eff_addr, i)) begin
                expected[8*i +: 8] = reg_model[eff_addr + i];
            end
        end

        return expected;
    endfunction

    virtual function void model_check_read(axi_lite_tr tr);
        bit [AXI_LITE_DATA_WIDTH-1:0] expected;

        if (!access_in_range(tr.addr)) begin
            if (tr.resp !== AXI_LITE_RESP_SLVERR) begin
                error_count++;
                `uvm_error("AXI_LITE_SCB",
                    $sformatf("Invalid read response mismatch: addr=0x%08h actual=0x%0h expected=SLVERR",
                        tr.addr, tr.resp))
            end else if (tr.rdata !== AXI_LITE_ERR_RDATA) begin
                error_count++;
                `uvm_error("AXI_LITE_SCB",
                    $sformatf("Invalid read data mismatch: addr=0x%08h actual=0x%08h expected=0x%08h",
                        tr.addr, tr.rdata, AXI_LITE_ERR_RDATA))
            end else begin
                pass_count++;
                `uvm_info("AXI_LITE_SCB",
                    $sformatf("Invalid read returned SLVERR/data as expected: addr=0x%08h rdata=0x%08h",
                        tr.addr, tr.rdata),
                    UVM_MEDIUM)
            end
            return;
        end

        if (tr.resp !== AXI_LITE_RESP_OKAY) begin
            error_count++;
            `uvm_error("AXI_LITE_SCB",
                $sformatf("Unexpected valid read response: addr=0x%08h resp=0x%0h rdata=0x%08h",
                    tr.addr, tr.resp, tr.rdata))
            return;
        end

        expected = model_read_data(tr.addr);

        if (tr.rdata !== expected) begin
            error_count++;
            `uvm_error("AXI_LITE_SCB",
                $sformatf("Read mismatch: addr=0x%08h actual=0x%08h expected=0x%08h",
                    tr.addr, tr.rdata, expected))
        end else begin
            pass_count++;
            `uvm_info("AXI_LITE_SCB",
                $sformatf("Read match: addr=0x%08h data=0x%08h",
                    tr.addr, tr.rdata),
                UVM_MEDIUM)
        end
    endfunction

    virtual function void write(axi_lite_tr tr);
        if (!ctrl_vif.rst_n) begin
            return;
        end

        if (tr.cmd == AXI_LITE_WRITE) begin
            model_write(tr);
        end else begin
            model_check_read(tr);
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        if (error_count == 0) begin
            `uvm_info("AXI_LITE_SCB",
                $sformatf("Scoreboard passed: read_checks=%0d", pass_count),
                UVM_LOW)
        end else begin
            `uvm_error("AXI_LITE_SCB",
                $sformatf("Scoreboard failed: errors=%0d read_checks=%0d",
                    error_count, pass_count))
        end
    endfunction

endclass
