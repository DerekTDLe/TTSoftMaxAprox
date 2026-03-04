/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module sum4_tree( //Combinational adder tree (registered).
    input  wire [7:0] a_i, b_i, c_i, d_i,
    output reg  [7:0] sum_o
);
    always @(*) begin
        sum_o = a_i + b_i + c_i + d_i;
    end
    
endmodule