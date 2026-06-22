class axi_lite_load_conflict_seq extends axi_lite_direct_load_seq;

    `uvm_object_utils(axi_lite_load_conflict_seq)

    function new(string name = "axi_lite_load_conflict_seq");
        super.new(name);
    endfunction

    virtual task hold_direct_load(input int unsigned byte_idx, input bit [7:0] value);
        if (byte_idx >= AXI_LITE_REG_NUM_BYTES) begin
            `uvm_error("AXI_LITE_LOAD_CONFLICT_SEQ",
                $sformatf("Direct load byte index out of range: %0d", byte_idx))
            return;
        end

        @(negedge ctrl_vif.clk);
        ctrl_vif.reg_d[byte_idx]    = value;
        ctrl_vif.reg_load[byte_idx] = 1'b1;
    endtask

    virtual task release_direct_load(input int unsigned byte_idx);
        @(negedge ctrl_vif.clk);
        ctrl_vif.reg_load[byte_idx] = 1'b0;
    endtask

    virtual task send_write_with_conflict(
        input int unsigned byte_idx,
        input bit [7:0] direct_value,
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input bit [AXI_LITE_DATA_WIDTH-1:0] data,
        input bit [AXI_LITE_STRB_WIDTH-1:0] strb,
        input int unsigned hold_cycles
    );
        bit write_done;

        write_done = 1'b0;
        hold_direct_load(byte_idx, direct_value);

        fork
            begin
                send_write(addr, data, strb, 0, 0, 0);
                write_done = 1'b1;
            end

            begin
                repeat (hold_cycles) @(posedge ctrl_vif.clk);
                if (write_done) begin
                    `uvm_error("AXI_LITE_LOAD_CONFLICT_SEQ",
                        $sformatf("AXI write completed while conflicting reg_load was still high: addr=0x%08h byte=%0d",
                            addr, byte_idx))
                end

                release_direct_load(byte_idx);

                repeat (AXI_LITE_TIMEOUT_CYCLES) begin
                    if (write_done) begin
                        break;
                    end
                    @(posedge ctrl_vif.clk);
                end

                if (!write_done) begin
                    `uvm_error("AXI_LITE_LOAD_CONFLICT_SEQ",
                        $sformatf("AXI write did not complete after direct load conflict was released: addr=0x%08h byte=%0d",
                            addr, byte_idx))
                end
            end
        join
    endtask

    virtual task send_write_without_conflict(
        input int unsigned byte_idx,
        input bit [7:0] direct_value,
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input bit [AXI_LITE_DATA_WIDTH-1:0] data,
        input bit [AXI_LITE_STRB_WIDTH-1:0] strb,
        input int unsigned hold_cycles
    );
        bit write_done;

        write_done = 1'b0;
        hold_direct_load(byte_idx, direct_value);

        fork
            begin
                send_write(addr, data, strb, 0, 0, 0);
                write_done = 1'b1;
            end

            begin
                repeat (hold_cycles) @(posedge ctrl_vif.clk);
                if (!write_done) begin
                    `uvm_error("AXI_LITE_LOAD_CONFLICT_SEQ",
                        $sformatf("AXI write stalled even though direct load byte was not selected by WSTRB: addr=0x%08h load_byte=%0d strb=0x%0h",
                            addr, byte_idx, strb))
                end
                release_direct_load(byte_idx);
            end
        join
    endtask

    virtual task body();
        if (ctrl_vif == null) begin
            `uvm_fatal("AXI_LITE_LOAD_CONFLICT_SEQ", "ctrl_vif is not set")
        end

        wait (ctrl_vif.rst_n === 1'b1);

        send_write_with_conflict(
            12,
            8'h55,
            32'h0000_000c,
            32'h0000_00aa,
            4'b0001,
            5
        );
        send_read(32'h0000_000c, 0, 0);

        send_write_with_conflict(
            14,
            8'h66,
            32'h0000_000c,
            32'h00bb_0000,
            4'b0100,
            4
        );
        send_read(32'h0000_000c, 1, 1);

        send_write_without_conflict(
            17,
            8'h77,
            32'h0000_0010,
            32'h0000_00cc,
            4'b0001,
            12
        );
        send_read(32'h0000_0010, 1, 0);
    endtask

endclass
