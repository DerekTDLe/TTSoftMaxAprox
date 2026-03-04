/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module sum4_tree( //Combinational adder tree (registered).
    input  wire [7:0] a_i, b_i, c_i, d_i,
    output reg  [7:0] sum_o
);
    reg [9:0] sum_full;

    always @(*) begin // WIP
        sum_full = a_i + b_i + c_i + d_i;
        if (sum_full > 10'd255)
            sum_o = 8'd255;
        else
            sum_o = sum_full[7:0];
    end
    
endmodule