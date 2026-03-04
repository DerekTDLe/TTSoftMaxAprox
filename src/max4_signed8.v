/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module max4_signed8( //find the maximum of 4 signed 8-bit numbers
    input  wire [7:0] a_i, b_i, c_i, d_i,
    output wire [7:0] max_val_o
);
    wire signed [7:0] max_ab = (a_i > b_i) ? a_i : b_i;
    wire signed [7:0] max_cd = (c_i > d_i) ? c_i : d_i;
    assign max_val_o = (max_ab > max_cd) ? max_ab : max_cd;
endmodule