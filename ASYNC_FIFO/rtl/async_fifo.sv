module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic                 wr_clk,
    input  logic                 wr_rstn,
    input  logic                 wr_en,
    input  logic [WIDTH - 1 : 0] wr_data,

    input  logic                 rd_clk,
    input  logic                 rd_rstn,
    input  logic                 rd_en,
    output logic [WIDTH - 1 : 0] rd_data,
    
    output logic                 full,
    output logic                 empty
);
    
    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam PTR_WIDTH  = ADDR_WIDTH + 1;

    logic [PTR_WIDTH - 1 : 0] wr_bin;
    logic [PTR_WIDTH - 1 : 0] wr_gray;
    logic [PTR_WIDTH - 1 : 0] wr_bin_next;
    logic [PTR_WIDTH - 1 : 0] wr_gray_next;

    logic [PTR_WIDTH - 1 : 0] rd_bin;
    logic [PTR_WIDTH - 1 : 0] rd_gray;
    logic [PTR_WIDTH - 1 : 0] rd_bin_next;
    logic [PTR_WIDTH - 1 : 0] rd_gray_next;

    logic [PTR_WIDTH - 1 : 0] wr_gray_rd_sync1;
    logic [PTR_WIDTH - 1 : 0] wr_gray_rd_sync2;
    logic [PTR_WIDTH - 1 : 0] rd_gray_wr_sync1;
    logic [PTR_WIDTH - 1 : 0] rd_gray_wr_sync2;

    logic wr_real, rd_real;

    assign wr_real = wr_en && !full;
    assign rd_real = rd_en && !empty;
    
    function automatic logic [PTR_WIDTH-1:0] bin2gray(
        input logic [PTR_WIDTH-1:0] bin
    );
        bin2gray = bin ^ (bin>>1);
    endfunction

    assign wr_bin_next = wr_bin + {{(PTR_WIDTH-1){1'b0}}, wr_real};
    assign rd_bin_next = rd_bin + {{(PTR_WIDTH-1){1'b0}}, rd_real};

    assign wr_gray_next = bin2gray(wr_bin_next);
    assign rd_gray_next = bin2gray(rd_bin_next);

    always_ff @(posedge wr_clk or negedge wr_rstn) begin
        if (!wr_rstn) begin
            wr_bin  <= '0;
            wr_gray <= '0;
            full    <= 1'b0;
        end
        else begin
            wr_bin  <= wr_bin_next;
            wr_gray <= wr_gray_next;

            full <= (wr_gray_next == {
                ~rd_gray_wr_sync2[PTR_WIDTH - 1],
                ~rd_gray_wr_sync2[PTR_WIDTH - 2],
                 rd_gray_wr_sync2[PTR_WIDTH - 3 : 0]
            });
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rstn) begin
        if (!rd_rstn) begin
            rd_bin  <= '0;
            rd_gray <= '0;
            empty   <= 1'b1;
        end
        else begin
            rd_bin  <= rd_bin_next;
            rd_gray <= rd_gray_next;

            empty <= (rd_gray_next == wr_gray_rd_sync2);
        end
    end

    always_ff @(posedge wr_clk or negedge wr_rstn) begin
        if (!wr_rstn) begin
            rd_gray_wr_sync1 <= '0;
            rd_gray_wr_sync2 <= '0;
        end
        else begin
            rd_gray_wr_sync1 <= rd_gray;
            rd_gray_wr_sync2 <= rd_gray_wr_sync1;
        end
    end

    always_ff @(posedge rd_clk or negedge rd_rstn) begin
        if (!rd_rstn) begin
            wr_gray_rd_sync1 <= '0;
            wr_gray_rd_sync2 <= '0;
        end
        else begin
            wr_gray_rd_sync1 <= wr_gray;
            wr_gray_rd_sync2 <= wr_gray_rd_sync1;
        end
    end

    dual_port_ram #(
        .WIDTH      (WIDTH),
        .DEPTH      (DEPTH)
    ) u_dual_port_ram (
        .wr_clk  (wr_clk),
        .wr_en   (wr_real),
        .wr_addr (wr_bin[ADDR_WIDTH - 1 : 0]),
        .wr_data (wr_data),

        .rd_clk  (rd_clk),
        .rd_en   (rd_real),
        .rd_addr (rd_bin[ADDR_WIDTH - 1 : 0]),
        .rd_data (rd_data)
    );
endmodule