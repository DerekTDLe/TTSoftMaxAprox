/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module recip_nr( //Minimal 4-entry reciprocal LUT
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [9:0] x_i,
    output reg  [15:0] recip_o,
    output reg        valid
);

    reg [1:0] state;
    reg [9:0] x_in_reg;

    function [15:0] recip_lut;
        input [9:0] x;
        begin
            if (x <= 10'd10)
                recip_lut = 16'd65280;   // 255 << 8
            else if (x <= 10'd50)
                recip_lut = 16'd32640;   // 127 << 8
            else if (x <= 10'd200)
                recip_lut = 16'd16320;   // 63 << 8
            else
                recip_lut = 16'd8160;    // 31 << 8
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= 2'd0;
            x_in_reg <= 10'd0;
            recip_o  <= 16'd0;
            valid    <= 1'b0;
        end else begin
            valid <= 1'b0;

            case (state)
                2'd0: begin
                    if (start) begin
                        x_in_reg <= x_i;
                        state <= 2'd1;
                    end
                end

                2'd1: begin
                    recip_o <= recip_lut(x_in_reg);
                    state <= 2'd2;
                end

                2'd2: begin
                    valid <= 1'b1;
                    state <= 2'd0;
                end

                default: state <= 2'd0;
            endcase
        end
    end

endmodule

`default_nettype wire
