interface async_fifo_if #(
    parameter WIDTH = 8
);

    logic                 wr_clk;
    logic                 wr_rstn;
    logic                 wr_en;
    logic [WIDTH - 1 : 0] wr_data;
    
    logic                 rd_clk;
    logic                 rd_rstn;
    logic                 rd_en;
    logic [WIDTH - 1 : 0] rd_data;
    
    logic                 full;
    logic                 empty;

    property p_wr_no_x;
        @(posedge wr_clk) disable iff (!wr_rstn)
        !$isunknown({wr_en, wr_data, full});
    endproperty

    a_wr_no_x: assert property (p_wr_no_x)
        else $error("ASYNC_FIFO_IF: X detected in write domain signals");

    property p_no_write_when_full;
        @(posedge wr_clk) disable iff (!wr_rstn)
        full |-> !wr_en;
    endproperty

    // This is optional as an environment assumption/assertion.
    // If your test intentionally drives wr_en when full to test blocking,
    // do NOT enable this as assert.
    // a_no_write_when_full: assert property (p_no_write_when_full)
    //     else $error("ASYNC_FIFO_IF: wr_en asserted while full");

    property p_full_known_after_reset;
        @(posedge wr_clk) disable iff (!wr_rstn)
        !$isunknown(full);
    endproperty

    a_full_known_after_reset: assert property (p_full_known_after_reset)
        else $error("ASYNC_FIFO_IF: full is X after reset release");


    // ----------------------------
    // Read clock domain assertions
    // ----------------------------

    property p_rd_ctrl_no_x;
        @(posedge rd_clk) disable iff (!rd_rstn)
        !$isunknown({rd_en, empty});
    endproperty

    a_rd_ctrl_no_x: assert property (p_rd_ctrl_no_x)
        else $error("ASYNC_FIFO_IF: X detected in read control signals");

    property p_no_read_when_empty;
        @(posedge rd_clk) disable iff (!rd_rstn)
        empty |-> !rd_en;
    endproperty

    // This is optional as an environment assumption/assertion.
    // If your test intentionally drives rd_en when empty to test blocking,
    // do NOT enable this as assert.
    // a_no_read_when_empty: assert property (p_no_read_when_empty)
    //     else $error("ASYNC_FIFO_IF: rd_en asserted while empty");

    property p_empty_known_after_reset;
        @(posedge rd_clk) disable iff (!rd_rstn)
        !$isunknown(empty);
    endproperty

    a_empty_known_after_reset: assert property (p_empty_known_after_reset)
        else $error("ASYNC_FIFO_IF: empty is X after reset release");

    property p_rd_data_no_x_when_valid;
        @(posedge rd_clk) disable iff (!rd_rstn)
        (rd_en && !empty) |=> !$isunknown(rd_data);
    endproperty

    a_rd_data_no_x_when_valid: assert property (p_rd_data_no_x_when_valid)
        else $error("ASYNC_FIFO_IF: rd_data is X after accepted read");


    // ----------------------------
    // Reset behavior
    // ----------------------------

    property p_full_low_after_wr_reset;
        @(posedge wr_clk)
        !wr_rstn |-> (full == 1'b0);
    endproperty

    a_full_low_after_wr_reset: assert property (p_full_low_after_wr_reset)
        else $error("ASYNC_FIFO_IF: full should be 0 during write reset");

    property p_empty_high_after_rd_reset;
        @(posedge rd_clk)
        !rd_rstn |-> (empty == 1'b1);
    endproperty

    a_empty_high_after_rd_reset: assert property (p_empty_high_after_rd_reset)
        else $error("ASYNC_FIFO_IF: empty should be 1 during read reset");

endinterface