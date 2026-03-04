`default_nettype none
`timescale 1ns / 1ps

module tb_recip_nr;

  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_recip_nr);
    #1;
  end

  reg clk;
  reg rst_n;
  reg start;
  reg [7:0] x_i;
  wire [7:0] recip_o;
  wire valid;

  recip_nr dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .x_i(x_i),
    .recip_o(recip_o),
    .valid(valid)
  );

endmodule
