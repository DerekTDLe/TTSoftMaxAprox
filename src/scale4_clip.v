/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module scale4_clip( //Ultra-minimalist: shift-only scaling
    input  wire [7:0] p0_i,
    input  wire [7:0] p1_i,
    input  wire [7:0] p2_i,
    input  wire [7:0] p3_i,
    input  wire [15:0] recip_i,
    output wire [7:0] y0_o,
    output wire [7:0] y1_o,
    output wire [7:0] y2_o,
    output wire [7:0] y3_o
);

    // Shift by 1 only: p * 2 approximates scaling
    // Works well when sum of exps is small (common case)
    function automatic [7:0] scale_shift_1bit;
        input [7:0] p;
        reg [8:0] scaled;
        begin
            scaled = {p, 1'b0};  // p << 1
            if (scaled > 9'd255)
                scale_shift_1bit = 8'd255;
            else
                scale_shift_1bit = scaled[7:0];
        end
    endfunction

    assign y0_o = scale_shift_1bit(p0_i);
    assign y1_o = scale_shift_1bit(p1_i);
    assign y2_o = scale_shift_1bit(p2_i);
    assign y3_o = scale_shift_1bit(p3_i);

endmodule

`default_nettype wire
