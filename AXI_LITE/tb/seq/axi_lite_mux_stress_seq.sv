class axi_lite_mux_stress_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_mux_stress_seq)

    int unsigned master_id;

    function new(string name = "axi_lite_mux_stress_seq");
        super.new(name);
        master_id = 0;
    endfunction

    virtual function bit [AXI_LITE_ADDR_WIDTH-1:0] mux_addr(int unsigned word);
        return (master_id * 32'h0000_0040) + (word * AXI_LITE_STRB_WIDTH);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;
        bit [AXI_LITE_STRB_WIDTH-1:0] strb;
        int unsigned word;

        for (int unsigned i = 0; i < 20; i++) begin
            word = (i * 3 + master_id) % 8;
            addr = mux_addr(word);
            data = 32'hA600_0000 | (master_id << 20) | (word << 12) | i;
            strb = strb_pattern((i * 7 + master_id) % 15);

            send_write(
                addr,
                data,
                strb,
                (i + master_id) % 4,
                (i + 2 + master_id) % 4,
                (i + 1) % 5
            );

            if ((i % 2) == 0) begin
                send_read(
                    addr,
                    (i + 3 + master_id) % 4,
                    (i + 2) % 5
                );
            end
        end

        for (int unsigned word_idx = 0; word_idx < 8; word_idx++) begin
            addr = mux_addr(word_idx);
            send_read(
                addr,
                (word_idx + master_id) % 4,
                (word_idx + 1 + master_id) % 5
            );
        end
    endtask

endclass
