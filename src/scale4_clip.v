/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module scale4_clip( //Shift-based scaling using reciprocal
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

    // Use recip_i to determine shift amount for scaling
    // recip_i ranges: ~65280 (255<<8), ~32640 (127<<8), ~16320 (63<<8), ~8160 (31<<8)
    // Decode upper bits to determine appropriate right-shift
    function automatic [7:0] scale_by_recip;
        input [7:0] p;
        /* verilator lint_off UNUSEDSIGNAL */
        input [15:0] recip; //need to disable lint here becuase I'm using only upper bits
        /* verilator lint_on UNUSEDSIGNAL */
        begin
            // Check upper bits of recip to determine scaling
            if (recip[15:14] == 2'b11)           // recip >= 49152 (~255/256)
                scale_by_recip = p;               // No shift: sum was small
            else if (recip[15:13] == 3'b011)     // recip >= 24576 (~127/256)
                scale_by_recip = p >> 1;          // Shift right 1: sum ~2x
            else if (recip[15:12] == 4'b0011)    // recip >= 12288 (~63/256)
                scale_by_recip = p >> 2;          // Shift right 2: sum ~4x
            else                                  // recip < 12288 (~31/256)
                scale_by_recip = p >> 3;          // Shift right 3: sum ~8x
        end
    endfunction

    assign y0_o = scale_by_recip(p0_i, recip_i);
    assign y1_o = scale_by_recip(p1_i, recip_i);
    assign y2_o = scale_by_recip(p2_i, recip_i);
    assign y3_o = scale_by_recip(p3_i, recip_i);

endmodule

`default_nettype wire
