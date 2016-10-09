Two-phase configurable priority encoder in VHDL
===============================================
This code has been published first on 21st of September 2016 as PUBLIC DOMAIN at usenet alt.sources group
with the subject "Two-phase configurable priority encoder in VHDL".

The post is available in the [google archive](https://groups.google.com/forum/#!topic/alt.sources/vMhX5RKEDPY)

This archive contains sources of the priority encoder, that returns number of the first input with '1'.

The entity is defined as:

```
entity two_prior_enc is
  generic(
    N_INPUTS   : integer := 32;         -- Number of inputs
    N_1ST_BITS : integer := 3           -- Number of bits in the 1st stage
    );
  port (inputs : in  std_logic_vector (N_INPUTS-1 downto 0);
        first  : out integer range 0 to N_INPUTS-1 := 0;
        found  : out std_logic;
        clk    : in  std_logic;
        rst_p  : in  std_logic);
end two_prior_enc;
```

`N_INPUTS` is the total number of inputs.
`N_1ST_BITS` is the number of bits handled on the 1st stage.

The inputs are divided into groups of `2**N_1ST_BITS` bits.
At the falling edge of the clock, the 1st '1' is found in each group.

At the rising edge of the clock the first group with '1' is found
and the number of group and the number of the input in the group is encoded.

The code is published under Public Domain or Creative Commons CC0 license
(whatever better suits your needs)

This is a free and Open Source solution. I don't give any warranty.
You use it at your own risk!

Wojciech M. Zabolotny wzab01@gmail.com


