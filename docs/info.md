## How it works

This project is a **4-input approximate softmax-like accelerator** implemented in Verilog for the Tiny Tapeout Sky130 template.

It accepts **four signed 8-bit inputs serially** and returns **four serialized 8-bit outputs**. Internally it follows the usual “softmax structure” (max-subtract → exp → sum → normalize), but several stages are intentionally simplified, so the numeric result is **not a mathematically accurate softmax**.

Top module: `tt_um_nonlut_softmax` (see `src/project.v`).

---

### Transaction / interface behavior

A transaction is controlled entirely through `ui_in` (inputs) and `uio_out` (status):

- **Start**: assert `ui_in[7]=1` for one cycle while the design is idle.
- **Load inputs**: on the next 4 cycles, drive one signed 8-bit value per cycle on `ui_in[7:0]`.
- **Outputs**: later, 4 output bytes are streamed one per cycle on `uo_out[7:0]`.

Status bits during output streaming:
- `uio_out[1]` = **serializer valid** (a new output byte is present on `uo_out`)
- `uio_out[0]` = **done** (transaction complete)

Outputs are serialized by `serializer4` (`src/serializer4.v`), which stores 4 bytes and then emits them over 4 cycles with a `valid_o` pulse each cycle.

---

## Design dataflow (as implemented)

### 1) Max + normalization (`max4_signed8`, `norm_sub4`)
- `max4_signed8` finds the maximum of the four signed inputs.
- `norm_sub4` subtracts that maximum from each lane: `n_i = x_i - max(x)`.

This is the standard “numerical stability” trick used in real softmax implementations.

Relevant files:
- `src/max4_signed8.v`
- `src/norm_sub4.v`

### 2) Exponential approximation (`exp_pwl_lane`)
Each normalized lane is passed through `exp_pwl_lane`, which is a **4-segment, shift/add piecewise-linear approximation**:

- Inputs <= -8 clamp to 0
- Inputs > 0 clamp to 255
- Otherwise use linear segments implemented via shifts:
  - [-8, -6): `(x<<1) + 16`
  - [-6, -3): `(x<<2) + 32`
  - [-3, 0]:  `(x<<3) + 64`

This stage does **not** use an exp LUT; it is explicitly implemented with shifts/adds and saturation.

Relevant file:
- `src/exp_pwl_lane.v`

### 3) Sum (`sum4_tree`)
The four 8-bit exp outputs are summed into a 10-bit value (`0..1020`) by `sum4_tree`.

Relevant file:
- `src/sum4_tree.v`

### 4) Reciprocal estimate (`recip_nr`)
`recip_nr` is named like a Newton-Raphson reciprocal, but in the current RTL it is a **minimal 4-entry reciprocal LUT** implemented as a Verilog function:

- if `sum <= 10`   → `recip = 255<<8`
- else if `<= 50`  → `recip = 127<<8`
- else if `<= 200` → `recip = 63<<8`
- else             → `recip = 31<<8`

It has a small FSM and produces a **single-cycle `valid` pulse** when the result is ready.

So: this design **does use a LUT** (for reciprocal approximation).

Relevant file:
- `src/recip_nr.v`

### 5) Scaling (`scale4_clip`)
`scale4_clip` is currently labeled “shift-only scaling” and (as written now) it does **not actually use `recip_i`**.

Instead, each lane output is simply:

- `y = saturate_to_u8(p << 1)`

So the “normalization” is extremely approximate: it depends only on shifting, not on the computed reciprocal.

Relevant file:
- `src/scale4_clip.v`

### 6) Output serialization (`serializer4`)
The 4 final bytes are serialized out over 4 cycles with a `valid` pulse each cycle.

Relevant file:
- `src/serializer4.v`

---

## How to test

The project uses a **cocotb-based, self-checking test flow** (Icarus by default) defined under `test/`.

### Run the default end-to-end test (recommended)

From the `test/` directory:

```sh
make -B
```

This runs `test/test.py`, which uses a comprehensive 27-vector test suite to validate protocol behavior, numerical correctness against a floating-point reference, and output range safety. Artifacts include `results.xml` (test summary) and `tb.fst` (waveform dump).

### Module-level unit tests

For debugging, you can test individual blocks:

```sh
make -B test-max4
make -B test-norm-sub4
make -B test-recip-nr
make -B test-exp-pwl-lane
make -B test-exp-pwl4
make -B test-sum4-tree
make -B test-scale4-clip
```

---

## AI Usage
Using Perplexity I generated some ideas for the tape-out and narrowed in on the SoftMax, and helped me plan out what modules I needed to make. After making the original modules, Copilot helped me generate tests for the individual modules, as well as helping test the top module once all submodules were tested. 

After compiling, I found the gate count to be far too high, at about 9000 gates. I asked copilot to help me decrease the bitwidths of modules,replace multipliers for shift approximation, switch from the original Newton-Raphson calculation for a LUT in the recprical calculator, and decreasing the exponential linear approximation fidelity from 6 segments to 4 to decrease the gate count to ~1.3k. Afterwards, AI was used to edit test parameters to fit the new scope and modify config files. 

Finally, AI was used to confirm attributes of the project for the MD. 

## External hardware

No external hardware is required.