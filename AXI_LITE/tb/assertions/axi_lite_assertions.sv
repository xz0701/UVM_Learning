module axi_lite_assertions #(
    parameter int unsigned AXI_ADDR_WIDTH = 32,
    parameter int unsigned AXI_DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_n,
    AXI_LITE.Monitor axi
);

    property p_aw_valid_held;
        @(posedge clk) disable iff (!rst_n)
        axi.aw_valid && !axi.aw_ready |=> axi.aw_valid;
    endproperty

    property p_aw_payload_stable;
        @(posedge clk) disable iff (!rst_n)
        axi.aw_valid && !axi.aw_ready |=> $stable({axi.aw_addr, axi.aw_prot});
    endproperty

    property p_w_valid_held;
        @(posedge clk) disable iff (!rst_n)
        axi.w_valid && !axi.w_ready |=> axi.w_valid;
    endproperty

    property p_w_payload_stable;
        @(posedge clk) disable iff (!rst_n)
        axi.w_valid && !axi.w_ready |=> $stable({axi.w_data, axi.w_strb});
    endproperty

    property p_ar_valid_held;
        @(posedge clk) disable iff (!rst_n)
        axi.ar_valid && !axi.ar_ready |=> axi.ar_valid;
    endproperty

    property p_ar_payload_stable;
        @(posedge clk) disable iff (!rst_n)
        axi.ar_valid && !axi.ar_ready |=> $stable({axi.ar_addr, axi.ar_prot});
    endproperty

    property p_b_valid_held;
        @(posedge clk) disable iff (!rst_n)
        axi.b_valid && !axi.b_ready |=> axi.b_valid;
    endproperty

    property p_b_payload_stable;
        @(posedge clk) disable iff (!rst_n)
        axi.b_valid && !axi.b_ready |=> $stable(axi.b_resp);
    endproperty

    property p_r_valid_held;
        @(posedge clk) disable iff (!rst_n)
        axi.r_valid && !axi.r_ready |=> axi.r_valid;
    endproperty

    property p_r_payload_stable;
        @(posedge clk) disable iff (!rst_n)
        axi.r_valid && !axi.r_ready |=> $stable({axi.r_data, axi.r_resp});
    endproperty

    a_aw_valid_held: assert property (p_aw_valid_held)
        else $error("AXI_LITE_ASSERT: AWVALID dropped before AWREADY");

    a_aw_payload_stable: assert property (p_aw_payload_stable)
        else $error("AXI_LITE_ASSERT: AW payload changed before handshake");

    a_w_valid_held: assert property (p_w_valid_held)
        else $error("AXI_LITE_ASSERT: WVALID dropped before WREADY");

    a_w_payload_stable: assert property (p_w_payload_stable)
        else $error("AXI_LITE_ASSERT: W payload changed before handshake");

    a_ar_valid_held: assert property (p_ar_valid_held)
        else $error("AXI_LITE_ASSERT: ARVALID dropped before ARREADY");

    a_ar_payload_stable: assert property (p_ar_payload_stable)
        else $error("AXI_LITE_ASSERT: AR payload changed before handshake");

    a_b_valid_held: assert property (p_b_valid_held)
        else $error("AXI_LITE_ASSERT: BVALID dropped before BREADY");

    a_b_payload_stable: assert property (p_b_payload_stable)
        else $error("AXI_LITE_ASSERT: B payload changed before handshake");

    a_r_valid_held: assert property (p_r_valid_held)
        else $error("AXI_LITE_ASSERT: RVALID dropped before RREADY");

    a_r_payload_stable: assert property (p_r_payload_stable)
        else $error("AXI_LITE_ASSERT: R payload changed before handshake");

endmodule
