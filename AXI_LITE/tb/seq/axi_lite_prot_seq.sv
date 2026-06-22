class axi_lite_prot_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_prot_seq)

    function new(string name = "axi_lite_prot_seq");
        super.new(name);
    endfunction

    virtual task body();
        send_write(32'h0000_0014, 32'hdead_beef, 4'hf, 0, 0, 0, 3'b000);
        send_read (32'h0000_0014, 0, 0, 3'b000);
        send_read (32'h0000_0014, 0, 0, 3'b011);

        send_write(32'h0000_0014, 32'h1111_2222, 4'hf, 0, 1, 0, 3'b001);
        send_write(32'h0000_0014, 32'h3333_4444, 4'hf, 1, 0, 1, 3'b010);
        send_read (32'h0000_0014, 1, 1, 3'b011);

        send_write(32'h0000_0014, 32'ha5a5_f00d, 4'hf, 0, 0, 0, 3'b011);
        send_read (32'h0000_0014, 0, 0, 3'b011);
        send_read (32'h0000_0014, 1, 0, 3'b111);

        send_write(32'h0000_0018, 32'hcafe_5678, 4'hf, 0, 0, 1, 3'b111);
        send_read (32'h0000_0018, 0, 1, 3'b011);
    endtask

endclass
