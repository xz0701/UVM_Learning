`timescale 1ns/1ps

module axi_lite_mem_slave #(
    parameter int unsigned AXI_ADDR_WIDTH = 32,
    parameter int unsigned AXI_DATA_WIDTH = 32,
    parameter int unsigned MEM_WORDS      = 16
) (
    input logic clk_i,
    input logic rst_ni,
    AXI_LITE.Slave slv
);

    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0] data_t;
    typedef logic [AXI_STRB_WIDTH-1:0] strb_t;

    data_t mem [MEM_WORDS];

    addr_t aw_addr_q;
    data_t w_data_q;
    strb_t w_strb_q;
    logic  aw_pending_q;
    logic  w_pending_q;

    function automatic int unsigned word_index(addr_t addr);
        return (addr >> $clog2(AXI_STRB_WIDTH)) % MEM_WORDS;
    endfunction

    assign slv.aw_ready = rst_ni && !aw_pending_q && !slv.b_valid;
    assign slv.w_ready  = rst_ni && !w_pending_q  && !slv.b_valid;
    assign slv.ar_ready = rst_ni && !slv.r_valid;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            aw_addr_q    <= '0;
            w_data_q     <= '0;
            w_strb_q     <= '0;
            aw_pending_q <= 1'b0;
            w_pending_q  <= 1'b0;
            slv.b_valid  <= 1'b0;
            slv.b_resp   <= axi_pkg::RESP_OKAY;
            slv.r_valid  <= 1'b0;
            slv.r_resp   <= axi_pkg::RESP_OKAY;
            slv.r_data   <= '0;

            foreach (mem[i]) begin
                mem[i] <= '0;
            end
        end else begin
            if (slv.b_valid && slv.b_ready) begin
                slv.b_valid <= 1'b0;
            end

            if (slv.r_valid && slv.r_ready) begin
                slv.r_valid <= 1'b0;
            end

            if (slv.aw_valid && slv.aw_ready) begin
                aw_addr_q    <= slv.aw_addr;
                aw_pending_q <= 1'b1;
            end

            if (slv.w_valid && slv.w_ready) begin
                w_data_q    <= slv.w_data;
                w_strb_q    <= slv.w_strb;
                w_pending_q <= 1'b1;
            end

            if (aw_pending_q && w_pending_q && !slv.b_valid) begin
                for (int unsigned i = 0; i < AXI_STRB_WIDTH; i++) begin
                    if (w_strb_q[i]) begin
                        mem[word_index(aw_addr_q)][8*i +: 8] <= w_data_q[8*i +: 8];
                    end
                end

                aw_pending_q <= 1'b0;
                w_pending_q  <= 1'b0;
                slv.b_resp   <= axi_pkg::RESP_OKAY;
                slv.b_valid  <= 1'b1;
            end

            if (slv.ar_valid && slv.ar_ready) begin
                slv.r_data  <= mem[word_index(slv.ar_addr)];
                slv.r_resp  <= axi_pkg::RESP_OKAY;
                slv.r_valid <= 1'b1;
            end
        end
    end

endmodule
