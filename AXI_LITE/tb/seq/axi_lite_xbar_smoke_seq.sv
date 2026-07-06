class axi_lite_xbar_smoke_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_xbar_smoke_seq)

    int unsigned master_id;

    function new(string name = "axi_lite_xbar_smoke_seq");
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

        for (int unsigned mst_port = 0; mst_port < AXI_LITE_XBAR_NUM_MST; mst_port++) begin
            for (int unsigned word = 0; word < 3; word++) begin
                addr = xbar_addr(mst_port, word);
                data = 32'hB000_0000 | (master_id << 20) | (mst_port << 12) | word;

                send_write(
                    addr,
                    data,
                    4'hf,
                    (word + master_id) % 3,
                    (word + mst_port + 1) % 3,
                    (word + 2) % 3
                );

                send_read(
                    addr,
                    (word + master_id + 1) % 3,
                    (word + mst_port + 2) % 3
                );
            end
        end

        addr = xbar_addr(master_id % AXI_LITE_XBAR_NUM_MST, 3);
        data = 32'hCAFE_0000 | master_id;
        send_write(addr, data, 4'h3, 2, master_id % 2, 2);
        send_read(addr, 1, 2);
    endtask

endclass
