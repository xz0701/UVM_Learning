module tb_top;

    import uvm_pkg::*;
    import alu_pkg::*;

    `include "uvm_macros.svh"
    
    localparam int WIDTH = 8;

    logic clk;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    alu_if #(
        .WIDTH(WIDTH)
    ) alu_vif (
        .clk(clk)
    );

    alu #(
        .WIDTH(WIDTH)
    ) dut (
        .a(alu_vif.a),
        .b(alu_vif.b),
        .op(alu_vif.op),
        .out(alu_vif.out)
    );

    initial begin
        uvm_config_db#(virtual alu_if)::set(
            null,
            "*",
            "vif",
            alu_vif
        );

        run_test("alu_test");
    end
endmodule