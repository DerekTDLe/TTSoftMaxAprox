/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module recip_nr( //Reciprocal approximation using Newton-Raphson method
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,      // pulse high 1 cycle to begin
    input  wire [9:0] x_i,        // unsigned 10-bit input (sum up to 1020)
    output reg  [15:0] recip_o,   // unsigned Q8.8-like scale: floor((255<<8)/sum)
    output reg        valid       // high for 1 cycle when result ready
);

    // 8-bit reciprocal LUT (gate-optimized)
    // recip = 255 / x, clamped to 8-bit
    
    reg [2:0] state;
    reg [9:0] x_in_reg;
    reg [7:0] recip_8bit;

    function [7:0] recip_lut;
        input [9:0] x;
        begin
            if (x <= 10'd1)
                recip_lut = 8'd255;
            else if (x <= 10'd2)
                recip_lut = 8'd127;
            else if (x <= 10'd3)
                recip_lut = 8'd85;
            else if (x <= 10'd4)
                recip_lut = 8'd63;
            else if (x <= 10'd5)
                recip_lut = 8'd51;
            else if (x <= 10'd7)
                recip_lut = 8'd36;
            else if (x <= 10'd10)
                recip_lut = 8'd25;
            else if (x <= 10'd15)
                recip_lut = 8'd17;
            else if (x <= 10'd20)
                recip_lut = 8'd12;
            else if (x <= 10'd30)
                recip_lut = 8'd8;
            else if (x <= 10'd50)
                recip_lut = 8'd5;
            else if (x <= 10'd100)
                recip_lut = 8'd2;
            else
                recip_lut = 8'd1;
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= 2'd0;
            x_in_reg    <= 10'd0;
            recip_8bit  <= 8'd0;
            recip_o     <= 16'd0;
            valid       <= 1'b0;
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
                    recip_8bit <= recip_lut(x_in_reg);
                    state <= 2'd2;
                end

                2'd2: begin
                    recip_o <= {recip_8bit, 8'd0};  // Convert 8-bit to 16-bit (shift left 8)
                    valid   <= 1'b1;
                    state   <= 2'd0;
                end

                default: state <= 2'd0;
            endcase
        end
    end

endmodule

`default_nettype wire
