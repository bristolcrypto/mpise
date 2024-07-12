- Let `w = 64` be the word size.

- Ignoring the issues of (non-)destructive and (non-)stateful, which
  are basically to do with supply of operands, the starting point is

  ```
  t_maccfrlu x, y, z {
    m       <- (1 << w) - 1
    r       <- ( (x * y + z)       & m) 
    return r
  }
   
  t_maccfrhu x, y, z {
    m       <- (1 << w) - 1
    r       <- (((x * y + z) >> w) & m) 
    return r
  }


  t_maccrrlu x, y, z, c {
    m       <- (1 << f_0(c)) - 1
    r       <- (((x * y) >> f_1(c)) & m) + z 
    return r
  }
      
  t_maccrrhi x, y, z, c {
    m       <- (1 << f_2(c)) - 1
    r       <- (((x * y) >> f_3(c)) & m) + z 
    return r
  }
  ```

  where

  ```
  f_0(c) = c + 48
  f_1(c) = 0
  f_2(c) = w
  f_3(c) = c + 48
  ```

- It seems we can merge these, with full-radix as a special-case:
  
  ```
  t_macclu x, y, z, c {
    t_0 <- x * y
    t_1 <- f_0(c) ? z : 0
    t_2 <- f_0(c) ? 0 : z
    m   <- (1 << f_1(c)) - 1
    r   <- (((t_0 + t_1) >> f_2(c)) & m) + t_2
    return r
  }
  ```

  and

  ```
  t_macchi x, y, z, c {
    t_0 <- x * y
    t_1 <- f_3(c) ? z : 0
    t_2 <- f_3(c) ? 0 : z
    m   <- (1 << f_4(c)) - 1
    r   <- (((t_0 + t_1) >> f_5(c)) & m) + t_2
    return r
  }
  ```

  where

  ```
  f_0(c) = 0      if c means reduced-radix
           1      if c means    full-radix

  f_1(c) = c + 48 if c means reduced-radix
           w      if c means    full-radix

  f_2(c) = 0      if c means reduced-radix
           0      if c means    full-radix

  f_3(c) = 0      if c means reduced-radix
           1      if c means    full-radix

  f_4(c) = w      if c means reduced-radix
           w      if c means    full-radix

  f_5(c) = c + 48 if c means reduced-radix
           w      if c means    full-radix
  ```

- The merge yields various properties re. implementation:

  - The data-path for high and low instructions, i.e., the computation
    steps, is the same (the difference comes from the `f_i`); we're
    basically doing a post-processing step on the multiplication that
    generates `t_0`.
  - What look like multiplexers to generate `t_1` and `t_2` are really
    just AND gates, because we either want `z` or `0`.
  - Most of the `f_i` functions are trivial (e.g., `f_2), and some are
    duplicates (e.g., `f_0` and `f_1`).
  - In the old version, we used `c + 48` as the derived radix: as such
    `0 <= c < 2^4` 
    yields
    `48 <= reduced radix < 64`.
    Although there are other options, if we were to reserve `c = 0` to 
    mean full-radix,
    `1 <= c < 2^4` 
    yields
    `49 <= reduced radix < 64`.
