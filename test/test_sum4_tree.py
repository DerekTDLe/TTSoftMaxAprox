import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_sum4_tree_full_sum_behavior(dut):
    # Expected behavior: preserve full 10-bit sum (0..1020).
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
        assert got == full_sum, (
            f"Case {idx}: expected full sum {full_sum}, got {got}"
        )
