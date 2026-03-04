/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module serializer4( //serialize 4 bytes over 4 cycles
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] d0_i,
    input  wire [7:0] d1_i,
    input  wire [7:0] d2_i,
    input  wire [7:0] d3_i,
    output reg  [7:0] data_o,
    output reg        valid_o,
    output reg        busy_o
);

    reg [7:0] data_reg0;
    reg [7:0] data_reg1;
    reg [7:0] data_reg2;
    reg [7:0] data_reg3;
    reg [1:0] idx;
    reg       stream_active;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg0 <= 8'd0;
            data_reg1 <= 8'd0;
            data_reg2 <= 8'd0;
            data_reg3 <= 8'd0;
            data_o    <= 8'd0;
            valid_o   <= 1'b0;
            busy_o    <= 1'b0;
            idx       <= 2'd0;
            stream_active <= 1'b0;
        end else begin
            valid_o <= 1'b0;

            if (start && !busy_o) begin
                data_reg0 <= d0_i;
                data_reg1 <= d1_i;
                data_reg2 <= d2_i;
                data_reg3 <= d3_i;
                busy_o  <= 1'b1;
                idx     <= 2'd0;
                stream_active <= 1'b1;
            end else if (busy_o) begin
                if (stream_active) begin
                    case (idx)
                        2'd0: begin
                            data_o  <= data_reg0;
                            valid_o <= 1'b1;
                            idx     <= 2'd1;
                        end
                        2'd1: begin
                            data_o  <= data_reg1;
                            valid_o <= 1'b1;
                            idx     <= 2'd2;
                        end
                        2'd2: begin
                            data_o  <= data_reg2;
                            valid_o <= 1'b1;
                            idx     <= 2'd3;
                        end
                        default: begin
                            data_o  <= data_reg3;
                            valid_o <= 1'b1;
                            stream_active <= 1'b0;
                        end
                    endcase
                end else begin
                    busy_o  <= 1'b0;
                    idx     <= 2'd0;
                end
            end
        end
    end

endmodule
