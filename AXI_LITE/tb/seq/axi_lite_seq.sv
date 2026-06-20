class axi_lite_seq extends axi_lite_full_cov_seq;

    `uvm_object_utils(axi_lite_seq)

    function new(string name = "axi_lite_seq");
        super.new(name);
    endfunction

endclass
