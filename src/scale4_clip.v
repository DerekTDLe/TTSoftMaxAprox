/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module scale4_clip( //scale 4 lanes by reciprocal and clip to 8-bit
    input  wire [7:0] p0_i,
    input  wire [7:0] p1_i,
    input  wire [7:0] p2_i,
    input  wire [7:0] p3_i,
    input  wire [7:0] recip_i,
    output wire [7:0] y0_o,
    output wire [7:0] y1_o,
    output wire [7:0] y2_o,
    output wire [7:0] y3_o
);

    function automatic [7:0] mul_clip_u8;
        input [7:0] a;
        input [7:0] b;
        reg [15:0] prod;
        begin
            prod = a * b;
            if (prod > 16'd255)
                mul_clip_u8 = 8'd255;
            else
                mul_clip_u8 = prod[7:0];
        end
    endfunction

    assign y0_o = mul_clip_u8(p0_i, recip_i);
    assign y1_o = mul_clip_u8(p1_i, recip_i);
    assign y2_o = mul_clip_u8(p2_i, recip_i);
    assign y3_o = mul_clip_u8(p3_i, recip_i);

endmodule
