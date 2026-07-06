class axi_lite_xbar_stress_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_xbar_stress_seq)

    int unsigned master_id;

    function new(string name = "axi_lite_xbar_stress_seq");
        super.new(name);
        master_id = 0;
    endfunction

    virtual function bit [AXI_LITE_ADDR_WIDTH-1:0] xbar_addr(
        int unsigned mst_port,
        int unsigned word
    );
        bit [AXI_LITE_ADDR_WIDTH-1:0] base;

        base = (mst_port == 0) ? AXI_LITE_XBAR_MST0_BASE : AXI_LITE_XBAR_MST1_BASE;
        return base + ((word + (master_id * 8)) * AXI_LITE_STRB_WIDTH);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;
        bit [AXI_LITE_STRB_WIDTH-1:0] strb;
        int unsigned mst_port;
        int unsigned word;

        for (int unsigned i = 0; i < 24; i++) begin
            mst_port = (i + master_id) % AXI_LITE_XBAR_NUM_MST;
            word = (i * 3 + master_id) % 8;
            addr = xbar_addr(mst_port, word);
            data = 32'hD700_0000 | (master_id << 20) | (mst_port << 12) | i;
            strb = strb_pattern((i * 5 + master_id) % 15);

            send_write(
                addr,
                data,
                strb,
                (i + master_id) % 4,
                (i + 2 + mst_port) % 4,
                (i + 1) % 5
            );

            if ((i % 2) == 0) begin
                send_read(
                    addr,
                    (i + 3 + master_id) % 4,
                    (i + 2 + mst_port) % 5
                );
            end
        end

        for (int unsigned mst_port_idx = 0; mst_port_idx < AXI_LITE_XBAR_NUM_MST; mst_port_idx++) begin
            for (int unsigned word_idx = 0; word_idx < 8; word_idx++) begin
                addr = xbar_addr(mst_port_idx, word_idx);
                send_read(
                    addr,
                    (word_idx + master_id) % 4,
                    (word_idx + 1 + mst_port_idx) % 5
                );
            end
        end
    endtask

endclass
