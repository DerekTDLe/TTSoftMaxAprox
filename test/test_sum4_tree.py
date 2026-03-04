import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_sum4_tree_saturating_behavior(dut):
    # Expected behavior for 8-bit output path: saturate at 255 (no wrap).
    vectors = [
        (10, 20, 30, 40),
        (64, 64, 64, 64),
        (80, 80, 80, 80),
        (255, 1, 1, 1),
    ]

    for idx, (a, b, c, d) in enumerate(vectors, start=1):
        dut.a_i.value = a
        dut.b_i.value = b
        dut.c_i.value = c
        dut.d_i.value = d
        await Timer(1, unit="ns")

        got = int(dut.sum_o.value)
        full_sum = a + b + c + d
        expected = 255 if full_sum > 255 else full_sum

        assert got == expected, (
            f"Case {idx}: expected saturated sum {expected} (full={full_sum}), got {got}"
        )
