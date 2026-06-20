class axi_lite_strobe_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_strobe_seq)

    function new(string name = "axi_lite_strobe_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;

        for (int unsigned word_idx = 0; word_idx < num_words(); word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;

            for (int unsigned strb_idx = 0; strb_idx < 15; strb_idx++) begin
                data = data_pattern(word_idx + strb_idx) ^
                       (32'h0000_0101 * (word_idx + 1)) ^
                       (32'h0000_0011 * (strb_idx + 1));

                send_write(
                    addr,
                    data,
                    strb_pattern(strb_idx),
                    strb_idx % 4,
                    (strb_idx + word_idx) % 4,
                    (strb_idx + 2) % 5
                );
                send_read(addr, (strb_idx + 1) % 4, (strb_idx + 3) % 5);
            end
        end
    endtask

endclass
