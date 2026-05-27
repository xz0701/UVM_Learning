class async_fifo_wr_tr extends uvm_sequence_item;

    rand bit wr_en;
    rand bit [WIDTH - 1 : 0] wr_data;
         bit full;
    
    `uvm_object_utils_begin (async_fifo_wr_tr)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(wr_data, UVM_ALL_ON)
        `uvm_field_int(full, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "async_fifo_wr_tr");
        super.new(name);
    endfunction

endclass