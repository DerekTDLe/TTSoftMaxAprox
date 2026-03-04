import cocotb
from cocotb.triggers import Timer


def to_u8(value: int) -> int:
    return value & 0xFF


def model_exp_pwl_lane_signed(x: int) -> int:
    if x <= -8:
        y = 0
    elif x >= 0:
        y = 255
    elif x < -6:
        y = (x >> 1) + 4
    elif x < -4:
        y = (x << 1) + 13
    elif x < -3:
        y = (x << 3) + 37
    elif x < -2:
        y = (x * 22) + 79
    elif x < -1:
        y = (x * 59) + 153
    else:
        y = (x * 161) + 255

    if y < 0:
        y = 0
    elif y > 255:
        y = 255

    return y & 0xFF


@cocotb.test()
async def test_exp_pwl4_parallel_lanes(dut):
    vectors = [
        (-8, -6, -4, -2),
        (-7, -5, -3, -1),
        (-8, -1, 0, -4),
        (0, 0, 0, 0),
    ]

    for idx, (x0, x1, x2, x3) in enumerate(vectors, start=1):
        dut.x0_i.value = to_u8(x0)
        dut.x1_i.value = to_u8(x1)
        dut.x2_i.value = to_u8(x2)
        dut.x3_i.value = to_u8(x3)

        await Timer(1, unit="ns")

        got = (
            int(dut.p0.value),
            int(dut.p1.value),
            int(dut.p2.value),
            int(dut.p3.value),
        )
        expected = (
            model_exp_pwl_lane_signed(x0),
            model_exp_pwl_lane_signed(x1),
            model_exp_pwl_lane_signed(x2),
            model_exp_pwl_lane_signed(x3),
        )

        assert got == expected, f"Case {idx}: expected {expected}, got {got}"
