class axi_lite_seq extends uvm_sequence #(axi_lite_tr);

    `uvm_object_utils(axi_lite_seq)

    function new(string name = "axi_lite_seq");
        super.new(name);
    endfunction

    virtual task send_write(
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input bit [AXI_LITE_DATA_WIDTH-1:0] data,
        input bit [AXI_LITE_STRB_WIDTH-1:0] strb,
        input int unsigned aw_delay = 0,
        input int unsigned w_delay = 0,
        input int unsigned b_ready_delay = 0
    );
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create("write_req");
        start_item(req);
        req.cmd           = AXI_LITE_WRITE;
        req.addr          = addr;
        req.data          = data;
        req.strb          = strb;
        req.aw_delay      = aw_delay;
        req.w_delay       = w_delay;
        req.b_ready_delay = b_ready_delay;
        finish_item(req);
    endtask

    virtual task send_read(
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input int unsigned ar_delay = 0,
        input int unsigned r_ready_delay = 0
    );
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create("read_req");
        start_item(req);
        req.cmd           = AXI_LITE_READ;
        req.addr          = addr;
        req.data          = '0;
        req.strb          = '0;
        req.ar_delay      = ar_delay;
        req.r_ready_delay = r_ready_delay;
        finish_item(req);
    endtask

    virtual task send_random_access(int unsigned idx);
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create($sformatf("random_req_%0d", idx));
        start_item(req);

        if (!req.randomize() with {
            cmd dist {AXI_LITE_WRITE := 3, AXI_LITE_READ := 2};
            addr inside {[0:AXI_LITE_REG_NUM_BYTES-AXI_LITE_STRB_WIDTH]};
            addr[1:0] == 2'b00;
        }) begin
            `uvm_error("AXI_LITE_SEQ", "Random AXI-Lite transaction randomization failed")
        end

        if (req.cmd == AXI_LITE_READ) begin
            req.strb = '0;
        end

        finish_item(req);
    endtask

    virtual task body();
        bit [AXI_LITE_DATA_WIDTH-1:0] data_patterns [0:5];
        bit [AXI_LITE_STRB_WIDTH-1:0] strb_patterns [0:14];
        bit [AXI_LITE_ADDR_WIDTH-1:0] addr;
        bit [AXI_LITE_DATA_WIDTH-1:0] data;

        data_patterns[0] = 32'h0000_0000;
        data_patterns[1] = 32'hffff_ffff;
        data_patterns[2] = 32'haaaa_aaaa;
        data_patterns[3] = 32'h5555_5555;
        data_patterns[4] = 32'h1234_5678;
        data_patterns[5] = 32'hcafe_beef;

        foreach (strb_patterns[i]) begin
            strb_patterns[i] = i + 1;
        end

        // Reset/default reads.
        for (int unsigned word_idx = 0; word_idx < AXI_LITE_REG_NUM_BYTES / AXI_LITE_STRB_WIDTH; word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;
            send_read(addr, word_idx % 3, word_idx % 4);
        end

        // Full-word writes and reads across all valid word addresses.
        for (int unsigned word_idx = 0; word_idx < AXI_LITE_REG_NUM_BYTES / AXI_LITE_STRB_WIDTH; word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;
            data = data_patterns[word_idx % data_patterns.size()];

            send_write(addr, data, 4'hf, word_idx % 3, (word_idx + 1) % 3, word_idx % 4);
            send_read(addr, (word_idx + 1) % 3, (word_idx + 2) % 4);
        end

        // Exercise strobe categories at every valid word address.
        for (int unsigned word_idx = 0; word_idx < AXI_LITE_REG_NUM_BYTES / AXI_LITE_STRB_WIDTH; word_idx++) begin
            addr = word_idx * AXI_LITE_STRB_WIDTH;

            foreach (strb_patterns[strb_idx]) begin
                data = data_patterns[(word_idx + strb_idx) % data_patterns.size()] ^
                       (32'h0000_0101 * (word_idx + 1)) ^
                       (32'h0000_0011 * (strb_idx + 1));

                send_write(
                    addr,
                    data,
                    strb_patterns[strb_idx],
                    strb_idx % 4,
                    (strb_idx + word_idx) % 4,
                    (strb_idx + 2) % 5
                );
                send_read(addr, (strb_idx + 1) % 4, (strb_idx + 3) % 5);
            end
        end

        // A short constrained-random tail catches combinations not covered above.
        repeat (50) begin
            send_random_access($urandom_range(0, 32'hffff));
        end
    endtask

endclass
