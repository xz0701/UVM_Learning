`timescale 1ns/1ps

module tb_mux_top;

    import uvm_pkg::*;
    import axi_lite_pkg::*;

    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) slv_if [AXI_LITE_MUX_NUM_SLV-1:0] ();

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) mst_if ();

    axi_lite_ctrl_if #(
        .REG_NUM_BYTES(AXI_LITE_REG_NUM_BYTES),
        .DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) ctrl_if (
        .clk   (clk),
        .rst_n (rst_n)
    );

    initial begin
        rst_n            = 1'b0;
        ctrl_if.reg_d    = '{default: 8'h00};
        ctrl_if.reg_load = '0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    axi_lite_mux_intf #(
        .AxiAddrWidth (AXI_LITE_ADDR_WIDTH),
        .AxiDataWidth (AXI_LITE_DATA_WIDTH),
        .NoSlvPorts   (AXI_LITE_MUX_NUM_SLV),
        .MaxTrans     (AXI_LITE_MUX_MAX_TRANS)
    ) dut (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .test_i (1'b0),
        .slv    (slv_if),
        .mst    (mst_if)
    );

    axi_lite_mem_slave #(
        .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH),
        .MEM_WORDS      (AXI_LITE_MUX_MEM_WORDS)
    ) mem_slv_i (
        .clk_i  (clk),
        .rst_ni (rst_n),
        .slv    (mst_if)
    );

    for (genvar i = 0; i < AXI_LITE_MUX_NUM_SLV; i++) begin : gen_slv_assertions
        axi_lite_assertions #(
            .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
            .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH)
        ) slv_assertions_i (
            .clk   (clk),
            .rst_n (rst_n),
            .axi   (slv_if[i])
        );
    end

    initial begin
        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.agt_0.*",
            "axi_vif",
            slv_if[0]
        );

        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.agt_1.*",
            "axi_vif",
            slv_if[1]
        );

        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.downstream_mon",
            "axi_vif",
            mst_if
        );

        uvm_config_db#(axi_lite_ctrl_vif_t)::set(
            null,
            "*",
            "ctrl_vif",
            ctrl_if
        );

        run_test();
    end

endmodule
