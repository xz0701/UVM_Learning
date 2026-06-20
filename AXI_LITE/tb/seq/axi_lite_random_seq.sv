class axi_lite_random_seq extends axi_lite_base_seq;

    int unsigned num_items = 50;

    `uvm_object_utils_begin(axi_lite_random_seq)
        `uvm_field_int(num_items, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi_lite_random_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (num_items) begin
            send_random_access($urandom_range(0, 32'hffff));
        end
    endtask

endclass
