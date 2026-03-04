`default_nettype none
`timescale 1ns / 1ps

module tb_scale4_clip;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_scale4_clip);
    #1;
  end

  reg  [7:0] p0_i;
  reg  [7:0] p1_i;
  reg  [7:0] p2_i;
  reg  [7:0] p3_i;
  reg  [15:0] recip_i;

  wire [7:0] y0_o;
  wire [7:0] y1_o;
  wire [7:0] y2_o;
  wire [7:0] y3_o;

  scale4_clip dut (
    .p0_i(p0_i),
    .p1_i(p1_i),
    .p2_i(p2_i),
    .p3_i(p3_i),
    .recip_i(recip_i),
    .y0_o(y0_o),
    .y1_o(y1_o),
    .y2_o(y2_o),
    .y3_o(y3_o)
  );

endmodule
