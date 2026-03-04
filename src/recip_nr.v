/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

module recip_nr( //Reciprocal approximation using Newton-Raphson method
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,      // pulse high 1 cycle to begin
    input  wire [9:0] x_i,        // unsigned 10-bit input (sum up to 1020)
    output reg  [15:0] recip_o,   // unsigned Q8.8-like scale: floor((255<<8)/sum)
    output reg        valid       // high for 1 cycle when result ready
);

    function automatic [15:0] recip_q08;
        input [9:0] v;
        reg [23:0] q;
        begin
            if (v == 10'd0) begin
                recip_q08 = 16'd65535;
            end else begin
                q = 24'd65280 / v; // 255 * 256 / sum
                recip_q08 = (q > 24'd65535) ? 16'd65535 : q[15:0];
            end
        end
    endfunction

    reg [9:0] x_reg;
    reg [15:0] recip_reg;
    reg [1:0] state;
    reg       busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 2'd0;
            busy      <= 1'b0;
            valid     <= 1'b0;
            recip_o   <= 16'd0;
            x_reg     <= 10'd0;
            recip_reg <= 16'd0;
        end else begin
            valid <= 1'b0;

            if (start && !busy) begin
                x_reg <= x_i;
                state <= 2'd0;
                busy  <= 1'b1;
            end else if (busy) begin
                case (state)
                    2'd0: begin
                        recip_reg <= recip_q08(x_reg);
                        state <= 2'd1;
                    end
                    2'd1: begin
                        state <= 2'd3;
                    end
                    2'd2: begin
                        state <= 2'd3;
                    end
                    2'd3: begin
                        recip_o <= recip_reg;
                        valid   <= 1'b1;
                        busy    <= 1'b0;
                        state   <= 2'd0;
                    end
                endcase
            end
        end
    end

endmodule
