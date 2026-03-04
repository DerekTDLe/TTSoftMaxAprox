/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module norm_sub4( //compute the diff between max and each of 4 inputs
    input  wire [7:0] a_i, b_i, c_i, d_i,
    input wire [7:0] max_i,
    output wire [7:0] a_o, b_o, c_o, d_o
);
    assign a_o = a_i - max_i;
    assign b_o = b_i - max_i;
    assign c_o = c_i - max_i;
    assign d_o = d_i - max_i;
endmodule