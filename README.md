# LEGv8 5-Stage Pipelined CPU

A 64-bit, 5-stage pipelined processor for a subset of the ARM LEGv8 instruction set, written in SystemVerilog. The datapath is built almost entirely from structural, gate-level modules (`and`/`or`/`xor`/`not` primitives with 50 ps delays). The register file, ALU, adders, multiplexers, decoders, and every pipeline register are all built from those gates, with no behavioral `+` or `?:` shortcuts. Behavioral `always_comb` blocks appear only in the small control units: main control, ALU control, forwarding, and hazard detection.

This README focuses on **how the pipeline works**: how instructions move through the stages, and how data hazards, load-use hazards, and control hazards are handled.

![LEGv8 pipelined datapath](docs/datapath.svg)

---

## Supported Instructions

| Type | Instructions |
|------|--------------|
| Arithmetic | `ADDI`, `ADDS`, `SUBS` (the `S` forms set N/Z/V/C flags) |
| Memory | `LDUR`, `STUR` (64-bit) |
| Branch | `B`, `BL`, `BR`, `CBZ`, `B.LT` |

---

## Pipeline Overview

```
        ┌──────┐   IF/ID   ┌──────┐   ID/EX   ┌──────┐  EX/MEM  ┌──────┐  MEM/WB  ┌──────┐
 PC ──► │  IF  │ ───────► │  ID  │ ───────► │  EX  │ ───────► │ MEM  │ ───────► │  WB  │
        └──────┘          └──────┘          └──────┘          └──────┘          └──────┘
        fetch             decode,           ALU,              data              select ALU /
        PC + 4            reg read,         flags             memory            mem / PC+4,
                          branch resolve                                        reg write
```

| Stage | What happens | Key modules |
|-------|--------------|-------------|
| **IF** | Fetch the instruction at `PC` and compute `PC + 4`. | `instructmem`, `adder_subtractor` |
| **ID** | Decode, generate control, sign-extend the immediate, read registers, and **resolve branches** (target, condition, next-PC select). | `control`, `ALUControl`, `sign_extend`, `regfile` |
| **EX** | Forward operands, select register or immediate, execute in the ALU, and write the flags register if needed. | `ForwardingUnit`, `alu` |
| **MEM** | Read from or write to data memory. | `datamem` |
| **WB** | Choose ALU result, loaded data, or `PC + 4` (for `BL`) and write it back. | `mux2_64` ×2 |

Signal names use a stage suffix so you can always tell where a value lives: `_D` (ID), `_E` (EX), `_M` (MEM), `_W` (WB). For example, `RegWrite_E` is the `RegWrite` control bit of whatever instruction is currently in EX.

### Pipeline registers

Each stage boundary is a set of `Register` instances: a 64-bit register built from `D_FF`s plus a 2:1 mux per bit for the write enable. Every control bit and data value an instruction needs downstream travels with it, including `RegWrite`, `MemRead`, `Mem2Reg`, `BLInstr`, the destination register number, and `PC + 4`. Each stage therefore has everything it needs without looking backwards.

