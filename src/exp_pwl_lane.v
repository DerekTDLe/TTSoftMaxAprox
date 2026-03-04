/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module exp_pwl_lane( //Minimal 4-segment shift-based PWL
    input  wire [7:0] x_i, //input signed 8-bit
    output wire [7:0] exp_o //output unsigned 8-bit
);
    // 4-segment PWL using only shifts and adds (no multiplies)
    
    wire signed [7:0] x_s = x_i;
    reg signed [15:0] y_s;
    reg [7:0] exp_o_reg;

    always @(*) begin
        if (x_s <= -8'sd8) begin
            y_s = 16'sd0;
        end else if (x_s > 8'sd0) begin
            y_s = 16'sd255;
        end else if (x_s < -8'sd6) begin
            // [-8, -6): e^x ≈ 2*x + 16 = (x << 1) + 16
            y_s = (x_s <<< 1) + 16'sd16;
        end else if (x_s < -8'sd3) begin
            // [-6, -3): e^x ≈ 4*x + 32 = (x << 2) + 32
            y_s = (x_s <<< 2) + 16'sd32;
        end else begin
            // [-3, 0]: e^x ≈ 8*x + 64 = (x << 3) + 64 (x=0 gives 64)
            y_s = (x_s <<< 3) + 16'sd64;
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