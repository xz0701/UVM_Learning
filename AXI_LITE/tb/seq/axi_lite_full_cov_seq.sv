class axi_lite_full_cov_seq extends axi_lite_base_seq;

    `uvm_object_utils(axi_lite_full_cov_seq)

    function new(string name = "axi_lite_full_cov_seq");
        super.new(name);
    endfunction

    virtual task body();
        axi_lite_smoke_seq smoke_seq;
        axi_lite_strobe_seq strobe_seq;
        axi_lite_backpressure_seq backpressure_seq;
        axi_lite_invalid_addr_seq invalid_addr_seq;
        axi_lite_random_seq random_seq;

        smoke_seq = axi_lite_smoke_seq::type_id::create("smoke_seq");
        strobe_seq = axi_lite_strobe_seq::type_id::create("strobe_seq");
        backpressure_seq = axi_lite_backpressure_seq::type_id::create("backpressure_seq");
        invalid_addr_seq = axi_lite_invalid_addr_seq::type_id::create("invalid_addr_seq");
        random_seq = axi_lite_random_seq::type_id::create("random_seq");

        start_subseq(smoke_seq);
        start_subseq(strobe_seq);
        start_subseq(backpressure_seq);
        start_subseq(invalid_addr_seq);
        start_subseq(random_seq);
    endtask

endclass
