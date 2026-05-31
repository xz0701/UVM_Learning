`timescale 1ns/1ns

`ifndef WR_CLK_PERIOD
    `define WR_CLK_PERIOD 10
`endif

`ifndef RD_CLK_PERIOD
    `define RD_CLK_PERIOD 15
`endif

module tb_top;

    import uvm_pkg::*;
    import async_fifo_param_pkg::*;
    import async_fifo_pkg::*;

    `include "uvm_macros.svh"

    logic wr_clk;
    logic wr_rstn;
    logic rd_clk;
    logic rd_rstn;

    initial begin
        wr_clk = 0;
        forever #(`WR_CLK_PERIOD/2) wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0;
        forever #(`RD_CLK_PERIOD/2) rd_clk = ~rd_clk;
    end

    initial begin
        wr_rstn = 1'b0;
        rd_rstn = 1'b0;

        repeat (5) @(posedge wr_clk);
        repeat (5) @(posedge rd_clk);

        wr_rstn = 1'b1;
        rd_rstn = 1'b1;
    end

    async_fifo_if #(
        .WIDTH(WIDTH) 
    ) async_fifo_vif();

    assign async_fifo_vif.wr_clk = wr_clk;
    assign async_fifo_vif.wr_rstn = wr_rstn;
    assign async_fifo_vif.rd_clk = rd_clk;
    assign async_fifo_vif.rd_rstn = rd_rstn;

    async_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wr_clk(async_fifo_vif.wr_clk),
        .wr_rstn(async_fifo_vif.wr_rstn),
        .wr_en(async_fifo_vif.wr_en),
        .wr_data(async_fifo_vif.wr_data),
        .rd_clk(async_fifo_vif.rd_clk),
        .rd_rstn(async_fifo_vif.rd_rstn),
        .rd_en(async_fifo_vif.rd_en),
        .rd_data(async_fifo_vif.rd_data),
        .full(async_fifo_vif.full),
        .empty(async_fifo_vif.empty)
    );

    initial begin

        uvm_config_db#(virtual async_fifo_if)::set(
            null, 
            "uvm_test_top", 
            "vif", 
            async_fifo_vif
        );

        uvm_config_db#(virtual async_fifo_if)::set(
            null, 
            "uvm_test_top.env.*", 
            "vif", 
            async_fifo_vif
        );

        // uvm_config_db#(virtual async_fifo_if)::set(
        //     null, 
        //     "uvm_test_top.env.*", 
        //     "vif", 
        //     async_fifo_vif
        // );

        run_test("async_fifo_test");
    end
endmodule