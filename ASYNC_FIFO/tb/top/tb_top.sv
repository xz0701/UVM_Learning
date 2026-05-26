`timescale 1ns/1ns

module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    async_fifo_if #(
        .WIDTH(WIDTH) 
    ) fifo_if();

    async_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wr_clk(wr_clk),
        .wr_rstn(wr_rstn),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_clk(rd_clk),
        .rd_rstn(rd_rstn),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    initial begin
        fifo_if.wr_clk = 1'b0;
        forever #5 fifo_if.wr_clk = ~fifo_if.wr_clk;
    end

    initial begin
        fifo_if.rd_clk = 1'b0;
        forever #8 fifo_if.rd_clk = ~fifo_if.rd_clk;
    end

    initial begin
        fifo_if.wr_rstn = 1'b0;
        fifo_if.rd_rstn = 1'b0;
        fifo_if.wr_en = 1'b0;
        fifo_if.wr_data = '0;
        fifo_if.rd_en = 1'b0;

        repeat (5) @(posedge fifo_if.wr_clk);
        repeat (5) @(posedge fifo_if.rd_clk);

        fifo_if.wr_rstn = 1'b1;
        fifo_if.rd_rstn = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual async_fifo_if #(WIDTH))::set(
            null, 
            "uvm_test_top", 
            "vif", 
            fifo_if
        );

        run_test();
    end

    initial begin
        #1000;
        $finish;
    end
endmodule