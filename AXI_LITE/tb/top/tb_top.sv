`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import axi_lite_pkg::*;

    `include "uvm_macros.svh"

    logic clk;
    logic rst_n;

    typedef logic [7:0] byte_t;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    AXI_LITE #(
        .AXI_ADDR_WIDTH(AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH(AXI_LITE_DATA_WIDTH)
    ) axi_if ();

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

    axi_lite_regs_intf #(
        .byte_t         (byte_t),
        .REG_NUM_BYTES  (AXI_LITE_REG_NUM_BYTES),
        .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH),
        .PRIV_PROT_ONLY (AXI_LITE_PRIV_PROT_ONLY),
        .SECU_PROT_ONLY (AXI_LITE_SECU_PROT_ONLY),
        .AXI_READ_ONLY  (AXI_LITE_READ_ONLY_MASK)
    ) dut (
        .clk_i       (clk),
        .rst_ni      (rst_n),
        .slv         (axi_if),
        .wr_active_o (ctrl_if.wr_active),
        .rd_active_o (ctrl_if.rd_active),
        .reg_d_i     (ctrl_if.reg_d),
        .reg_load_i  (ctrl_if.reg_load),
        .reg_q_o     (ctrl_if.reg_q)
    );

    axi_lite_assertions #(
        .AXI_ADDR_WIDTH (AXI_LITE_ADDR_WIDTH),
        .AXI_DATA_WIDTH (AXI_LITE_DATA_WIDTH)
    ) axi_lite_assertions_i (
        .clk   (clk),
        .rst_n (rst_n),
        .axi   (axi_if)
    );

    initial begin
        uvm_config_db#(axi_lite_vif_t)::set(
            null,
            "*",
            "axi_vif",
            axi_if
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
