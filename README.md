# cs3220-assembler
Assembler for Gatech Fall 2016 CS 3220 Processor Design

## Usage
`./assembler.pl infile.a32 outfile.mif`

## Updating the assembler for a different ISA

There are two hash structures used to define the instructions: %OPCODE and %INSTR
* %INSTR references the values in the %OPCODE hash, to assist with defining the iwords.
* Each instruction in %INSTR has an iword and fmt defined.

Ex:
```
    ADD     => {iword => "$OPCODE{ALU_R} 0111 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
```

### Rules
* iword should be formatted as a binary string, with placeholders for the reg num or imm value from the assembly instruction
* fmt should include every placeholder defined in the iword, in the order that the values are listed in the assembly instruction
* Placeholder tokens in iword should be separated from each other and the hardcoded binary with a space, as shown
* Placeholder tokens in fmt should be separated with a comma (or in some cases parens, as seen in the JAL instruction)
