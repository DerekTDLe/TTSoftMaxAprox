## How it works

This project implements a 4-input LUT-less softmax accelerator.

It receives four signed 8-bit values serially, finds the maximum lane value, normalizes each lane by subtracting that max, and applies a piecewise-linear exponential approximation (`exp_pwl_lane`) per lane.

The four exponentials are summed (`sum4_tree`), and a reciprocal block (`recip_nr`) computes an approximate `1/sum` scaling factor. Each lane is then scaled by this factor (`scale4_clip`) and clipped to 8-bit range.

The final four outputs are serialized by `serializer4` and emitted one byte per cycle. `uio[1]` indicates serializer-valid while streaming, and `uio[0]` indicates done.

## How to test

Run the default integration test from the `test` directory:

`make -B`

The cocotb integration test (`test/test.py`) applies reset, sends a start pulse (`ui_in[7]=1`), serially loads 4 input bytes, waits for serialized outputs, and checks:

- exactly 4 output bytes are observed,
- done flag is asserted,
- outputs are in 8-bit range,
- output argmax behavior for non-degenerate vectors,
- closeness to floating-point softmax reference under bounded L1 error.

You can also run module-level tests for sub-blocks using make targets in `test/Makefile`, e.g. `make test-exp-pwl-lane`, `make test-exp-pwl4`, `make test-max4`, `make test-norm-sub4`, and `make test-recip-nr`.

## External hardware

No external hardware is required.
