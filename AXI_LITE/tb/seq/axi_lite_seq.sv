class axi_lite_seq extends uvm_sequence #(axi_lite_tr);

    `uvm_object_utils(axi_lite_seq)

    function new(string name = "axi_lite_seq");
        super.new(name);
    endfunction

    virtual task body();
        axi_lite_tr req;

        req = axi_lite_tr::type_id::create("write_0");
        start_item(req);
        req.cmd  = AXI_LITE_WRITE;
        req.addr = 32'h0000_0000;
        req.data = 32'h1234_5678;
        req.strb = 4'hf;
        finish_item(req);

        req = axi_lite_tr::type_id::create("read_0");
        start_item(req);
        req.cmd  = AXI_LITE_READ;
        req.addr = 32'h0000_0000;
        req.data = '0;
        req.strb = '0;
        finish_item(req);

        req = axi_lite_tr::type_id::create("write_full");
        start_item(req);
        req.cmd  = AXI_LITE_WRITE;
        req.addr = 32'h0000_0000;
        req.data = 32'hffff_ffff;
        req.strb = 4'hf;
        finish_item(req);

        req = axi_lite_tr::type_id::create("write_byte1");
        start_item(req);
        req.cmd  = AXI_LITE_WRITE;
        req.addr = 32'h0000_0000;
        req.data = 32'h0000_aa00;
        req.strb = 4'b0010;
        finish_item(req);

        req = axi_lite_tr::type_id::create("read_byte_strobe_result");
        start_item(req);
        req.cmd  = AXI_LITE_READ;
        req.addr = 32'h0000_0000;
        req.data = '0;
        req.strb = '0;
        finish_item(req);
    endtask

endclass
