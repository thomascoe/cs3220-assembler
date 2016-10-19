#!/usr/bin/perl
use strict;
use warnings;

## globals
# Size of the memory
my $DEPTH = 2048;           # Number of addresses (i.e. number of words)
my $WIDTH = 32;             # Number of bits per word
# Radixes in BIN, DEC, HEX, OCT, or UNS
my $ADDRESS_RADIX = "HEX";  
my $DATA_RADIX = "HEX";
# Opcodes for different instruction types
my %OPCODE = (
    ALU_R   => "0000",
    ALU_I   => "1000",
    LW      => "1001",
    SW      => "0101",
    CMP_R   => "0010",
    CMP_I   => "1010",
    BRANCH  => "0110",
    JAL     => "1011",
);
# Opcodes combined with function codes (these are the 'opcodes' provided in the assembly)
my %FN_OPCODE = (
    # ALU-R
    ADD     => "0000".$OPCODE{ALU_R},
    SUB     => "0001".$OPCODE{ALU_R},
    AND     => "0100".$OPCODE{ALU_R},
    OR      => "0101".$OPCODE{ALU_R},
    XOR     => "0110".$OPCODE{ALU_R},
    NAND    => "1100".$OPCODE{ALU_R},
    NOR     => "1101".$OPCODE{ALU_R},
    XNOR    => "1110".$OPCODE{ALU_R},
    # ALU-I
    ADDI    => "0000".$OPCODE{ALU_I},
    SUBI    => "0001".$OPCODE{ALU_I},
    ANDI    => "0100".$OPCODE{ALU_I},
    ORI     => "0101".$OPCODE{ALU_I},
    XORI    => "0110".$OPCODE{ALU_I},
    NANDI   => "1100".$OPCODE{ALU_I},
    NORI    => "1101".$OPCODE{ALU_I},
    XNORI   => "1110".$OPCODE{ALU_I},
    MVHI    => "1011".$OPCODE{ALU_I},
    # Load/Store
    LW      => "0000".$OPCODE{LW},
    SW      => "0000".$OPCODE{SW},
    # CMP-R
    F       => "0000".$OPCODE{CMP_R},
    EQ      => "0001".$OPCODE{CMP_R},
    LT      => "0010".$OPCODE{CMP_R},
    LTE     => "0011".$OPCODE{CMP_R},
    T       => "1000".$OPCODE{CMP_R},
    NE      => "1001".$OPCODE{CMP_R},
    GTE     => "1010".$OPCODE{CMP_R},
    GT      => "1011".$OPCODE{CMP_R},
    # CMP-I
    FI      => "0000".$OPCODE{CMP_I},
    EQI     => "0001".$OPCODE{CMP_I},
    LTI     => "0010".$OPCODE{CMP_I},
    LTEI    => "0011".$OPCODE{CMP_I},
    TI      => "1000".$OPCODE{CMP_I},
    NEI     => "1001".$OPCODE{CMP_I},
    GTEI    => "1010".$OPCODE{CMP_I},
    GTI     => "1011".$OPCODE{CMP_I},
    # BRANCH
    BF      => "0000".$OPCODE{BRANCH},
    BEQ     => "0001".$OPCODE{BRANCH},
    BLT     => "0010".$OPCODE{BRANCH},
    BLTE    => "0011".$OPCODE{BRANCH},
    BEQZ    => "0101".$OPCODE{BRANCH},
    BLTZ    => "0110".$OPCODE{BRANCH},
    BLTEZ   => "0111".$OPCODE{BRANCH},
);

{ ## BEGIN main scope block
    # Get command line params. Print usage if undefined
    my ($infile, $outfile) = @ARGV;
    if ((not defined $infile) or (not defined $outfile)) {
        print "Syntax: $0 infile outfile\n";
        exit;
    }
    parse_input($infile);
    if ($outfile eq "stdout") {
        $outfile = undef;
    }
    build_memory($outfile);
} ## END main scope block

sub parse_input
{
    my ($infile) = @_;
    return if not defined $infile;
    print "Reading input file $infile...\n";
    open(my $fh, '<', $infile) or die "Couldn't open input file '$infile': $!\n";
    
    while (my $line = <$fh>) {
        chomp $line;
        print "$line\n";
    }
}

sub build_memory
{
    my ($outfile) = @_;
    
    # If output file defined, write to it. Otherwise use STDOUT
    my $fh;
    if (defined $outfile) {
        open($fh, '>', $outfile) or die "Couldn't open output file '$outfile': $!\n";
        print "Generating $outfile...\n";
    }
    else {
        $fh = \*STDOUT;
    }
    
    print $fh <<END_HEADER;
DEPTH = $DEPTH
WIDTH = $WIDTH
ADDRESS_RADIX = $ADDRESS_RADIX
DATA_RADIX = $DATA_RADIX

CONTENT
BEGIN

END_HEADER
    # TODO: Print address content
    print $fh "\nEND;\n";
}
