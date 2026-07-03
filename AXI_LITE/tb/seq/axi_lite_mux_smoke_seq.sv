class axi_lite_mux_smoke_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_mux_smoke_seq)

    int unsigned master_id;

    function new(string name = "axi_lite_mux_smoke_seq");
        super.new(name);
        master_id = 0;
    endfunction

    virtual function bit [AXI_LITE_ADDR_WIDTH-1:0] mux_addr(int unsigned word);
        return (master_id * 32'h0000_0040) + (word * AXI_LITE_STRB_WIDTH);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;

        for (int unsigned word = 0; word < 4; word++) begin
            addr = mux_addr(word);
            data = 32'hC000_0000 | (master_id << 16) | word;

            send_write(
                addr,
                data,
                4'hf,
                (word + master_id) % 3,
                (word + 1) % 3,
                (word + 2) % 3
            );

            send_read(
                addr,
                (word + 2) % 3,
                (word + master_id + 1) % 3
            );
        end

        addr = mux_addr(1);
        data = 32'hFACE_0000 | master_id;
        send_write(addr, data, 4'h3, 2, master_id % 2, 2);
        send_read(addr, 1, 2);
    endtask

endclass
