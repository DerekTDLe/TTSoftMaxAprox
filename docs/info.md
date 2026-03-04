<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 4-input softmax accelerator without lookup tables.

It receives four signed 8-bit values serially, finds the lane-wise maximum, normalizes each input by subtracting that max, and applies a piecewise-linear exponential approximation (`exp_pwl_lane`) per lane.

The four exponentials are summed (`sum4_tree`), and a reciprocal approximation (`recip_nr`) computes an approximate `1/sum`. Each lane is then scaled by this reciprocal (`scale4_clip`) and clipped to 8-bit output range.

The final four outputs are serialized by `serializer4` and emitted one byte per cycle. `uio[1]` indicates serializer-valid while streaming, and `uio[0]` indicates done.

## How to test

Run the default integration test from the `test` directory:

`make -B`

The cocotb test (`test/test.py`) applies reset, sends a start pulse (`ui_in[7]=1`), serially loads 4 input bytes, waits for serialized outputs, and checks:

- exactly 4 output bytes are observed,
- done flag is asserted,
- outputs are in 8-bit range.

You can also run module-level tests for sub-blocks using make targets in `test/Makefile`, e.g. `make test-exp-pwl-lane`, `make test-exp-pwl4`, `make test-max4`, `make test-norm-sub4`, and `make test-recip-nr`.

## External hardware

No external hardware is required.
