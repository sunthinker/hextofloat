## Description
- Hex(4bytes) convert to float.
- IEEE754
- Use for weakly-typed language
- Support Lua5.3+(Bit operations were only supported in Lua5.3+)
## About IEEE754
- s sign
- E exponent(store)
- e exponent(real)
- M magnitude
- E == 0, (-1)^s*2^e*(0.M), e = 1-127
- E not all is 1 and not all is 0, (-1)^s*2^e*(1.M), e = E-127