import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles, Timer


async def capture_stream(dut, payload):
    d0, d1, d2, d3 = payload
    dut.d0_i.value = d0
    dut.d1_i.value = d1
    dut.d2_i.value = d2
    dut.d3_i.value = d3

    await RisingEdge(dut.clk)
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    out = []
    for _ in range(10):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ps")
        if int(dut.valid_o.value) == 1:
            out.append(int(dut.data_o.value))
            if len(out) == 4:
                break

    assert out == [d0, d1, d2, d3], f"Expected stream {[d0, d1, d2, d3]}, got {out}"

    await RisingEdge(dut.clk)
    await Timer(1, unit="ps")
    assert int(dut.valid_o.value) == 0, "valid_o should deassert after 4 bytes"
    assert int(dut.busy_o.value) == 0, "busy_o should deassert after 4 bytes"


@cocotb.test()
async def test_serializer4_stream_and_busy(dut):
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())  # 10 MHz

    dut.rst_n.value = 0
    dut.start.value = 0
    dut.d0_i.value = 0
    dut.d1_i.value = 0
    dut.d2_i.value = 0
    dut.d3_i.value = 0
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    await capture_stream(dut, (11, 22, 33, 44))

    # Start a second stream and try retriggering while busy
    dut.d0_i.value = 55
    dut.d1_i.value = 66
    dut.d2_i.value = 77
    dut.d3_i.value = 88

    await RisingEdge(dut.clk)
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    await RisingEdge(dut.clk)
    await Timer(1, unit="ps")
    assert int(dut.valid_o.value) == 1
    assert int(dut.data_o.value) == 55

    # Attempt retrigger during busy with different payload; should be ignored
    dut.d0_i.value = 1
    dut.d1_i.value = 2
    dut.d2_i.value = 3
    dut.d3_i.value = 4
    dut.start.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ps")
    dut.start.value = 0

    out = [55]
    if int(dut.valid_o.value) == 1:
        out.append(int(dut.data_o.value))

    for _ in range(10):
        await RisingEdge(dut.clk)
        await Timer(1, unit="ps")
        if int(dut.valid_o.value) == 1:
            out.append(int(dut.data_o.value))
            if len(out) == 4:
                break

    assert out == [55, 66, 77, 88], f"start while busy should be ignored; got {out}"

    await RisingEdge(dut.clk)
    await Timer(1, unit="ps")
    assert int(dut.busy_o.value) == 0
    assert int(dut.valid_o.value) == 0
