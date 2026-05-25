module dual_port_ram #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic                     wr_clk,
    input  logic                     wr_en,
    input  logic [$clog2(DEPTH)-1:0] wr_addr,
    input  logic [WIDTH - 1 : 0]     wr_data,

    input  logic                     rd_clk,
    input  logic                     rd_en,
    input  logic [$clog2(DEPTH)-1:0] rd_addr,
    output logic [WIDTH - 1 : 0]     rd_data
);
    
    logic [WIDTH - 1 : 0] mem [0 : DEPTH - 1];
    
    always_ff @(posedge wr_clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
    end

    always_ff @(posedge rd_clk) begin
        if (rd_en)
            rd_data <= mem[rd_addr];
    end

endmodule