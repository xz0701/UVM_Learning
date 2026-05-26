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

endinterface