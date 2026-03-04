## How it works

This project implements a **4‑input, LUT‑less, approximate softmax** accelerator in Verilog (Tiny Tapeout / Sky130).

### What it computes

Given four signed 8‑bit inputs `x0..x3` (loaded serially), the design produces four 8‑bit outputs `y0..y3` that approximate:

`softmax(xi) = exp(xi) / (exp(x0)+exp(x1)+exp(x2)+exp(x3))`

Because this is an approximation intended for small area, the exponential and reciprocal are computed with lightweight fixed‑point approximations rather than full-precision math.

### Dataflow / blocks

At a high level the computation is:

1. **Input capture (serial)**: the top module accepts 4 bytes over `ui_in` on consecutive clock cycles after a start pulse.
2. **Max subtraction for stability** (`max4_signed8`, `norm_sub4`): compute `m = max(x0..x3)` and form `xi' = xi - m`.
   - This keeps the exponent inputs near 0, avoiding overflow and improving numeric stability.
3. **Exponential approximation** (`exp_pwl_lane` ×4): apply a piecewise‑linear approximation of `exp(x)` to each normalized lane.
4. **Sum of exponentials** (`sum4_tree`): compute `s = e0 + e1 + e2 + e3`.
5. **Reciprocal approximation** (`recip_nr`): compute an approximate reciprocal `r ≈ 1/s`.
6. **Scale and saturate** (`scale4_clip`): compute `yi ≈ ei * r` in fixed‑point and clip/saturate to an 8‑bit output format.
7. **Output serialize** (`serializer4`): emit one output byte per cycle.

Top module: `tt_um_nonlut_softmax`.

### Interface / transaction behavior

- **Start**: while IDLE, assert `ui_in[7]=1` for one cycle to start a transaction.
- **Load inputs**: on the next 4 cycles, present signed input bytes on `ui_in[7:0]` (one lane per cycle).
- **Outputs**: the design later produces 4 serialized output bytes on `uo_out[7:0]`.
  - `uio_out[1]` = **valid** while each output byte is being streamed.
  - `uio_out[0]` = **done** when the transaction completes.

## How to test

The repository provides **self‑checking cocotb tests** that exercise both the full top‑level dataflow and selected sub‑modules.

### 1) Default integration test (recommended)

Run from the `test/` directory:

```sh
make -B
```

This compiles the full top-level (`tt_um_nonlut_softmax`) and runs `test/test.py`. The testbench:

- applies reset and clocks,
- starts a transaction (`ui_in[7]=1`),
- serially drives 4 input bytes,
- collects the 4 serialized outputs while `valid` is asserted,
- checks the handshake behavior (exactly 4 output bytes, `valid`/`done` behavior),
- checks basic **range/saturation** properties (8‑bit outputs),
- compares against a **floating‑point softmax reference** with a bounded error tolerance.

**Why this is sufficient:** this integration test covers the complete transaction protocol (start/load/serialize), and it verifies end‑to‑end numeric behavior against a software reference across multiple input vectors. That combination gives confidence that (1) the module can be used correctly from the Tiny Tapeout wrapper interface and (2) the composed pipeline of max‑sub, exp approximation, sum, reciprocal, and scaling produces outputs consistent with the intended softmax behavior.

Artifacts:

- `results.xml` (pass/fail summary)
- `tb.fst` waveform (viewable in GTKWave)

### 2) Module‑level tests (debug / unit testing)

You can also run smaller tests that target individual blocks (helpful when debugging):

```sh
make -B test-max4
make -B test-norm-sub4
make -B test-exp-pwl-lane
make -B test-exp-pwl4
make -B test-sum4-tree
make -B test-recip-nr
make -B test-scale4-clip
```

These unit tests increase confidence by isolating arithmetic and corner cases within each stage, making failures easier to localize than with only an end‑to‑end test.

## External hardware

No external hardware is required.