class axi_lite_read_only_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_read_only_seq)

    function new(string name = "axi_lite_read_only_seq");
        super.new(name);
    endfunction

    virtual task body();
        send_read (32'h0000_0000, 0, 0);
        send_write(32'h0000_0000, 32'hdead_beef, 4'hf, 0, 0, 0);
        send_read (32'h0000_0000, 1, 1);

        send_write(32'h0000_0004, 32'h1122_3344, 4'hf, 0, 1, 1);
        send_read (32'h0000_0004, 1, 2);

        send_write(32'h0000_0004, 32'hffff_ffff, 4'h3, 1, 0, 2);
        send_read (32'h0000_0004, 2, 1);

        send_write(32'h0000_0004, 32'ha5a5_a5a5, 4'hc, 2, 0, 0);
        send_read (32'h0000_0004, 0, 3);

        send_write(32'h0000_0008, 32'h1234_5678, 4'hf, 0, 0, 1);
        send_read (32'h0000_0008, 1, 0);
    endtask

endclass
