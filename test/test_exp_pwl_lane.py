import cocotb
from cocotb.triggers import Timer


def to_u8(value: int) -> int:
    return value & 0xFF


def to_s8(value: int) -> int:
    value &= 0xFF
    return value - 256 if value & 0x80 else value


def model_exp_pwl_lane_signed(x: int) -> int:
    # Intended 6-segment model in signed integer domain
    if x < -6:
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

    return y & 0xFF


@cocotb.test()
async def test_exp_pwl_lane_directed(dut):
    # Segment/edge probes
    vectors = [-8, -7, -6, -5, -4, -3, -2, -1, 0]

    for idx, x in enumerate(vectors, start=1):
        dut.x_i.value = to_u8(x)
        await Timer(1, unit="ns")

        got = int(dut.exp_o.value)
        expected = model_exp_pwl_lane_signed(x)

        assert got == expected, (
            f"Case {idx}: x={x}, expected={expected}, got={got}"
        )


@cocotb.test()
async def test_exp_pwl_lane_monotonic_window(dut):
    # In this window, output should not decrease as x increases
    # (coarse monotonic sanity check)
    samples = []
    for x in range(-8, 1):
        dut.x_i.value = to_u8(x)
        await Timer(1, unit="ns")
        samples.append((x, int(dut.exp_o.value)))

    for i in range(1, len(samples)):
        x_prev, y_prev = samples[i - 1]
        x_cur, y_cur = samples[i]
        assert y_cur >= y_prev, (
            f"Monotonic check failed: x={x_prev}->{x_cur}, y={y_prev}->{y_cur}"
        )
