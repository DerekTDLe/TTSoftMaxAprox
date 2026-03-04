import cocotb
from cocotb.triggers import Timer


def q08_scale_expected(p: int, recip_q08: int) -> int:
    # Softmax-intent scaling: p * (1/sum in Q0.8), then convert back to 8-bit
    return (p * recip_q08) >> 8


@cocotb.test()
async def test_scale4_clip_q08_behavior(dut):
    vectors = [
        ((64, 64, 64, 64), 16 * 256),
        ((255, 64, 32, 16), 1 * 256),
        ((200, 50, 5, 1), 2 * 256),
        ((0, 0, 0, 0), 255 * 256),
    ]

    for idx, (p, recip) in enumerate(vectors, start=1):
        p0, p1, p2, p3 = p
        dut.p0_i.value = p0
        dut.p1_i.value = p1
        dut.p2_i.value = p2
        dut.p3_i.value = p3
        dut.recip_i.value = recip

        await Timer(1, unit="ns")

        got = (
            int(dut.y0_o.value),
            int(dut.y1_o.value),
            int(dut.y2_o.value),
            int(dut.y3_o.value),
        )
        exp = (
            q08_scale_expected(p0, recip),
            q08_scale_expected(p1, recip),
            q08_scale_expected(p2, recip),
            q08_scale_expected(p3, recip),
        )

        assert got == exp, f"Case {idx}: expected {exp}, got {got}"
