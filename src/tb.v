`timescale 1ns/1ps
`default_nettype none

module tb;
  reg        clk, rst_n;
  reg  [7:0] ui_in;
  wire [7:0] uo_out;

  // Instantiate DUT
  tt_um_example dut (
    .ui_in  (ui_in),
    .uo_out (uo_out),
    .uio_in (8'b0),
    .uio_out(),
    .uio_oe (),
    .ena    (1'b1),
    .clk    (clk),
    .rst_n  (rst_n)
  );

  // 10ns clock
  initial clk = 0;
  always #5 clk = ~clk;

  integer i;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    // Reset
    rst_n = 0; ui_in = 0;
    repeat(4) @(posedge clk);
    rst_n = 1;

    // Step response: jump from 0 to 200, watch output settle
    $display("=== Step Response (0 -> 200) ===");
    ui_in = 8'd200;
    for (i = 0; i < 40; i = i+1) begin
      @(posedge clk);
      #1 $display("cycle %0d: in=%0d out=%0d", i, ui_in, uo_out);
    end

    // Impulse: one cycle of 255 then back to 0
    $display("=== Impulse then decay ===");
    ui_in = 8'd255;
    @(posedge clk); #1;
    ui_in = 8'd0;
    for (i = 0; i < 20; i = i+1) begin
      @(posedge clk);
      #1 $display("cycle %0d: in=%0d out=%0d", i, ui_in, uo_out);
    end

    $finish;
  end
endmodule
