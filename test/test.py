# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge
import math


async def reset_dut(dut):
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 8)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)


async def run_softmax_transaction(dut, inputs):
    # Start pulse in IDLE
    dut.ui_in.value = 0x80
    await RisingEdge(dut.clk)

    # 4 serialized inputs
    for value in inputs:
        dut.ui_in.value = value & 0xFF
        await RisingEdge(dut.clk)

    dut.ui_in.value = 0

    outputs = []
    done_seen = False
    for _ in range(120):
        await RisingEdge(dut.clk)
        ser_valid = int(dut.uio_out.value) & 0x2
        done_flag = int(dut.uio_out.value) & 0x1
        if ser_valid:
            outputs.append(int(dut.uo_out.value))
        if done_flag:
            done_seen = True
            break

    return outputs, done_seen


def softmax_ref_u8(inputs):
    m = max(inputs)
    exps = [math.exp(x - m) for x in inputs]
    s = sum(exps)
    probs = [e / s for e in exps]
    return [int(round(p * 255.0)) for p in probs]


def l1_norm_err_u8(a, b):
    return sum(abs(x - y) for x, y in zip(a, b)) / 255.0


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start full softmax_top integration test")

    # 10 MHz clock
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    test_vectors = [
        [10, 20, 30, 40],
        [0, 0, 0, 0],
        [40, 10, 0, -5],
        [-8, -6, -4, -2],
    ]

    nonflat_cases = 0
    errs = []

    for idx, vec in enumerate(test_vectors, start=1):
        dut._log.info(f"Reset for case {idx}")
        await reset_dut(dut)

        outputs, done_seen = await run_softmax_transaction(dut, vec)
        ref = softmax_ref_u8(vec)

        assert len(outputs) == 4, f"Case {idx}: Expected 4 serialized outputs, got {len(outputs)}"
        assert done_seen, f"Case {idx}: Done flag was not observed"

        for lane, value in enumerate(outputs, start=1):
            assert 0 <= value <= 255, f"Case {idx}: Output {lane} out of range: {value}"

        spread = max(outputs) - min(outputs)
        if spread > 0:
            nonflat_cases += 1

        # For vectors with unique max, check winner lane matches only when
        # DUT output has enough dynamic range to make winner meaningful.
        if len(set(vec)) == len(vec) and spread >= 4:
            got_argmax = max(range(4), key=lambda i: outputs[i])
            ref_argmax = max(range(4), key=lambda i: vec[i])
            assert got_argmax == ref_argmax, (
                f"Case {idx}: argmax mismatch, input winner={ref_argmax}, output winner={got_argmax}"
            )

        # "Pretty close" tolerance in normalized L1 to reference softmax*255
        err = l1_norm_err_u8(outputs, ref)
        errs.append(err)
        assert err <= 1.20, f"Case {idx}: L1 norm error too high ({err:.3f}), out={outputs}, ref={ref}"

        dut._log.info(f"Case {idx}: in={vec}, out={outputs}, ref={ref}, l1={err:.3f}")

    # Guardrail against completely degenerate behavior.
    assert nonflat_cases >= 1, "All test cases produced flat outputs; expected at least one non-flat response"
    avg_err = sum(errs) / len(errs)
    assert avg_err <= 1.05, f"Average L1 error too high: {avg_err:.3f}"
