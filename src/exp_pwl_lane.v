/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module exp_pwl_lane( //Gate-optimized 5-segment PWL exponential approximation
    input  wire [7:0] x_i, //input signed 8-bit
    output wire [7:0] exp_o //output unsigned 8-bit
);
    // Optimized PWL: 5 segments with 8-bit coefficients (no large multipliers)
    // Approximates e^x without using x*32 or larger multiplies
    
    wire signed [7:0] x_s = x_i;
    reg signed [15:0] y_s;
    reg [7:0] exp_o_reg;

    always @(*) begin
        if (x_s <= -8'sd8) begin
            y_s = 16'sd0;
        end else if (x_s > 8'sd0) begin
            // x > 0: approximately constant at 255 (e^x >> 1 for x > 0)
            y_s = 16'sd255;
        end else if (x_s < -8'sd6) begin
            // [-8, -6): e^x ≈ x + 8 (coarse but avoids mult)
            y_s = x_s + 16'sd8;
        end else if (x_s < -8'sd4) begin
            // [-6, -4): e^x ≈ 2*x + 16
            y_s = (x_s <<< 1) + 16'sd16;
        end else if (x_s < -8'sd2) begin
            // [-4, -2): e^x ≈ 4*x + 32
            y_s = (x_s <<< 2) + 16'sd32;
        end else begin
            // [-2, 0]: e^x ≈ 16*x + 128 (includes x=0 → e^0=128≈1)
            y_s = (x_s <<< 4) + 16'sd128;
        end

        // Saturate to [0, 255]
        if (y_s < 16'sd0)
            exp_o_reg = 8'd0;
        else if (y_s > 16'sd255)
            exp_o_reg = 8'd255;
        else
            exp_o_reg = y_s[7:0];
    end

    assign exp_o = exp_o_reg;
    
endmodule

`default_nettype wire

`default_nettype wire