# softmaxAprox(Tiny Tapeout)

4-input LUT-less softmax accelerator implemented in Verilog for the Tiny Tapeout Sky130 template.

## Design summary

This design accepts 4 signed 8-bit inputs over `ui_in` (serially), computes an approximate softmax, and returns 4 serialized 8-bit outputs on `uo_out`.

Pipeline stages:

1. `max4_signed8`: signed max of the 4 inputs.
2. `norm_sub4` (`norm_sub4.v`): subtract max from each lane.
3. `exp_pwl_lane` x4: piecewise-linear approximation of `exp(x)` for normalized lanes.
4. `sum4_tree`: sum the 4 exponential lanes.
5. `recip_nr`: reciprocal approximation for normalization scale.
6. `scale4_clip`: lane scaling in Q0.8 domain with 8-bit saturation.
7. `serializer4`: output bytes one-per-cycle.

Top module: `tt_um_nonlut_softmax`

## Interface behavior

- `ui_in[7] = 1` in IDLE starts a transaction.
- Next 4 clock cycles: present 4 signed input bytes on `ui_in`.
- `uio_out[1]` indicates serializer valid while each output byte is present on `uo_out`.
- `uio_out[0]` indicates done for the transaction.

## Files

- RTL: [src](src)
- Tiny Tapeout project metadata: [info.yaml](info.yaml)
- Datasheet markdown source: [docs/info.md](docs/info.md)
- Testbench and cocotb tests: [test](test)

## Testing

From `test/`:

```sh
make -B
```

This runs the default self-checking cocotb integration test (`test/test.py`) and produces `results.xml` + waveform output.

Selected module tests:

```sh
make -B test-max4
make -B test-norm-sub4
make -B test-exp-pwl-lane
make -B test-sum4-tree
make -B test-recip-nr
make -B test-scale4-clip
```

## Tiny Tapeout

- Template reference: https://github.com/TinyTapeout/ttsky-verilog-template
- Program info: https://tinytapeout.com/

For assignment submission, provide the public repository URL and the full commit SHA you want graded.
