`timescale 1ns/1ps

module tb_axi_lite_regs;

  localparam int unsigned AXI_ADDR_WIDTH = 32;
  localparam int unsigned AXI_DATA_WIDTH = 32;
  localparam int unsigned REG_NUM_BYTES  = 32;
  localparam int unsigned STRB_WIDTH     = AXI_DATA_WIDTH / 8;

  typedef logic [7:0] byte_t;

  logic clk;
  logic rst_n;

  logic [REG_NUM_BYTES-1:0] wr_active;
  logic [REG_NUM_BYTES-1:0] rd_active;

  byte_t [REG_NUM_BYTES-1:0] reg_d;
  logic  [REG_NUM_BYTES-1:0] reg_load;
  byte_t [REG_NUM_BYTES-1:0] reg_q;

  logic [AXI_DATA_WIDTH-1:0] rdata;
  int unsigned error_count;

  // ------------------------------------------------------------
  // PULP AXI-Lite interface
  // ------------------------------------------------------------
  AXI_LITE #(
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH)
  ) axi_lite_if ();

  // ------------------------------------------------------------
  // DUT: PULP axi_lite_regs_intf
  // ------------------------------------------------------------
  axi_lite_regs_intf #(
    .REG_NUM_BYTES  (REG_NUM_BYTES),
    .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH)
  ) dut (
    .clk_i       (clk),
    .rst_ni      (rst_n),
    .slv         (axi_lite_if),
    .wr_active_o (wr_active),
    .rd_active_o (rd_active),
    .reg_d_i     (reg_d),
    .reg_load_i  (reg_load),
    .reg_q_o     (reg_q)
  );

  // ------------------------------------------------------------
  // Clock
  // ------------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // ------------------------------------------------------------
  // Init AXI master-side signals
  // ------------------------------------------------------------
  task automatic init_axi_master();
    axi_lite_if.aw_addr  <= '0;
    axi_lite_if.aw_prot  <= '0;
    axi_lite_if.aw_valid <= 1'b0;

    axi_lite_if.w_data   <= '0;
    axi_lite_if.w_strb   <= '0;
    axi_lite_if.w_valid  <= 1'b0;

    axi_lite_if.b_ready  <= 1'b0;

    axi_lite_if.ar_addr  <= '0;
    axi_lite_if.ar_prot  <= '0;
    axi_lite_if.ar_valid <= 1'b0;

    axi_lite_if.r_ready  <= 1'b0;
  endtask

  // ------------------------------------------------------------
  // Reset helper
  // ------------------------------------------------------------
  task automatic apply_reset();
    rst_n    = 1'b0;
    reg_d    = '{default: 8'h00};
    reg_load = '0;

    init_axi_master();

    repeat (5) @(posedge clk);
    rst_n = 1'b1;
    repeat (5) @(posedge clk);
  endtask

  // ------------------------------------------------------------
  // AXI-Lite write task
  //
  // Note:
  // This DUT accepts write when AWVALID and WVALID are both high.
  // Therefore this first smoke test drives AW and W together.
  // ------------------------------------------------------------
  task automatic axi_write(
    input logic [AXI_ADDR_WIDTH-1:0] addr,
    input logic [AXI_DATA_WIDTH-1:0] data,
    input logic [STRB_WIDTH-1:0]     strb
  );
    $display("[%0t] AXI WRITE START addr=0x%08h data=0x%08h strb=0x%0h",
             $time, addr, data, strb);

    @(posedge clk);

    axi_lite_if.aw_addr  <= addr;
    axi_lite_if.aw_prot  <= 3'b000;
    axi_lite_if.aw_valid <= 1'b1;

    axi_lite_if.w_data   <= data;
    axi_lite_if.w_strb   <= strb;
    axi_lite_if.w_valid  <= 1'b1;

    axi_lite_if.b_ready  <= 1'b1;

    // Wait for AW and W handshake.
    do begin
      @(posedge clk);
    end while (!(axi_lite_if.aw_ready && axi_lite_if.w_ready));

    axi_lite_if.aw_valid <= 1'b0;
    axi_lite_if.w_valid  <= 1'b0;
    axi_lite_if.aw_addr  <= '0;
    axi_lite_if.w_data   <= '0;
    axi_lite_if.w_strb   <= '0;

    // Wait for B response.
    do begin
      @(posedge clk);
    end while (!axi_lite_if.b_valid);

    if (axi_lite_if.b_resp !== 2'b00) begin
      $error("[%0t] AXI WRITE RESP ERROR addr=0x%08h resp=%0d",
             $time, addr, axi_lite_if.b_resp);
    end else begin
      $display("[%0t] AXI WRITE OK addr=0x%08h resp=OKAY",
               $time, addr);
    end

    @(posedge clk);
    axi_lite_if.b_ready <= 1'b0;
  endtask

  // ------------------------------------------------------------
  // AXI-Lite read task
  // ------------------------------------------------------------
  task automatic axi_read(
    input  logic [AXI_ADDR_WIDTH-1:0] addr,
    output logic [AXI_DATA_WIDTH-1:0] data
  );
    $display("[%0t] AXI READ START addr=0x%08h", $time, addr);

    @(posedge clk);

    axi_lite_if.ar_addr  <= addr;
    axi_lite_if.ar_prot  <= 3'b000;
    axi_lite_if.ar_valid <= 1'b1;

    axi_lite_if.r_ready  <= 1'b1;

    // Wait for AR handshake.
    do begin
      @(posedge clk);
    end while (!axi_lite_if.ar_ready);

    axi_lite_if.ar_valid <= 1'b0;
    axi_lite_if.ar_addr  <= '0;

    // Wait for R response.
    do begin
      @(posedge clk);
    end while (!axi_lite_if.r_valid);

    data = axi_lite_if.r_data;

    if (axi_lite_if.r_resp !== 2'b00) begin
      $error("[%0t] AXI READ RESP ERROR addr=0x%08h resp=%0d data=0x%08h",
             $time, addr, axi_lite_if.r_resp, data);
    end else begin
      $display("[%0t] AXI READ OK addr=0x%08h data=0x%08h resp=OKAY",
               $time, addr, data);
    end

    @(posedge clk);
    axi_lite_if.r_ready <= 1'b0;
  endtask

  // ------------------------------------------------------------
  // Read and compare helper
  // ------------------------------------------------------------
  task automatic expect_read(
    input logic [AXI_ADDR_WIDTH-1:0] addr,
    input logic [AXI_DATA_WIDTH-1:0] expected,
    input string                     test_name
  );
    axi_read(addr, rdata);

    if (rdata !== expected) begin
      error_count++;
      $error("[%0t] %s FAILED: addr=0x%08h actual=0x%08h expected=0x%08h",
             $time, test_name, addr, rdata, expected);
    end else begin
      $display("[%0t] %s PASSED: addr=0x%08h data=0x%08h",
               $time, test_name, addr, rdata);
    end
  endtask

  // ------------------------------------------------------------
  // Main test
  // ------------------------------------------------------------
  initial begin
    error_count = 0;

    apply_reset();

    // Reset/default value
    expect_read(32'h0000_0000, 32'h0000_0000, "RESET DEFAULT TEST");

    // Basic write/read
    axi_write(32'h0000_0000, 32'h1234_5678, 4'hF);
    expect_read(32'h0000_0000, 32'h1234_5678, "BASIC WRITE/READ TEST");

    // Byte strobe: update only byte lane 1.
    axi_write(32'h0000_0000, 32'hFFFF_FFFF, 4'hF);
    axi_write(32'h0000_0000, 32'h0000_AA00, 4'b0010);
    expect_read(32'h0000_0000, 32'hFFFF_AAFF, "BYTE STROBE TEST");

    // Multiple register addresses.
    axi_write(32'h0000_0004, 32'hDEAD_BEEF, 4'hF);
    axi_write(32'h0000_0008, 32'hCAFE_CAFE, 4'hF);
    expect_read(32'h0000_0000, 32'hFFFF_AAFF, "MULTI ADDR TEST ADDR0");
    expect_read(32'h0000_0004, 32'hDEAD_BEEF, "MULTI ADDR TEST ADDR4");
    expect_read(32'h0000_0008, 32'hCAFE_CAFE, "MULTI ADDR TEST ADDR8");

    // Reset should restore default register values.
    apply_reset();
    expect_read(32'h0000_0000, 32'h0000_0000, "POST RESET TEST ADDR0");
    expect_read(32'h0000_0004, 32'h0000_0000, "POST RESET TEST ADDR4");
    expect_read(32'h0000_0008, 32'h0000_0000, "POST RESET TEST ADDR8");

    if (error_count == 0) begin
      $display("[%0t] ALL DIRECTED TESTS PASSED", $time);
    end else begin
      $fatal(1, "[%0t] DIRECTED TESTS FAILED: error_count=%0d", $time, error_count);
    end

    repeat (10) @(posedge clk);
    $finish;
  end

endmodule
