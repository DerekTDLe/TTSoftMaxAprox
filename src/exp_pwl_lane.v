/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module exp_pwl_lane( //test to compute a single lane of the exp approximation
    input  wire [7:0] x_i, //input signed 8-bit
    output wire [7:0] exp_o //output unsigned 8-bit
);
    //case approximations, starting with 6 segments
    //([-8,-6):; y \approx 0.5x + 4)
    //([-6,-4):; y \approx 2x + 13)
    //([-4,-3):; y \approx 8x + 37)
    //([-3,-2):; y \approx 22x + 79)
    //([-2,-1):; y \approx 59x + 153)
    //([-1,0]:; y \approx 161x + 255)

    wire signed [7:0] x_s = x_i;
    reg signed [15:0] y_s;
    reg [7:0] exp_o_reg;

    always @(*) begin
        if (x_s <= -8'sd8) begin
            y_s = 16'sd0;
        end else if (x_s >= 8'sd0) begin
            y_s = 16'sd255;
        end else if (x_s < -8'sd6) begin
            y_s = (x_s >>> 1) + 16'sd4; //0.5x + 4
        end else if (x_s < -8'sd4) begin
            y_s = (x_s <<< 1) + 16'sd13; //2x + 13
        end else if (x_s < -8'sd3) begin
            y_s = (x_s <<< 3) + 16'sd37; //8x + 37
        end else if (x_s < -8'sd2) begin
            y_s = (x_s * 16'sd22) + 16'sd79; //22x + 79
        end else if (x_s < -8'sd1) begin
            y_s = (x_s * 16'sd59) + 16'sd153; //59x + 153
        end else begin
            y_s = (x_s * 16'sd161) + 16'sd255; //161x + 255
        end

        if (y_s < 16'sd0)
            exp_o_reg = 8'd0;
        else if (y_s > 16'sd255)
            exp_o_reg = 8'd255;
        else
            exp_o_reg = y_s[7:0];
    end

    assign exp_o = exp_o_reg;
    
endmodule