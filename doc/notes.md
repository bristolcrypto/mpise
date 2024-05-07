- The DAC paper basically considered a 3-component ISE, which included

  1. support for    full-radix multiply-add:

     ```
     maddlu   rd, rs1, rs2, rs3 {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << 64) - 1
       r       <- ( (x * y + z)         & m) 
       GPR[rd] <- r
     }
   
     maddhu   rd, rs1, rs2, rs3 {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << 64) - 1
       r       <- (((x * y  + z) >> 64) & m) 
       GPR[rd] <- r
     }
     ```

  2. support for reduced-radix multiply-add:

     ```
     madd57lu rd, rs1, rs2, rs3 {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << 57) - 1
       r       <- ( (x * y)        & m) + z 
       GPR[rd] <- r
     }
   
     madd57hu rd, rs1, rs2, rs3 {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << 64) - 1
       r       <- (((x * y) >> 57) & m) + z 
       GPR[rd] <- r
     }
     ```

  3. support for carry propagation:

     ```
     cadd     rd, rs1, rs2, rs3 {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       r       <- ((x + y) >> 64) + z
       GPR[rd] <- r
     }  

     sraiadd  rd, rs1, rs2, imm {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       r       <- x + EXTS(y >> imm)
       GPR[rd] <- r
     }
     ```

- As a first step, the goal is to generalise the reduced-radix component:
  doing so will replace the fixed limb size (of 57 bits) with a parameter.
  Ignoring the challenge of encoding, there are 2 high level approaches:

  1. stateful  (or CSR)       variant:

     ```
     maddrrlu rd, rs1, rs2, rs3      {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << f_0(CSR[maddrr])) - 1
       r       <- (((x * y) >> f_1(CSR[maddrr])) & m) + z 
       GPR[rd] <- r
     }
   
     maddrrhu rd, rs1, rs2, rs3      {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << f_2(CSR[maddrr])) - 1
       r       <- (((x * y) >> f_3(CSR[maddrr])) & m) + z 
       GPR[rd] <- r
     }
     ```

  2. stateless (or immediate) variant:

     ```
     maddrrlu rd, rs1, rs2, rs3, imm {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << f_0(imm        )) - 1
       r       <- (((x * y) >> f_1(imm        )) & m) + z 
       GPR[rd] <- r
     }
   
     maddrrhu rd, rs1, rs2, rs3, imm {
       x       <- GPR[rs1]
       y       <- GPR[rs2]
       z       <- GPR[rs3]
       m       <- (1 << f_2(imm        )) - 1
       r       <- (((x * y) >> f_3(imm        )) & m) + z 
       GPR[rd] <- r
     }
     ```

  where

  ```
  f_0(x) = selection of radix based on x
  f_1(x) =  0
  f_2(x) = 64
  f_3(x) = selection of radix based on x
  ```

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

  +--------+------+-----------------------------------------------------------+
  | Option | Bits | Constraints                                               |
  +--------+------+-----------------------------------------------------------+
  | 1.     |  5   | 5 bits = 4 for radix + 1 for high/low opcode is not a lot |
  | 2.     |  5   | 5 bits = 4 for radix + 1 for high/low opcode is not a lot |
  | 3a.    | 10   | need to demonstrate impact, e.g., re. additional moves    |
  | 3b.    | 10   | need to demonstrate impact, e.g., re. additional moves    |
  +--------+------+-----------------------------------------------------------+

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
