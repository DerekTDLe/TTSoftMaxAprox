# Testbench Guide

This project uses a cocotb-based, self-checking verification flow.

## Default integration test

Run from this directory:

```sh
make -B
```

This compiles the full top-level (`tt_um_nonlut_softmax`) and runs `test.py`, which verifies:

- transaction start/load/serialize flow,
- exactly 4 output bytes per transaction,
- done/valid signaling,
- output range checks,
- approximate softmax correctness versus a floating-point reference.

Artifacts:

- `results.xml` (pass/fail summary used by CI),
- `tb.fst` (waveform).

## Module-level tests

You can test blocks independently:

```sh
make -B test-max4
make -B test-norm-sub4
make -B test-exp-pwl-lane
make -B test-exp-pwl4
make -B test-sum4-tree
make -B test-recip-nr
make -B test-scale4-clip
```

## Waveform viewing

```sh
gtkwave tb.fst tb.gtkw
```
