class axi_lite_tr extends uvm_sequence_item;

    rand axi_lite_cmd_e cmd;
    rand bit [31:0] addr;
    rand bit [31:0] data;
    rand bit [3:0] strb;
    rand bit [2:0] prot;
    rand int unsigned aw_delay;
    rand int unsigned w_delay;
    rand int unsigned b_ready_delay;
    rand int unsigned ar_delay;
    rand int unsigned r_ready_delay;

    bit [31:0] rdata;
    bit [1:0] resp;
    axi_lite_wr_order_e wr_order;
    int unsigned b_wait_cycles;
    int unsigned r_wait_cycles;

    constraint addr_align_c {
        addr[1:0] == 2'b00;
    }

    constraint strb_nonzero_c {
        cmd == AXI_LITE_WRITE -> strb != '0;
    }

    constraint delay_limit_c {
        aw_delay      inside {[0:5]};
        w_delay       inside {[0:5]};
        b_ready_delay inside {[0:5]};
        ar_delay      inside {[0:5]};
        r_ready_delay inside {[0:5]};
    }

    `uvm_object_utils_begin(axi_lite_tr)
        `uvm_field_enum(axi_lite_cmd_e, cmd, UVM_DEFAULT)
        `uvm_field_int(addr,  UVM_DEFAULT)
        `uvm_field_int(data,  UVM_DEFAULT)
        `uvm_field_int(strb,  UVM_DEFAULT)
        `uvm_field_int(prot,  UVM_DEFAULT)
        `uvm_field_int(aw_delay,      UVM_DEFAULT)
        `uvm_field_int(w_delay,       UVM_DEFAULT)
        `uvm_field_int(b_ready_delay, UVM_DEFAULT)
        `uvm_field_int(ar_delay,      UVM_DEFAULT)
        `uvm_field_int(r_ready_delay, UVM_DEFAULT)
        `uvm_field_int(rdata, UVM_DEFAULT)
        `uvm_field_int(resp,  UVM_DEFAULT)
        `uvm_field_enum(axi_lite_wr_order_e, wr_order, UVM_DEFAULT)
        `uvm_field_int(b_wait_cycles, UVM_DEFAULT)
        `uvm_field_int(r_wait_cycles, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi_lite_tr");
        super.new(name);
    endfunction

endclass
