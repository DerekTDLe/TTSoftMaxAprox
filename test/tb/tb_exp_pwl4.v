`default_nettype none
`timescale 1ns / 1ps

module tb_exp_pwl4;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_exp_pwl4);
    #1;
  end

  reg  [7:0] x0_i;
  reg  [7:0] x1_i;
  reg  [7:0] x2_i;
  reg  [7:0] x3_i;

  wire [7:0] p0;
  wire [7:0] p1;
  wire [7:0] p2;
  wire [7:0] p3;

  exp_pwl4 dut (
    .x0_i(x0_i),
    .x1_i(x1_i),
    .x2_i(x2_i),
    .x3_i(x3_i),
    .p0(p0),
    .p1(p1),
    .p2(p2),
    .p3(p3)
  );

endmodule
