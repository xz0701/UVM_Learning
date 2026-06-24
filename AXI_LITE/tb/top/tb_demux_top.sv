`timescale 1ns/1ps

module tb_demux_top;

    import uvm_pkg::*;
    import axi_lite_pkg::*;

    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;
    logic [AXI_LITE_DEMUX_SEL_WIDTH-1:0] slv_aw_select;
    logic [AXI_LITE_DEMUX_SEL_WIDTH-1:0] slv_ar_select;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) slv_if ();

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) mst_if [AXI_LITE_DEMUX_NUM_MST-1:0] ();

    axi_lite_ctrl_if #(
        .REG_NUM_BYTES(AXI_LITE_REG_NUM_BYTES),
        .DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) ctrl_if (
        .clk   (clk),
        .rst_n (rst_n)
    );

    assign slv_aw_select = slv_if.aw_addr[AXI_LITE_DEMUX_SELECT_ADDR_BIT +: AXI_LITE_DEMUX_SEL_WIDTH];
    assign slv_ar_select = slv_if.ar_addr[AXI_LITE_DEMUX_SELECT_ADDR_BIT +: AXI_LITE_DEMUX_SEL_WIDTH];

    initial begin
        rst_n            = 1'b0;
        ctrl_if.reg_d    = '{default: 8'h00};
        ctrl_if.reg_load = '0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    axi_lite_demux_intf #(
        .AxiAddrWidth (AXI_LITE_ADDR_WIDTH),
        .AxiDataWidth (AXI_LITE_DATA_WIDTH),
        .NoMstPorts   (AXI_LITE_DEMUX_NUM_MST),
        .MaxTrans     (AXI_LITE_DEMUX_MAX_TRANS)
    ) dut (
        .clk_i           (clk),
        .rst_ni          (rst_n),
        .test_i          (1'b0),
        .slv_aw_select_i (slv_aw_select),
        .slv_ar_select_i (slv_ar_select),
        .slv             (slv_if),
        .mst             (mst_if)
    );

    for (genvar i = 0; i < AXI_LITE_DEMUX_NUM_MST; i++) begin : gen_mem_slv
        axi_lite_mem_slave #(
            .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
            .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH),
            .MEM_WORDS      (AXI_LITE_DEMUX_MEM_WORDS)
        ) mem_slv_i (
            .clk_i  (clk),
            .rst_ni (rst_n),
            .slv    (mst_if[i])
        );
    end

    axi_lite_assertions #(
        .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH)
    ) slv_assertions_i (
        .clk   (clk),
        .rst_n (rst_n),
        .axi   (slv_if)
    );

    initial begin
        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.agt.*",
            "axi_vif",
            slv_if
        );

        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.mst_mon_0",
            "axi_vif",
            mst_if[0]
        );

        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.mst_mon_1",
            "axi_vif",
            mst_if[1]
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
