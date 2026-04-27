/*
 * Copyright (c) 2024 Elton DMello
 * SPDX-License-Identifier: Apache-2.0
 *
 * 1st-order IIR Low-pass (Exponential Moving Average)
 * Uses shift-and-subtract only — no multipliers.
 *
 * Equation (integer domain, scaled by 2^ALPHA):
 *   acc <= acc - (acc >> ALPHA) + ui_in
 *
 * Output = acc >> ALPHA  (top 8 bits of scaled accumulator)
 * With ALPHA=3: smoothing factor α ≈ 0.125, strong low-pass.
 */
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,   // 8-bit unsigned PCM / sensor sample in
    output wire [7:0] uo_out,  // 8-bit low-pass filtered output
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

  // ALPHA controls cutoff: higher = more smoothing (lower cutoff)
  // ALPHA=3 → α=1/8.  ACC needs 8 + ALPHA bits to hold scaled value.
  localparam ALPHA = 3;
  localparam ACC_W = 8 + ALPHA; // 11 bits

  reg [ACC_W-1:0] acc;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= 0;
    end else begin
      // acc holds y[n] * 2^ALPHA
      // y[n] = y[n-1]*(1 - 1/8) + x[n]*(1/8)
      // scaled: acc_new = acc - (acc>>ALPHA) + ui_in
      acc <= acc - (acc >> ALPHA) + {3'b000, ui_in};
    end
  end

  // Divide back down: output = acc / 2^ALPHA = acc >> ALPHA
  assign uo_out  = acc[ACC_W-1:ALPHA]; // bits [10:3] → 8-bit result
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;

  wire _unused = &{ena, uio_in, 1'b0};

endmodule
