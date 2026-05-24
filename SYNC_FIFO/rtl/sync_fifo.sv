module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 wr_en,
    input  logic                 rd_en,
    input  logic [WIDTH - 1 : 0] wdata,
    output logic [WIDTH - 1 : 0] rdata,
    output logic                 full,
    output logic                 empty
);
    
    logic [WIDTH - 1 : 0] mem [0 : DEPTH - 1];
    localparam PTR_WIDTH = $clog2(DEPTH);
    logic [PTR_WIDTH - 1 : 0] wr_ptr;
    logic [PTR_WIDTH - 1 : 0] rd_ptr;
    logic [PTR_WIDTH : 0] counter;

    logic write_real, read_real;

    assign write_real = wr_en && (!full || rd_en);
    assign read_real  = rd_en && !empty;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset should be DEPTH, not DEPTH - 1
            for (int i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= '0;
            end
            wr_ptr <= '0;
            rd_ptr <= '0;
            rdata  <= '0;
        end
        else begin
            if (write_real) begin
                mem[wr_ptr] <= wdata;
                wr_ptr      <= wr_ptr + 1'b1;
            end
            if (read_real) begin
                rdata       <= mem[rd_ptr];
                rd_ptr      <= rd_ptr + 1'b1;
            end
        end
    end

    // Deal with counter, if write and read happen at the same time,
    // Counter should keep same value
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= '0;
        else begin
            unique case ({write_real, read_real})
                2'b00  : counter <= counter;
                2'b01  : counter <= counter - 1'b1;
                2'b10  : counter <= counter + 1'b1;
                2'b11  : counter <= counter; 
                default: counter <= counter;
            endcase
        end
    end

    // empty
    assign empty = (counter == 0);
    // full
    assign full  = (counter == DEPTH);
endmodule