- **IF/ID** uses `PipelineReg`, which adds a `Flush` input (OR'd into reset) and has its write enable driven by the hazard unit, so it can **hold** during a stall.
- **ID/EX, EX/MEM, and MEM/WB** are always enabled. Stalls are handled by inserting a bubble rather than freezing them (see below).

---

## Data Hazards: Forwarding

A typical sequence:

```
ADDS X1, X2, X3     // X1 written in WB, 3 cycles later
SUBS X4, X1, X5     // needs X1 next cycle
```

Without forwarding, the `SUBS` would read a stale `X1`. The design uses three mechanisms to fix this.

### 1. EX-stage forwarding (`ForwardingUnit fu`)

The forwarding unit compares the source registers of the instruction in EX (`Rn_E`, `Rm_E`) against the destination registers of the instructions in MEM and WB. It drives a 4:1 mux in front of each ALU input:

| `forward` | Source | Meaning |
|-----------|--------|---------|
| `00` | `ReadData1_E` / `ReadData2_E` | No hazard; use the value read in ID |
| `10` | `ALUOut_M` | Producer is one instruction ahead (in MEM) |
| `01` | `WriteData` | Producer is two instructions ahead (in WB) |

Two details matter:

- **Priority:** MEM is checked before WB. If both stages write the same register, the newer value (in MEM) wins.
- **X31 is never forwarded.** `XZR` always reads as zero, so a write to it must not be forwarded.

The forwarded B operand also feeds the EX/MEM store-data register. A `STUR` therefore stores the correct value even when it was produced one or two instructions earlier.

### 2. Register file write-through (WB → ID)

When an instruction in WB writes the register that the instruction in ID is reading, `regfile` detects the match in gates (XNOR compare, AND with `RegWrite`, exclude X31). It then passes `WriteData` straight to the read port. This covers the three-instructions-apart case without needing a split-cycle register file.

### 3. ID-stage forwarding for branches

Branches resolve in ID (see Control Hazards), so `CBZ` and `BR` need their register value one stage *earlier* than the ALU does. A second `ForwardingUnit` (`fu_br`) plus an extra EX comparator feed a 4:1 mux in front of the branch logic:

| Source | Producer is in… |
|--------|-----------------|
| `ALUOut` (live ALU output) | EX, the instruction directly before the branch |
| `ALUOut_M` | MEM |
| `WriteData` | WB |
| `ReadData1` | already in the register file |

This lets code such as `SUBS X1, ...` followed immediately by `CBZ X1, label` branch correctly with no stall.

---

## Load-Use Hazards: Stalling (`HazardDetectionUnit`)

Load data is not available until the end of MEM, so it cannot be forwarded to an instruction that needs it in EX on the very next cycle:

```
LDUR X2, [X1, #0]
ADDS X3, X2, X4     // must wait one cycle
```

The hazard unit checks whether the instruction in EX is a load (`MemRead_E`) whose destination matches either source register of the instruction in ID. When it does, the unit inserts one stall cycle:

1. **Freeze the front of the pipe.** `hz_WriteEnable = 0` holds both the PC and the IF/ID register, so the same instruction is fetched and decoded again next cycle.
2. **Insert a bubble.** `id_ex_muxsel = 0` is AND-gated into every control bit entering ID/EX (`RegWrite`, `MemWrite`, `MemRead`, `Mem2Reg`, `BLInstr`, `ALUSrc`, `FlagWrite`). The instruction that enters EX becomes a NOP that writes nothing.

On the next cycle the load is in WB, and the normal WB forwarding path supplies the data.

```
cycle:        1    2    3    4    5    6
LDUR X2      IF   ID   EX   MEM  WB
ADDS X3,X2        IF   ID   ID*  EX   MEM      * stalled; bubble enters EX
next              ...  IF   IF*  ID   EX
```

---

## Control Hazards: Early Branch Resolution + Delay Slot

### Resolving branches in ID

Instead of waiting for the ALU, every branch is fully resolved in ID:

- **Target:** a dedicated adder computes `PC_D + SignExt(imm) << 2`.
- **`CBZ`:** a zero-detect runs on the forwarded `Rt` value.
- **`B.LT`:** taken when `N ≠ V`.
- **`BR`:** the forwarded register value becomes the next PC directly.
- **`B` / `BL`:** always taken. `BL` also writes `PC + 4` into X30. The value travels down the pipe as `PC_4_E → PC_4_M → PC_4_W` and is selected in WB.

Two muxes then choose the next PC: `PC + 4` or the branch target, followed by that result or the register value (for `BR`).

### Flag forwarding for `B.LT`

The flags register is written at the end of EX. A `B.LT` directly after `SUBS` would otherwise read stale flags. Two muxes select the **live** ALU `N` and `V` outputs whenever the instruction in EX is setting flags (`FlagWrite_E`), and the stored flags otherwise:

```
SUBS X0, X1, X2
B.LT loop           // sees the SUBS flags with zero stall cycles
```

### One branch delay slot

Because the branch resolves in ID, the instruction directly after it has already been fetched by the time the new PC is known. This design uses a **branch delay slot**: that instruction always executes, whether or not the branch is taken. No cycles are wasted and no flush is needed, so `IF_Flush` is tied to 0. Programs for this CPU are written with this in mind; either a useful instruction or a NOP is placed after each branch.

---

## Design Decisions and Tradeoffs

### Resolving branches in ID instead of EX or MEM

The textbook LEGv8 pipeline resolves branches in MEM, which costs up to 3 wasted cycles on every taken branch. Moving resolution into ID cuts that to a single slot after the branch, and the delay slot fills that slot with useful work.

The cost:
- **Extra hardware.** ID needs its own target adder, zero detect, and flag logic.
- **A second forwarding network.** The branch operand is needed a full stage earlier than ALU operands, so ID gets its own forwarding paths.
- **A longer critical path** (see below).

I chose this because loops and function calls are branch-heavy. Branch penalties would dominate CPI far more than the occasional load-use stall.

### Delay slot instead of predict-not-taken + flush

The alternative was to keep fetching sequentially and flush IF/ID whenever a branch is taken. That would cost one cycle per taken branch. A delay slot costs nothing in hardware, which is why `IF_Flush` exists but is tied to 0. The tradeoff is that it moves work to software: every branch must be followed by a useful instruction or a NOP. That ISA-visible quirk is why modern ISAs dropped delay slots. For a fixed set of hand-written programs, it is the cheapest option.

### Forwarding the live ALU result straight into ID

When `SUBS X1, …` is followed immediately by `CBZ X1`, the value doesn't exist until the end of EX in that same cycle. There were two choices:

| Option | Cost |
|--------|------|
| Stall the branch one cycle | A lost cycle on a very common loop pattern (decrement, then test) |
| **Forward the combinational ALU output into the branch logic** (chosen) | The ALU, branch forwarding mux, zero detect, and next-PC mux all run in series within one cycle. This becomes the longest path in the design and would set the clock period. |

I took the longer critical path to keep zero-stall `SUBS → CBZ` and `SUBS → B.LT` sequences. The same idea applies to the flags: `B.LT` reads the live ALU N/V outputs instead of waiting for the flags register. In a design that needed a higher clock speed, I would stall these cases instead.

### Write-through register file instead of split-cycle writes

The usual way to make a WB write visible to a same-cycle ID read is to write on the first half of the clock and read on the second half, which requires two clock edges. Instead, the register file compares the write and read addresses and muxes `WriteData` straight to the output. This keeps the whole design on a single rising edge. The cost is a 5-bit comparator and a 64-bit mux per read port.

### Bubbles by zeroing control bits, not the whole register

On a load-use stall, only the control bits entering ID/EX are forced to zero, using one AND gate each. The 64-bit data fields are left alone. With `RegWrite`, `MemWrite`, `MemRead`, and `FlagWrite` all zero, the instruction can't change any architectural state, so its data values don't matter. This uses 7 gates instead of resetting hundreds of flip-flops.

### Conservative hazard detection

The hazard unit compares both source-register fields without checking whether the instruction actually uses them. For example, `ADDI` has immediate bits where `Rm` would be. This can occasionally cause an unnecessary stall, but it can never miss a real one. Keeping the logic simple was worth a rare extra cycle.

### Gate-level datapath, behavioral control

Everything that moves data is structural gates with real propagation delays. As a result, the simulation shows true timing behavior and the critical paths described above. The control units are written as behavioral truth tables because they are pure decode logic. Expanding them into gates would add many lines without showing anything new.

### Limitations

- `B.cond` implements only the `LT` condition (N ≠ V).
- Memory accesses are fixed at 64 bits; there are no byte or word loads.
- Branch resolution in ID means branches are never predicted. Every branch relies on its delay slot instead.

---

## Repository Layout

| File | Description |
|------|-------------|
| `pipeline_cpu.sv` | Top level: all five stages, pipeline registers, forwarding/hazard wiring |
| `control.sv` | Main decoder: opcode → control signals |
| `ALUControl.sv` | Picks the ALU operation |
| `ForwardingUnit.sv` | EX/MEM and MEM/WB forwarding selects |
| `HazardDetectionUnit.sv` | Load-use stall detection |
| `PipelineReg.sv` | Register with flush (used for IF/ID) |
| `regfile.sv` | 32×64 register file with write-through bypass, X31 = 0 |
| `Register.sv`, `D_FF.sv` | 64-bit enabled register built from D flip-flops |
| `Decoder.sv` | 5:32 write decoder built from 2:4 and 3:8 decoders |
| `Multiplexer.sv` | Gate-level 2:1, 4:1, 8:1, and 32:1 muxes and their 64-bit wrappers |
| `alu.sv`, `logic_gates.sv`, `full_adder.sv`, `adder_subtractor.sv` | 64-bit ALU |
| `sign_extend.sv` | I / D / B / CB immediate extension |

The CPU connects to a 32-bit instruction memory (`instructmem`) and a byte-addressed, little-endian 64-bit data memory (`datamem`). Those modules and the simulation testbench are not part of this repository.

---

## Verification

The CPU was verified in ModelSim/Questa with self-checking simulations. Each run loads a LEGv8 program into instruction memory and runs it to completion. Assertions then check the final register file, flags, and data memory against expected values. If any instruction was mis-forwarded, stalled incorrectly, or executed when it should have been skipped, the end state would be wrong.

Testing was layered so each pipeline mechanism was proven before the next one depended on it:

1. **Single-instruction correctness.** Arithmetic, flag-setting, loads/stores, and each branch type were run on their own to confirm the datapath and control before stressing the hazard logic.
2. **Targeted hazard tests.** Short programs placed dependent instructions back to back to trigger each mechanism directly:
   - EX/MEM and MEM/WB forwarding into the ALU
   - Register-file write-through
   - Load-use stalls and bubbles
   - Branch operands and flags forwarded into ID
   - Correct handling of X31 and the branch delay slot
3. **Full programs.** A bubble sort and a recursive Fibonacci were run with call/return through a memory stack. These mix every hazard type in tight loops and nested calls, so the pipeline is tested on realistic instruction streams rather than isolated cases.
