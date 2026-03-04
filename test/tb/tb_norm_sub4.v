`default_nettype none
`timescale 1ns / 1ps

module tb_norm_sub4;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_norm_sub4);
    #1;
  end

  reg [7:0] a_i;
  reg [7:0] b_i;
  reg [7:0] c_i;
  reg [7:0] d_i;
  reg [7:0] max_i;

  wire [7:0] a_o;
  wire [7:0] b_o;
  wire [7:0] c_o;
  wire [7:0] d_o;

  norm_sub4 dut (
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),
    .d_i(d_i),
    .max_i(max_i),
    .a_o(a_o),
    .b_o(b_o),
    .c_o(c_o),
    .d_o(d_o)
  );

endmodule
