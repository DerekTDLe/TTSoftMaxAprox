`default_nettype none
`timescale 1ns / 1ps

module tb_sum4_tree;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_sum4_tree);
    #1;
  end

  reg  [7:0] a_i;
  reg  [7:0] b_i;
  reg  [7:0] c_i;
  reg  [7:0] d_i;
  wire [9:0] sum_o;

  sum4_tree dut (
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),
    .d_i(d_i),
    .sum_o(sum_o)
  );

endmodule
