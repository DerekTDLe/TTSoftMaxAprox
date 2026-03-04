import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles


def golden_recip_q08(x: int) -> int:
    if x == 0:
        return 255
    return min(255, int(256 // x))


async def run_case(dut, x: int):
    dut.x_i.value = x
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    latency = None
    got = None
    for cycle in range(1, 9):
        await RisingEdge(dut.clk)
        if int(dut.valid.value) == 1:
            latency = cycle
            got = int(dut.recip_o.value)
            break

    assert latency is not None, f"valid never asserted within 8 cycles for x={x}"
    assert 4 <= latency <= 6, f"unexpected valid latency={latency} for x={x}"

    await RisingEdge(dut.clk)
    assert int(dut.valid.value) == 0, f"valid did not deassert after result pulse for x={x}"
    return latency, got


@cocotb.test()
async def test_recip_nr_directed(dut):
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())  # 10 MHz

    dut.rst_n.value = 0
    dut.start.value = 0
    dut.x_i.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    tests = [64, 16, 200, 1, 0]

    for idx, x in enumerate(tests, start=1):
        expected = golden_recip_q08(x)
        latency, got = await run_case(dut, x)
        assert got == expected, f"Test {idx}: x={x} expected {expected} got {got}"
        dut._log.info(f"Test {idx}: x={x}, latency={latency}, expected={expected}, got={got} PASS")
