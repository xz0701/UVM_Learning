class axi_lite_backpressure_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_backpressure_seq)

    function new(string name = "axi_lite_backpressure_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;

        for (int unsigned strb_idx = 0; strb_idx < 15; strb_idx++) begin
            addr = (strb_idx % num_words()) * AXI_LITE_STRB_WIDTH;

            send_write(
                addr,
                32'h1000_0000 ^ (32'h0001_0101 * (strb_idx + 1)),
                strb_pattern(strb_idx),
                0,
                0,
                strb_idx % 3
            );

            send_write(
                addr,
                32'h2000_0000 ^ (32'h0002_0202 * (strb_idx + 1)),
                strb_pattern(strb_idx),
                0,
                3,
                (strb_idx + 1) % 3
            );

            send_write(
                addr,
                32'h3000_0000 ^ (32'h0003_0303 * (strb_idx + 1)),
                strb_pattern(strb_idx),
                3,
                0,
                (strb_idx + 2) % 3
            );

            send_read(addr, strb_idx % 3, strb_idx % 3);
        end
    endtask

endclass
