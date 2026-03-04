`default_nettype none
`timescale 1ns / 1ps

module tb_serializer4;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_serializer4);
    #1;
  end

  reg clk;
  reg rst_n;
  reg start;
  reg [7:0] d0_i;
  reg [7:0] d1_i;
  reg [7:0] d2_i;
  reg [7:0] d3_i;

  wire [7:0] data_o;
  wire valid_o;
  wire busy_o;

  serializer4 dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .d0_i(d0_i),
    .d1_i(d1_i),
    .d2_i(d2_i),
    .d3_i(d3_i),
    .data_o(data_o),
    .valid_o(valid_o),
    .busy_o(busy_o)
  );

endmodule
