class axi_lite_direct_load_seq extends axi_lite_base_seq;

    axi_lite_ctrl_vif_t ctrl_vif;

    `uvm_object_utils(axi_lite_direct_load_seq)

    function new(string name = "axi_lite_direct_load_seq");
        super.new(name);
    endfunction

    virtual task drive_direct_load(input int unsigned byte_idx, input bit [7:0] value);
        if (byte_idx >= AXI_LITE_REG_NUM_BYTES) begin
            `uvm_error("AXI_LITE_DIRECT_LOAD_SEQ",
                $sformatf("Direct load byte index out of range: %0d", byte_idx))
            return;
        end

        @(negedge ctrl_vif.clk);
        ctrl_vif.reg_d[byte_idx]    = value;
        ctrl_vif.reg_load[byte_idx] = 1'b1;
        @(posedge ctrl_vif.clk);
        @(negedge ctrl_vif.clk);
        ctrl_vif.reg_load[byte_idx] = 1'b0;
    endtask

    virtual task drive_direct_word(
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input bit [AXI_LITE_DATA_WIDTH-1:0] data
    );
        bit [AXI_LITE_REG_ADDR_WIDTH-1:0] eff_addr;

        eff_addr = addr[AXI_LITE_REG_ADDR_WIDTH-1:0];

        for (int unsigned i = 0; i < AXI_LITE_STRB_WIDTH; i++) begin
            drive_direct_load(eff_addr + i, data[8*i +: 8]);
        end
    endtask

    virtual task body();
        if (ctrl_vif == null) begin
            `uvm_fatal("AXI_LITE_DIRECT_LOAD_SEQ", "ctrl_vif is not set")
        end

        wait (ctrl_vif.rst_n === 1'b1);

        drive_direct_word(32'h0000_0000, 32'h1234_5678);
        send_read(32'h0000_0000, 0, 0);

        drive_direct_word(32'h0000_0004, 32'hdead_beef);
        send_read(32'h0000_0004, 1, 1);

        drive_direct_load(2, 8'hAA);
        send_read(32'h0000_0000, 2, 0);

        drive_direct_load(6, 8'h55);
        send_read(32'h0000_0004, 0, 2);

        send_write(32'h0000_0008, 32'hcafe_f00d, 4'hf, 0, 0, 1);
        drive_direct_word(32'h0000_0008, 32'h0bad_c0de);
        send_read(32'h0000_0008, 1, 0);
    endtask

endclass
