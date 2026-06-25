class axi_lite_demux_stress_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_demux_stress_seq)

    function new(string name = "axi_lite_demux_stress_seq");
        super.new(name);
    endfunction

    virtual function bit [AXI_LITE_ADDR_WIDTH-1:0] demux_addr(
        int unsigned port,
        int unsigned word
    );
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;

        addr = '0;
        addr[AXI_LITE_DEMUX_SELECT_ADDR_BIT +: AXI_LITE_DEMUX_SEL_WIDTH] =
            port[AXI_LITE_DEMUX_SEL_WIDTH-1:0];
        addr[3:2] = word[1:0];
        return addr;
    endfunction

    virtual task body();
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;
        bit [AXI_LITE_STRB_WIDTH-1:0] strb;
        int unsigned port;
        int unsigned word;

        for (int unsigned i = 0; i < 24; i++) begin
            port = i % AXI_LITE_DEMUX_NUM_MST;
            word = ((i / AXI_LITE_DEMUX_NUM_MST) + (port * 2)) % 4;
            addr = demux_addr(port, word);
            data = 32'hA500_0000 | (port << 20) | (word << 12) | i;
            strb = strb_pattern((i * 7) % 15);

            send_write(
                addr,
                data,
                strb,
                (i + 0) % 4,
                (i + 2) % 4,
                (i + 1) % 5
            );

            if ((i % 2) == 0) begin
                send_read(
                    addr,
                    (i + 3) % 4,
                    (i + 2) % 5
                );
            end
        end

        for (int unsigned port_idx = 0; port_idx < AXI_LITE_DEMUX_NUM_MST; port_idx++) begin
            for (int unsigned word_idx = 0; word_idx < 4; word_idx++) begin
                addr = demux_addr(port_idx, word_idx);
                send_read(
                    addr,
                    (port_idx + word_idx) % 4,
                    (port_idx + word_idx + 1) % 5
                );
            end
        end
    endtask

endclass
