/*
 * Copyright (c) 2024 DerekTDLe
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_nonlut_softmax (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  localparam S0_IDLE        = 4'd0;
  localparam S1_LOAD        = 4'd1;
  localparam S2_NORMALIZE   = 4'd2;
  localparam S3_EXP         = 4'd3;
  localparam S4_SUM         = 4'd4;
  localparam S5_RECIP_START = 4'd5;
  localparam S6_RECIP_WAIT  = 4'd6;
  localparam S7_SCALE       = 4'd7;
  localparam S8_OUT_START   = 4'd8;
  localparam S9_OUT_WAIT    = 4'd9;
  localparam S10_DONE       = 4'd10;

  reg [3:0] state;
  reg [1:0] load_idx;

  reg [7:0] x0_reg;
  reg [7:0] x1_reg;
  reg [7:0] x2_reg;
  reg [7:0] x3_reg;

  reg [7:0] p0_reg;
  reg [7:0] p1_reg;
  reg [7:0] p2_reg;
  reg [7:0] p3_reg;

  reg [9:0] sum_reg;
  reg [15:0] recip_reg;

  reg [7:0] y0_reg;
  reg [7:0] y1_reg;
  reg [7:0] y2_reg;
  reg [7:0] y3_reg;

  reg recip_start;
  reg ser_start;
  reg ser_seen_busy;

  reg [7:0] out_reg;
  reg done_reg;

  wire [7:0] max_val_w;
  wire [7:0] n0_w;
  wire [7:0] n1_w;
  wire [7:0] n2_w;
  wire [7:0] n3_w;

  wire [7:0] p0_w;
  wire [7:0] p1_w;
  wire [7:0] p2_w;
  wire [7:0] p3_w;

  wire [9:0] sum_w;

  wire [15:0] recip_w;
  wire recip_valid_w;

  wire [7:0] y0_w;
  wire [7:0] y1_w;
  wire [7:0] y2_w;
  wire [7:0] y3_w;

  wire [7:0] ser_data_w;
  wire ser_valid_w;
  wire ser_busy_w;

  max4_signed8 u_max4 (
      .a_i(x0_reg),
      .b_i(x1_reg),
      .c_i(x2_reg),
      .d_i(x3_reg),
      .max_val_o(max_val_w)
  );

  norm_sub4 u_norm_sub4 (
      .a_i(x0_reg),
      .b_i(x1_reg),
      .c_i(x2_reg),
      .d_i(x3_reg),
      .max_i(max_val_w),
      .a_o(n0_w),
      .b_o(n1_w),
      .c_o(n2_w),
      .d_o(n3_w)
  );

  exp_pwl_lane u_exp0 (
      .x_i(n0_w),
      .exp_o(p0_w)
  );

  exp_pwl_lane u_exp1 (
      .x_i(n1_w),
      .exp_o(p1_w)
  );

  exp_pwl_lane u_exp2 (
      .x_i(n2_w),
      .exp_o(p2_w)
  );

  exp_pwl_lane u_exp3 (
      .x_i(n3_w),
      .exp_o(p3_w)
  );

  sum4_tree u_sum4 (
      .a_i(p0_reg),
      .b_i(p1_reg),
      .c_i(p2_reg),
      .d_i(p3_reg),
      .sum_o(sum_w)
  );

  recip_nr u_recip (
      .clk(clk),
      .rst_n(rst_n),
      .start(recip_start),
      .x_i(sum_reg),
      .recip_o(recip_w),
      .valid(recip_valid_w)
  );

  scale4_clip u_scale (
      .p0_i(p0_reg),
      .p1_i(p1_reg),
      .p2_i(p2_reg),
      .p3_i(p3_reg),
      .recip_i(recip_reg),
      .y0_o(y0_w),
      .y1_o(y1_w),
      .y2_o(y2_w),
      .y3_o(y3_w)
  );

  serializer4 u_ser (
      .clk(clk),
      .rst_n(rst_n),
      .start(ser_start),
      .d0_i(y0_reg),
      .d1_i(y1_reg),
      .d2_i(y2_reg),
      .d3_i(y3_reg),
      .data_o(ser_data_w),
      .valid_o(ser_valid_w),
      .busy_o(ser_busy_w)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S0_IDLE;
      load_idx <= 2'd0;
      x0_reg <= 8'd0;
      x1_reg <= 8'd0;
      x2_reg <= 8'd0;
      x3_reg <= 8'd0;
      p0_reg <= 8'd0;
      p1_reg <= 8'd0;
      p2_reg <= 8'd0;
      p3_reg <= 8'd0;
      sum_reg <= 10'd1;
      recip_reg <= 16'd0;
      y0_reg <= 8'd0;
      y1_reg <= 8'd0;
      y2_reg <= 8'd0;
      y3_reg <= 8'd0;
      recip_start <= 1'b0;
      ser_start <= 1'b0;
      ser_seen_busy <= 1'b0;
      out_reg <= 8'd0;
      done_reg <= 1'b0;
    end else begin
      recip_start <= 1'b0;
      ser_start <= 1'b0;

      case (state)
        S0_IDLE: begin
          done_reg <= 1'b0;
          out_reg <= 8'd0;
          load_idx <= 2'd0;
          if (ui_in[7]) begin
            state <= S1_LOAD;
          end
        end

        S1_LOAD: begin
          case (load_idx)
            2'd0: x0_reg <= ui_in;
            2'd1: x1_reg <= ui_in;
            2'd2: x2_reg <= ui_in;
            default: x3_reg <= ui_in;
          endcase

          if (load_idx == 2'd3) begin
            state <= S2_NORMALIZE;
          end else begin
            load_idx <= load_idx + 2'd1;
          end
        end

        S2_NORMALIZE: begin
          state <= S3_EXP;
        end

        S3_EXP: begin
          p0_reg <= p0_w;
          p1_reg <= p1_w;
          p2_reg <= p2_w;
          p3_reg <= p3_w;
          state <= S4_SUM;
        end

        S4_SUM: begin
          sum_reg <= (sum_w == 10'd0) ? 10'd1 : sum_w;
          state <= S5_RECIP_START;
        end

        S5_RECIP_START: begin
          recip_start <= 1'b1;
          state <= S6_RECIP_WAIT;
        end

        S6_RECIP_WAIT: begin
          if (recip_valid_w) begin
            recip_reg <= recip_w;
            state <= S7_SCALE;
          end
        end

        S7_SCALE: begin
          y0_reg <= y0_w;
          y1_reg <= y1_w;
          y2_reg <= y2_w;
          y3_reg <= y3_w;
          state <= S8_OUT_START;
        end

        S8_OUT_START: begin
          ser_start <= 1'b1;
          ser_seen_busy <= 1'b0;
          state <= S9_OUT_WAIT;
        end

        S9_OUT_WAIT: begin
          if (ser_busy_w) begin
            ser_seen_busy <= 1'b1;
          end
          if (ser_seen_busy && !ser_busy_w && !ser_valid_w) begin
            state <= S10_DONE;
          end
        end

        default: begin
          done_reg <= 1'b1;
          out_reg <= 8'h80;
          state <= S10_DONE;
        end
      endcase
    end
  end

  assign uo_out = ser_valid_w ? ser_data_w : out_reg;
  assign uio_out = {6'b000000, ser_valid_w, done_reg};
  assign uio_oe  = 8'b00000011;

  wire _unused = &{ena, uio_in, 1'b0};

endmodule
