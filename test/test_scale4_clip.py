import cocotb
from cocotb.triggers import Timer


def clip_mul_u8(a: int, b: int) -> int:
    prod = a * b
    return 255 if prod > 255 else prod


@cocotb.test()
async def test_scale4_clip_basic(dut):
    vectors = [
        ((0, 0, 0, 0), 0),
        ((1, 2, 3, 4), 10),
        ((10, 20, 30, 40), 2),
        ((64, 64, 64, 64), 4),
        ((200, 50, 1, 255), 2),
        ((255, 255, 255, 255), 255),
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
        expected = (
            clip_mul_u8(p0, recip),
            clip_mul_u8(p1, recip),
            clip_mul_u8(p2, recip),
            clip_mul_u8(p3, recip),
        )

        assert got == expected, f"Case {idx}: expected {expected}, got {got}"
