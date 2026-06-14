class axi_lite_tr extends uvm_sequence_item;

    rand axi_lite_cmd_e cmd;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0] strb;

    bit [31:0] rdata;
    bit [1:0] resp;

    constraint addr_align_c {
        addr[1:0] == 2'b00;
    }

    constraint strb_nonzero_c {
        cmd == AXI_LITE_WRITE -> strb != '0;
    }

    `uvm_object_utils_begin(axi_lite_tr)
        `uvm_field_enum(axi_lite_cmd_e, cmd, UVM_DEFAULT)
        `uvm_field_int(addr,  UVM_DEFAULT)
        `uvm_field_int(data,  UVM_DEFAULT)
        `uvm_field_int(strb,  UVM_DEFAULT)
        `uvm_field_int(rdata, UVM_DEFAULT)
        `uvm_field_int(resp,  UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi_lite_tr");
        super.new(name);
    endfunction

endclass
