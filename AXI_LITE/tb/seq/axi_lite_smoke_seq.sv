class axi_lite_smoke_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_smoke_seq)

    function new(string name = "axi_lite_smoke_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;

        for (int unsigned word_idx = 0; word_idx < num_words(); word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;
            send_read(addr, word_idx % 3, word_idx % 4);
        end

        for (int unsigned word_idx = 0; word_idx < num_words(); word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;
            data = data_pattern(word_idx);

            send_write(addr, data, 4'hf, word_idx % 3, (word_idx + 1) % 3, word_idx % 4);
            send_read(addr, (word_idx + 1) % 3, (word_idx + 2) % 4);
        end
    endtask

endclass
