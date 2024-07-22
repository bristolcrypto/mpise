# General notes

- The DAC paper basically considered a 3-component ISE, which included

  1. support for carry propagation,
  2. support for    full-radix multiply-add,
  3. support for reduced-radix multiply-add.

- As a first step, the goal is to generalise the reduced-radix component:
  doing so will replace the fixed limb size (of 57 bits) with a parameter.
  Ignoring the challenge of encoding, there are 2 high level approaches:

  1. stateful  (or CSR)       variant,
  2. stateless (or immediate) variant.

- Note that the stateful variant obviously introduces state, namely the
  CSR: relative to the stateless variant, this is a disadvantage.  That
  said, however, this overhead could plausibly be shared *if* one sets
  this ISE in the context of a broader extension.
  For example,
  [Alkim et al.](https://tches.iacr.org/index.php/TCHES/article/view/8589)
  present an ISE for arithmetic in a small finite field to support Kyber 
  and NewHope: they consider fixed and flexible variants, with the latter
  CSR to store the configuration (e.g., the modulus).

- [RISC-V specification](https://riscv.org/technical/specifications)
  states that the R4 instruction format (ab)used by the DAC paper
  "*is only used by the floating-point fused multiply-add instructions*",
  i.e., `f[n]madd` and `f[n]msub`: this use-case consumes an entire major
  opcode (i.e., `opcode = 1001011`), and therefore a significant amount of 
  encoding space.  As is, R4 uses 

  - a 2-bit `fmt' field to specify the floating-point format
  - a 3-bit `rm` field to specify the rounding mode

  The value `fmt = 10` is reserved, meaning it *could* be used an integer 
  format; the values `rm = 101` and `rm = 110` are also reserved.  

- The *ideal* instruction would be 5-address, in the sense one can specify 
  3 inputs and 2 outputs for more- and less-significant halves of a result:

  - using 1 output        is better aligned with the 3-address norm, 
    but
    implies a need for separate instructions to produce the
  - using 2  inputs would be better aligned with the 3-address norm, 
    but
    makes the ISE redundant: we are left with `mul` and `mulhi` from the base ISA.

  So, treating a 4-address format as a requirement and ignoring some more
  exotic options (e.g., via use of 64-bit instructions), we could

  1. use the R4      format with existing    major opcode, 
     i.e., make ISE mutually exclusive with F and D floating-point extensions,
  2. use the R4      format with alternative major opcode,
  3. use an  R4-like format with alternative major opcode, 
     e.g.,

     a. destructive semantics: overload `rd` to produce both `rd` and `rs3`
     b. implicit addresses: make `rs3` implied rather than explicit

  as characterised by the following:

  | Option | Bits | Constraints                                               |
  |:-------|:-----|:----------------------------------------------------------|
  | 1.     |  5   | 5 bits = 4 for radix + 1 for high/low opcode is not a lot |
  | 2.     |  5   | 5 bits = 4 for radix + 1 for high/low opcode is not a lot |
  | 3a.    | 10   | need to demonstrate impact, e.g., re. additional moves    |
  | 3b.    | 10   | need to demonstrate impact, e.g., re. additional moves    |

  Note that 3a. was considered for the design of R4, with the specification 
  explicitly documenting
  "*[destructive] use of `rd` to provide `rs3`*"
  as an option.

- Although concrete choices re. all the above will be needed to support an
  implementable design, it is also important to remember that details such
  as the the instruction variant and encoding are somewhat orthogonal to
  the impact on execution latency.

  For example, the stateful and stateless variants are basically equivalent 
  in terms of execution latency.  Assuming both variants have single-cycle 
  latency per instruction, the granularity of changes to the radix will be 
  (very) coarse: one selects and uses one radix per high-level construction,
  so changes to the radix will be infrequent and their cost amortised.

- Some other notes:

  - Johann estimated that we should support a set of radix between 48 and
    63 bits, although this set may be sparse (provided motivation for any
    included or excluded cases).  Note that the set
    `{ 48, 49, ..., 63 }'
    has 16 elements, meaning 4 bits to select an element.
  - Ideally, it would be attractive to subsume the full-radix multiply-add
    via selection of 64 as the radix; this needs some thought, however.
  - At least in theory, it *might* be plausible to allow a larger set of
    radix to be specified versus actually supported in hardware.  Doing so
    might allow the hardware to be specialised (e.g., for 57 only, per the
    DAC paper), but is implies a need for discoverability of supported
    versus unsupported cases: raising an exception for the latter is at
    least possible, but not very elegant.
  - As the name implies, the stateful variant requires additional state,
    i.e., a CSR: as well as implying additional overhead re. area, this has
    impact, e.g., re. the need to context switch that state.
  - Encoding pressure on the stateless variant is clearly much higher than
    the stateful variant, because selection of radix is based on `imm`: use
    of a CSR potentially offers more bits than for `imm`, which implies the
    stateful variant might be able to offer a larger set of radix.

- The merged full- and reduced-radix approach yields various properties re. 
  implementation:

  - The data-path for high and low instructions, i.e., the computation
    steps, is the same (the difference comes from the `f_i`); we're
    basically doing a post-processing step on the multiplication that
    generates `t_0`.
  - What look like multiplexers to generate `t_1` and `t_2` are really
    just AND gates, because we either want `z` or `0`.
  - Most of the `f_i` functions are trivial (e.g., `f_2), and some are
    duplicates (e.g., `f_0` and `f_1`).
  - Since the design can be parameterised by the word size, it *could* be
    considered for RV64 and RV32: this could be viewed as an advantage.

# INNER-LOOP OPERATIONS

Based on the instructions defined above, we have to distinguish between four implementations for the inner-loop operation of the multi-precision multiplication: (i) full-radix prepresentation with non-destructive instructions, (ii) full-radix prepresentation with destructive instructions, (iii) reduced-radix prepresentation with non-destructive instructions, and (iv) reduced-radix prepresentation with destructive instructions. The two former cases are the more challenging ones.

# 1. Full-radix representation with non-desructive instructions

This is basically the full-radix implementation from the DAC 2024 paper. The accumulator consists of the three registers L, M, and H.

  ```
  .macro MUL_ADD_FR_ND L, M, H, T, A, B
    maccfrhu \T, \A, \B, \L    // hi-part first, result in T
    maccfrlu \L, \A, \B, \L    // then lo-part, result in L
    cacc     \H, \M, \T, \H    // propagate carry from M to L
    add      \M, \M, \T        // add result of hi-part to M
  .endm
  ```

Note that the addend of both `maccfrlu` and `maccfrhu` is the same, namely L. There are two carry propagations, one from L to M, and another one from M to H. The former is implicitly performed as part of the `maccfrhu` instruction, while the latter is done through the `cacc` instruction.

# 2. Full-radix representation with desructive instructions

Due to the desructive nature `maccfrlu` and `maccfrlu`, a `mv` instruction is necessary to save the content of L.

  ```
  .macro MUL_ADD_FR_D L, M, H, T, A, B
    mv       \T, \L            // necessary for destr. instr.
    maccfrhu \T, \A, \B        // hi-part first, result in T
    maccfrlu \L, \A, \B        // then lo-part, result in L
    cacc     \H, \M, \T        // propagate carry from M to L
    add      \M, \M, \T        // add result of hi-part to M
  .endm
  ```

Apart from the `mv` instruction, the implementation with destructive instructions is very similar to the non-destructive case. It seems to be impossible to have a destructive version with less than 5 instructions.

# 3. Reduced-radix representation with non-desructive instructions

This is basically the reduced-radix implementation from the DAC 2024 paper. The accumulator consists of the two registers L and H.

  ```
  .macro MUL_ADD_RR_ND L, H, A, B 
    maccrrlu \L, \A, \B, \L
    maccrrhu \H, \A, \B, \H
  .endm
  ```

Note that the addend of `maccfrlu` is L, whereas the addend of `maccfrhu` H. Assuming that the number-representation radix has been chosen properly, there is no carry propagation from L to H and there should also be no overflow (i.e., no carry-out) of H.

# 4. Reduced-radix representation with desructive instructions

The implementation using destruvtive instructions is basically the same as the non-destructive version above.

# 5. Full-radix instructions as special case of reduced-radix instructions

Here we assume that A and B are 64 bits long. Futhermore, we assume that `maccrrlu rd, rs1, rs2, rs3` adds `rs3` to the lower 64 bits of the product `rs1*rs2` and that `maccrrhu rd, rs1, rs2, rs3` adds `rs3` to the upper 64 bits of the product `rs1*rs2`. We only consider here the non-destructive instructions.

The highly-efficient reduced-radix implementation using only 2 instructions does not work anymore since each of the accu registers can overflow. Thus, we have to manually do a carry propagation from L to M and from M to H.

  ```
  .macro MUL_ADD_RR_ND L, M, H, TL, TM, A, B
    maccrrlu \TL, \A, \B, \L   // lo-part first, result in TL
    sltu     \TM, \TL, \L      // TM is 0 or 1 (carry from L to M)
    maccrrhu \TM, \A, \B, \TM  // TM can not overflow here !!!
    cacc     \H, \M, \TM, \H   // propagate carry from M+TM to H
    add      \M, \M, \TM       // add hi-part of product to M
  .endm
  ```

The accumultor is now in TL, M, H instead of L, M, H. This version requires 5 instructions.

Note that the reduced-radix `maccrrlu` for a radix of 2^64 is equivalent to the full-radix `maccfrlu` instruction. On the other hand, the reduced-radix `maccrrhu` instruction for a radix of 2^64 differs from the the full-radix `maccfrhu` instruction with respect to carry propagation. As a consequence, when we want to support full-radix as a special case of reduced-radix and still achieve peak perforrmance with both radix representations, we would need 1 kind of MACC instruction for the lower part, but 2 kinds of MACC instruction for the upper part.

An implementation using destructive instructions requires a `mv` instruction to save the content of L before `maccrrlu` is executed, i.e., the number of instructios increases to six.

# 6. Full-radix variant using only native multiply instructions

Below is a low-const variant for full-radix representation that uses the native multiply instructions and `cacc` as only custom instruction.

  ```
  .macro MUL_ADD_FR_ND L, M, H, TL, TH, A, B 
    mul      \TL, \A, \B
    mulhi    \TH, \A, \B
    cacc     \TH, \TL, \L, \TH // no carry out !!!
    cacc     \H,  \TH, \M, \H
    add      \L, \L, \TL
    add      \M, \M, \TH
  .endm
  ```
