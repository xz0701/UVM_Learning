class axi_lite_invalid_addr_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_invalid_addr_seq)

    function new(string name = "axi_lite_invalid_addr_seq");
        super.new(name);
    endfunction

    virtual task body();
        send_write(32'h0000_0020, 32'hdead_beef, 4'hf, 0, 0, 0);
        send_read (32'h0000_0020, 0, 0);
        send_write(32'h0000_0024, 32'hcafe_f00d, 4'b0011, 0, 2, 1);
        send_read (32'h0000_0024, 1, 2);

        send_write(32'h0000_0100, 32'h1357_2468, 4'b1100, 3, 0, 2);
        send_read (32'h0000_0100, 2, 0);
    endtask

endclass
