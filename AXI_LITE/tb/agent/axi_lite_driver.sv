class axi_lite_driver extends uvm_driver #(axi_lite_tr);

    `uvm_component_utils(axi_lite_driver)

    axi_lite_vif_t      axi_vif;
    axi_lite_ctrl_vif_t ctrl_vif;

    function new(string name = "axi_lite_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(axi_lite_vif_t)::get(this, "", "axi_vif", axi_vif)) begin
            `uvm_fatal("AXI_LITE_DRV", "Failed to get AXI-Lite virtual interface")
        end

        if (!uvm_config_db#(axi_lite_ctrl_vif_t)::get(this, "", "ctrl_vif", ctrl_vif)) begin
            `uvm_fatal("AXI_LITE_DRV", "Failed to get control virtual interface")
        end
    endfunction

    virtual task reset_signals();
        axi_vif.aw_addr  <= '0;
        axi_vif.aw_prot  <= '0;
        axi_vif.aw_valid <= 1'b0;
        axi_vif.w_data   <= '0;
        axi_vif.w_strb   <= '0;
        axi_vif.w_valid  <= 1'b0;
        axi_vif.b_ready  <= 1'b0;
        axi_vif.ar_addr  <= '0;
        axi_vif.ar_prot  <= '0;
        axi_vif.ar_valid <= 1'b0;
        axi_vif.r_ready  <= 1'b0;
    endtask

    virtual task wait_reset_release();
        wait (ctrl_vif.rst_n === 1'b1);
        repeat (2) @(posedge ctrl_vif.clk);
    endtask

    virtual task drive_aw(axi_lite_tr tr);
        repeat (tr.aw_delay) @(posedge ctrl_vif.clk);

        axi_vif.aw_addr  <= tr.addr;
        axi_vif.aw_prot  <= 3'b000;
        axi_vif.aw_valid <= 1'b1;

        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.aw_ready);

        axi_vif.aw_valid <= 1'b0;
        axi_vif.aw_addr  <= '0;
    endtask

    virtual task drive_w(axi_lite_tr tr);
        repeat (tr.w_delay) @(posedge ctrl_vif.clk);

        axi_vif.w_data  <= tr.data;
        axi_vif.w_strb  <= tr.strb;
        axi_vif.w_valid <= 1'b1;

        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.w_ready);

        axi_vif.w_valid <= 1'b0;
        axi_vif.w_data  <= '0;
        axi_vif.w_strb  <= '0;
    endtask

    virtual task drive_write(axi_lite_tr tr);
        @(posedge ctrl_vif.clk);
        axi_vif.b_ready <= 1'b0;

        fork
            drive_aw(tr);
            drive_w(tr);
        join

        repeat (tr.b_ready_delay) @(posedge ctrl_vif.clk);
        axi_vif.b_ready <= 1'b1;
        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.b_valid || !axi_vif.b_ready);

        tr.resp = axi_vif.b_resp;

        @(posedge ctrl_vif.clk);
        axi_vif.b_ready <= 1'b0;

        `uvm_info("AXI_LITE_DRV",
            $sformatf("WRITE addr=0x%08h data=0x%08h strb=0x%0h resp=0x%0h aw_delay=%0d w_delay=%0d b_ready_delay=%0d",
                tr.addr, tr.data, tr.strb, tr.resp, tr.aw_delay, tr.w_delay, tr.b_ready_delay),
            UVM_MEDIUM)
    endtask

    virtual task drive_read(axi_lite_tr tr);
        @(posedge ctrl_vif.clk);
        axi_vif.r_ready <= 1'b0;

        repeat (tr.ar_delay) @(posedge ctrl_vif.clk);
        axi_vif.ar_addr  <= tr.addr;
        axi_vif.ar_prot  <= 3'b000;
        axi_vif.ar_valid <= 1'b1;

        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.ar_ready);

        axi_vif.ar_valid <= 1'b0;
        axi_vif.ar_addr  <= '0;

        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.r_valid);

        repeat (tr.r_ready_delay) @(posedge ctrl_vif.clk);
        axi_vif.r_ready <= 1'b1;

        do begin
            @(posedge ctrl_vif.clk);
        end while (!axi_vif.r_valid || !axi_vif.r_ready);

        tr.rdata = axi_vif.r_data;
        tr.resp  = axi_vif.r_resp;

        @(posedge ctrl_vif.clk);
        axi_vif.r_ready <= 1'b0;

        `uvm_info("AXI_LITE_DRV",
            $sformatf("READ addr=0x%08h rdata=0x%08h resp=0x%0h ar_delay=%0d r_ready_delay=%0d",
                tr.addr, tr.rdata, tr.resp, tr.ar_delay, tr.r_ready_delay),
            UVM_MEDIUM)
    endtask

    virtual task run_phase(uvm_phase phase);
        axi_lite_tr tr;

        reset_signals();

        wait_reset_release();

        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.cmd == AXI_LITE_WRITE) begin
                drive_write(tr);
            end else begin
                drive_read(tr);
            end
            
            seq_item_port.item_done();
        end
    endtask
endclass
