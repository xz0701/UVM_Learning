class axi_lite_demux_smoke_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_demux_smoke_seq)

    function new(string name = "axi_lite_demux_smoke_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;

        for (int unsigned port = 0; port < AXI_LITE_DEMUX_NUM_MST; port++) begin
            for (int unsigned word = 0; word < 4; word++) begin
                addr = (port << AXI_LITE_DEMUX_SELECT_ADDR_BIT) +
                       (word * AXI_LITE_STRB_WIDTH);
                data = 32'hD000_0000 | (port << 16) | word;

                send_write(
                    addr,
                    data,
                    4'hf,
                    word % 3,
                    (word + port) % 3,
                    (word + 1) % 3
                );

                send_read(
                    addr,
                    (word + 1) % 3,
                    (word + port + 2) % 3
                );
            end
        end

        send_write(32'h0000_0004, 32'hCAFE_0001, 4'h3, 2, 0, 1);
        send_read (32'h0000_0004, 1, 2);

        send_write(32'h0000_0014, 32'hBEEF_0102, 4'hc, 0, 2, 2);
        send_read (32'h0000_0014, 2, 1);
    endtask

endclass
