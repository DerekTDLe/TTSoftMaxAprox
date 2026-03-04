/*
 * Copyright (c) 2024 Q Le
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module exp_pwl4( //Wrapper instantiating 4 parallel exp_pwl_lane
    input  wire [7:0] x0_i, x1_i, x2_i, x3_i, //input signed 8-bit per lane
    output wire [7:0] p0, p1, p2, p3 //output unsigned 8-bit
);
   
    exp_pwl_lane lane0 (
        .x_i(x0_i),
        .exp_o(p0)
    );
    exp_pwl_lane lane1 (
        .x_i(x1_i),
        .exp_o(p1)
    );
    exp_pwl_lane lane2 (
        .x_i(x2_i),
        .exp_o(p2)
    );
    exp_pwl_lane lane3 (
        .x_i(x3_i),
        .exp_o(p3)
    );
    
endmodule