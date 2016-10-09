Script to generate VHDL package for conversion between the record type and std_logic_vector
===============================================
This first version of this code has been published first on 19th of March 2012 as PUBLIC DOMAIN at usenet alt.sources group
with the subject "Script to generate VHDL package for conversion between the record type and std_logic_vector".
The post is available in the [google archive](https://groups.google.com/forum/#!topic/alt.sources/U-phIIAT6dE)

The record types in VHDL are very useful when designing more
complicated systems. However if you need to store data of record
types to memory or FIFO, it is necessary to convert such data 
to the `std_logic_vector` type.
Similarly, when such data are read from the memory or FIFO, 
it is necessary to convert to the original record type.
This problem was often discussed, eg. [here](http://stackoverflow.com/questions/3985694/serialize-vhdl-record) or [here](http://objectmix.com/vhdl/190447-converting-records-std_logic_vector.html)

Finally I've decided to prepare a Python script which automatically
generates the appropriate VHDL package containing both the
records type declaration and functions to convert between this type and
`std_logic_vector`.

The `rec_to_pkg_nest.py` script creates VHDL package for conversion
between the VHDL records containing `signed`, `unsigned`,
`std_logic_vector` and `std_logic` fields and `std_logic_vector`.

Additionally, the record may contain also another record,
defined previously in the same decription file.

It should be called as: rec_to_pkg_nest.py description_file
where the description file should have the following syntax:

```
#Optional comment line
package package_name
## Comments starting with double hash are accumulated and
## copied at the begining of the generated vhdl file
#Then one or more record definitions
record record_name
#optional comment lines
#[...]
field_name,signed_or_unsigned,width
#or
field_name,signed_or_unsigned,left_bit_nr,right_bit_nr
#or
field_name,rec,previously_defined_record
end
```
I hope, that you'll find this script useful.
As it is published as PUBLIC DOMAIN or under Creative Commons CC0 license, you are free to modify and use it
in any way you want.

However, if you create any derived work, please provide information
about the original author.

Wojciech M. Zabolotny
wzab01@gmail.com


