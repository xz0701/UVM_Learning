class async_fifo_rd_tr extends uvm_sequence_item;

    rand bit rd_en;
         bit [WIDTH - 1 : 0] rd_data;
         bit empty;
    
    `uvm_object_utils_begin (async_fifo_rd_tr)
        `uvm_field_int(rd_en, UVM_ALL_ON)
        `uvm_field_int(rd_data, UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "async_fifo_rd_tr");
        super.new(name);
    endfunction

endclass