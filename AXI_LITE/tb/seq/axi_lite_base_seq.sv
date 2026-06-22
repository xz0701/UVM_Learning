class axi_lite_base_seq extends uvm_sequence #(axi_lite_tr);

    `uvm_object_utils(axi_lite_base_seq)

    function new(string name = "axi_lite_base_seq");
        super.new(name);
    endfunction

    virtual function int unsigned num_words();
        return AXI_LITE_REG_NUM_BYTES / AXI_LITE_STRB_WIDTH;
    endfunction

    virtual function bit [AXI_LITE_DATA_WIDTH-1:0] data_pattern(int unsigned idx);
        case (idx % 6)
            0: return 32'h0000_0000;
            1: return 32'hffff_ffff;
            2: return 32'haaaa_aaaa;
            3: return 32'h5555_5555;
            4: return 32'h1234_5678;
            default: return 32'hcafe_beef;
        endcase
    endfunction

    virtual function bit [AXI_LITE_STRB_WIDTH-1:0] strb_pattern(int unsigned idx);
        return idx + 1;
    endfunction

    virtual task send_write(
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input bit [AXI_LITE_DATA_WIDTH-1:0] data,
        input bit [AXI_LITE_STRB_WIDTH-1:0] strb,
        input int unsigned aw_delay = 0,
        input int unsigned w_delay = 0,
        input int unsigned b_ready_delay = 0,
        input bit [2:0] prot = 3'b000
    );
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create("write_req");
        start_item(req);
        req.cmd           = AXI_LITE_WRITE;
        req.addr          = addr;
        req.data          = data;
        req.strb          = strb;
        req.prot          = prot;
        req.aw_delay      = aw_delay;
        req.w_delay       = w_delay;
        req.b_ready_delay = b_ready_delay;
        finish_item(req);
    endtask

    virtual task send_read(
        input bit [AXI_LITE_ADDR_WIDTH-1:0] addr,
        input int unsigned ar_delay = 0,
        input int unsigned r_ready_delay = 0,
        input bit [2:0] prot = 3'b000
    );
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create("read_req");
        start_item(req);
        req.cmd           = AXI_LITE_READ;
        req.addr          = addr;
        req.data          = '0;
        req.strb          = '0;
        req.prot          = prot;
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
            prot == 3'b000;
        }) begin
            `uvm_error("AXI_LITE_BASE_SEQ", "Random AXI-Lite transaction randomization failed")
        end

        if (req.cmd == AXI_LITE_READ) begin
            req.strb = '0;
        end

        finish_item(req);
    endtask

    virtual task start_subseq(axi_lite_base_seq seq);
        seq.start(m_sequencer, this);
    endtask

endclass
