class axi_lite_test extends axi_lite_full_cov_test;

    `uvm_component_utils(axi_lite_test)

    function new(string name = "axi_lite_test", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
