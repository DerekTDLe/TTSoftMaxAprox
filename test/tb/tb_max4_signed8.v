`default_nettype none
`timescale 1ns / 1ps

module tb_max4_signed8;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_max4_signed8);
    #1;
  end

  reg [7:0] a_i;
  reg [7:0] b_i;
  reg [7:0] c_i;
  reg [7:0] d_i;
  wire [7:0] max_val_o;

  max4_signed8 dut (
    .a_i(a_i),
    .b_i(b_i),
    .c_i(c_i),
    .d_i(d_i),
    .max_val_o(max_val_o)
  );

endmodule
