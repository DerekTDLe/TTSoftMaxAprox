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

    reg [7:0] exp_o_reg; //WIP
    always @(*) begin
        if (x_i < -6) begin
            exp_o_reg = (x_i >>> 1) + 4; //0.5x + 4
        end else if (x_i < -4) begin
            exp_o_reg = (x_i <<< 1) + 13; //2x + 13
        end else if (x_i < -3) begin
            exp_o_reg = (x_i <<< 3) + 37; //8x + 37
        end else if (x_i < -2) begin
            exp_o_reg = (x_i * 22) + 79; //22x + 79
        end else if (x_i < -1) begin
            exp_o_reg = (x_i * 59) + 153; //59x + 153
        end else begin
            exp_o_reg = (x_i * 161) + 255; //161x + 255
        end
    end
    assign exp_o = exp_o_reg;
    
endmodule