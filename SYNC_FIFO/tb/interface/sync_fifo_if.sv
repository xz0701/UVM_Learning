`ifndef SYNC_FIFO_IF_SV
`define SYNC_FIFO_IF_SV

interface sync_fifo_if #(
    parameter int WIDTH = sync_fifo_param_pkg::WIDTH,
    parameter int DEPTH = sync_fifo_param_pkg::DEPTH
)(
    input logic clk,
    input logic rst_n
);

    logic             rd_en;
    logic             wr_en;
    logic [WIDTH-1:0] rd_data;
    logic [WIDTH-1:0] wr_data;
    logic             empty;
    logic             full;

    logic [$clog2(DEPTH+1) - 1 : 0] occ_cnt;
    wire wr_accept;
    wire rd_accept;

    assign wr_accept = wr_en && (!full || rd_en);
    assign rd_accept = rd_en && !empty;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            occ_cnt <= '0;
        end
        else begin
            unique case ({wr_accept, rd_accept})
                2'b10: occ_cnt <= occ_cnt + 1'b1;
                2'b01: occ_cnt <= occ_cnt - 1'b1;
                default: occ_cnt <= occ_cnt;
            endcase
        end
    end

    // check reset
    property p_reset_state;
        @ (posedge clk)
        !rst_n |-> (empty && !full);
    endproperty

    a_reset_state: assert property (p_reset_state)
        else $error("FIFO reset state error: empty should be 1 and full should be 0");
    
    // full and empty should not be high at the same time
    property p_no_full_empty_same_time;
        @ (posedge clk) disable iff(!rst_n) 
        !(full && empty);
    endproperty

    a_no_full_empty_same_time: assert property (p_no_full_empty_same_time)
        else $error("FIFO empty and full should note be high at the same time");
    
    // occupancy should never exceed DEPTH
    property p_occ_cnt_range;
        @ (posedge clk) disable iff(!rst_n)
        occ_cnt <= DEPTH;
    endproperty

    a_occ_cnt_range: assert property (p_occ_cnt_range)
        else $error("FIFO occupancy exceeds DEPTH");

    // empty flag should match occupancy model
    property p_empty_exact;
        @(posedge clk) disable iff (!rst_n)
        empty == (occ_cnt == 0);
    endproperty

    a_empty_exact: assert property (p_empty_exact)
        else $error("FIFO empty flag mismatch with occupancy model");

    // full flag should match occupancy model
    property p_full_exact;
        @(posedge clk) disable iff (!rst_n)
        full == (occ_cnt == DEPTH);
    endproperty

    a_full_exact: assert property (p_full_exact)
        else $error("FIFO full flag mismatch with occupancy model");

    // Empty + simultaneous read/write: write accepted, read ignored
    property p_empty_rw_behavior;
        @(posedge clk) disable iff (!rst_n)
        (empty && wr_en && rd_en) |=> (!empty);
    endproperty

    a_empty_rw_behavior: assert property (p_empty_rw_behavior)
        else $error("Empty + read/write should leave one item in FIFO");

    // Full + simultaneous read/write: read and write both accepted, occupancy remains full
    property p_full_rw_behavior;
        @(posedge clk) disable iff (!rst_n)
        (full && wr_en && rd_en) |=> full;
    endproperty

    a_full_rw_behavior: assert property (p_full_rw_behavior)
        else $error("Full + read/write should keep FIFO full");

endinterface

`endif