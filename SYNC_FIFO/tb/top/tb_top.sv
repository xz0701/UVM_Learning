module tb_top;

    import uvm_pkg::*;
    import sync_fifo_param_pkg::*;
    import sync_fifo_pkg::*;

    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
    end

    sync_fifo_if #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)       
    ) sync_fifo_vif (
        .clk(clk),
        .rst_n(rst_n)
    );

    sync_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(sync_fifo_vif.clk),
        .rst_n(sync_fifo_vif.rst_n),
        .rd_en(sync_fifo_vif.rd_en),
        .wr_en(sync_fifo_vif.wr_en),
        .rdata(sync_fifo_vif.rd_data),
        .wdata(sync_fifo_vif.wr_data),
        .empty(sync_fifo_vif.empty),
        .full(sync_fifo_vif.full)
    );

    initial begin
        uvm_config_db#(virtual sync_fifo_if)::set(
            null,
            "*",
            "vif",
            sync_fifo_vif
        );

        run_test("sync_fifo_test");
    end
endmodule