`timescale 1ns/1ps

module tb_xbar_top;

    import uvm_pkg::*;
    import axi_pkg::*;
    import axi_lite_pkg::*;

    `include "uvm_macros.svh"

    typedef axi_pkg::xbar_rule_32_t xbar_rule_t;

    localparam axi_pkg::xbar_cfg_t XBAR_CFG = '{
        NoSlvPorts:   AXI_LITE_XBAR_NUM_SLV,
        NoMstPorts:   AXI_LITE_XBAR_NUM_MST,
        MaxMstTrans:  AXI_LITE_XBAR_MAX_MST_TRANS,
        MaxSlvTrans:  AXI_LITE_XBAR_MAX_SLV_TRANS,
        FallThrough:  1'b0,
        LatencyMode:  axi_pkg::CUT_ALL_AX,
        AxiAddrWidth: AXI_LITE_ADDR_WIDTH,
        AxiDataWidth: AXI_LITE_DATA_WIDTH,
        NoAddrRules:  AXI_LITE_XBAR_NUM_ADDR_RULES,
        default:      '0
    };

    localparam xbar_rule_t [AXI_LITE_XBAR_NUM_ADDR_RULES-1:0] XBAR_ADDR_MAP = '{
        '{
            idx:        32'd1,
            start_addr: AXI_LITE_XBAR_MST1_BASE,
            end_addr:   AXI_LITE_XBAR_MST1_BASE + AXI_LITE_XBAR_REGION_SIZE
        },
        '{
            idx:        32'd0,
            start_addr: AXI_LITE_XBAR_MST0_BASE,
            end_addr:   AXI_LITE_XBAR_MST0_BASE + AXI_LITE_XBAR_REGION_SIZE
        }
    };

    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) slv_if [AXI_LITE_XBAR_NUM_SLV-1:0] ();

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) mst_if [AXI_LITE_XBAR_NUM_MST-1:0] ();

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

    axi_lite_xbar_intf #(
        .Cfg    (XBAR_CFG),
        .rule_t (xbar_rule_t)
    ) dut (
        .clk_i                 (clk),
        .rst_ni                (rst_n),
        .test_i                (1'b0),
        .slv_ports             (slv_if),
        .mst_ports             (mst_if),
        .addr_map_i            (XBAR_ADDR_MAP),
        .en_default_mst_port_i ('0),
        .default_mst_port_i    ('0)
    );

    for (genvar i = 0; i < AXI_LITE_XBAR_NUM_MST; i++) begin : gen_mem_slv
        axi_lite_mem_slave #(
            .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
            .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH),
            .MEM_WORDS      (AXI_LITE_XBAR_MEM_WORDS)
        ) mem_slv_i (
            .clk_i  (clk),
            .rst_ni (rst_n),
            .slv    (mst_if[i])
        );
    end

    for (genvar i = 0; i < AXI_LITE_XBAR_NUM_SLV; i++) begin : gen_slv_assertions
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
            "uvm_test_top.env.slv_agt_0.*",
            "axi_vif",
            slv_if[0]
        );

        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "uvm_test_top.env.slv_agt_1.*",
            "axi_vif",
            slv_if[1]
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
