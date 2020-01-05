# Smith_Waterman_Hardware_Implementation

## Hardware

### Specification
Execute the python file `spec.py`.
Put the ouput verilog file to `src/spec.v`
> usage: spec.py [-h] [-o FILE] [-ma MA] [-pe PE] [-t T] [-sw SW] [-sa SA]
>               [-buf BUF]
>
>Set the specification of the Smith-Waterman hardware. you can set the number
>by either the command line or user interface(no any argument).
>
>optional arguments:
>  -h, --help  show this help message and exit
>  -o FILE     The destinationof output file.
>
>input data:
>  -ma MA      the maxinum bits of match.
>  -pe PE      the maxinum length of query DNA.(i.e. the number of cell PE)
>  -t T        the bits of the maxinum amount of target DNA.
>
>hardware:
>  -sw SW      the width of SRAM word.
>  -sa SA      the bits of SRAM address.
>  -buf BUF    the size of buffer for query DNA.

### RTL
```sh
ncverilog -f rtl.f
```

### Synthesis
```sh
ncverilog -f syn.f
```
* Synthesis cycle time : $2.25(ns)$
* Post-simulation cycle time : $2.25(ns)$
* Area : $4750163.688184(\mu m^2)$

### Place & Route
```sh
ncverilog -f apr.f
```
* APR Cycle Time : $20.0(ns)$
* Post-simulation Cycle Time : $20.0(ns)$
* Die Area : $10001183.96(\mu m^2)$
* Core Area : $9500356.29(\mu m^2)$