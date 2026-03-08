import cocotb
from cocotb.triggers import Timer


def shift_scale_expected(p: int, recip: int) -> int:
    """Shift-based scaling matching the Verilog implementation"""
    # Decode upper bits of recip to determine shift amount
    if recip >= 49152:  # recip[15:14] == 2'b11
        return p  # No shift
    elif recip >= 24576:  # recip[15:13] == 3'b011
        return p >> 1  # Shift right 1
    elif recip >= 12288:  # recip[15:12] == 4'b0011
        return p >> 2  # Shift right 2
    else:
        return p >> 3  # Shift right 3


@cocotb.test()
async def test_scale4_clip_shift_behavior(dut):
    """Test shift-based scaling that uses recip_i to determine shift amount"""
    vectors = [
        # (inputs, recip_value)
        # High recip (~255/256 = 65280): no shift
        ((128, 64, 32, 16), 65280),
        # Medium recip (~127/256 = 32640): shift right 1
        ((128, 64, 32, 16), 32640),
        # Low recip (~63/256 = 16320): shift right 2
        ((128, 64, 32, 16), 16320),
        # Very low recip (~31/256 = 8160): shift right 3
        ((128, 64, 32, 16), 8160),
        # Edge cases
        ((255, 200, 100, 50), 65280),  # No shift, high values
        ((255, 200, 100, 50), 8160),   # Shift right 3, high values
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
            shift_scale_expected(p0, recip),
            shift_scale_expected(p1, recip),
            shift_scale_expected(p2, recip),
            shift_scale_expected(p3, recip),
        )

        assert got == exp, f"Case {idx}: expected {exp}, got {got}"
