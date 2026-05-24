`ifndef SYNC_FIFO_TRANSACTION_SV
`define SYNC_FIFO_TRANSACTION_SV

class sync_fifo_transaction extends uvm_sequence_item;

    parameter int WIDTH = 8;
    
    rand bit             wr_en;
    rand bit             rd_en;
    rand bit [WIDTH-1:0] wr_data;
    
    logic                rst_n;
    logic    [WIDTH-1:0] rd_data;
    logic                empty;
    logic                full;

    `uvm_object_utils_begin(sync_fifo_transaction)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(rd_en, UVM_ALL_ON)
        `uvm_field_int(wr_data, UVM_ALL_ON)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(rd_data, UVM_ALL_ON)
        `uvm_field_int(empty, UVM_ALL_ON)
        `uvm_field_int(full, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "sync_fifo_transaction");
        super.new(name);
    endfunction

endclass

`endif