import cocotb
from cocotb.triggers import Timer


def to_u8(value: int) -> int:
    return value & 0xFF


def to_s8(value: int) -> int:
    value &= 0xFF
    return value - 256 if value & 0x80 else value


@cocotb.test()
async def test_max4_signed8_basic(dut):
    vectors = [
        (-5, -2, -9, -2),
        (0, 0, 0, 0),
        (127, -128, 3, 4),
        (-128, -127, -126, -125),
        (10, 20, 30, 40),
        (-1, -64, -2, -3),
    ]

    for idx, (a, b, c, d) in enumerate(vectors, start=1):
        dut.a_i.value = to_u8(a)
        dut.b_i.value = to_u8(b)
        dut.c_i.value = to_u8(c)
        dut.d_i.value = to_u8(d)

        await Timer(1, unit="ns")

        expected = max(a, b, c, d)
        got = to_s8(int(dut.max_val_o.value))

        assert got == expected, f"Case {idx}: expected {expected}, got {got}"
