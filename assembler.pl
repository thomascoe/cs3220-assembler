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
    BT      => "1000".$OPCODE{BRANCH},
    BNE     => "1001".$OPCODE{BRANCH},
    BGTE    => "1010".$OPCODE{BRANCH},
    BGT     => "1011".$OPCODE{BRANCH},
    BNEZ    => "1101".$OPCODE{BRANCH},
    BGTEZ   => "1110".$OPCODE{BRANCH},
    BGTZ    => "1111".$OPCODE{BRANCH},
    JAL     => "0000".$OPCODE{JAL},
);
my %REG_NUM = (
    R0  => "0000",
    R1  => "0001",
    R2  => "0010",
    R3  => "0011",
    R4  => "0100",
    R5  => "0101",
    R6  => "0110",
    R7  => "0111",
    R8  => "1000",
    R9  => "1001", # Reserved for assembler
    R10 => "1010",
    R11 => "1011",
    R12 => "1100",
    R13 => "1101",
    R14 => "1110",
    R15 => "1111",
);
my %REG_ALIAS = (
    # Function arguments
    A0  => "R0",
    A1  => "R1",
    A2  => "R2",
    A3  => "R3",
    # Return value (R3)
    RV  => "R3",
    # Temporaries (R4 and R5)
    T0  => "R4",
    T1  => "R5",
    # Calee-saved values
    S0  => "R6",
    S1  => "R7",
    S2  => "R8",
    # Pointers
    GP  => "R12",
    FP  => "R13",
    SP  => "R14",
    RA  => "R15",
);
my @PSEUDO_INSTRS = qw(BR NOT BLE BGE CALL RET JMP);

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
        if ($line =~ /^\./) { # special instruction (.ORIG, .WORD, .NAME)
            # TODO
        }
        elsif ($line =~ /^[a-zA-Z0-9]+:/) { #label
            # TODO
        }
        else { # Regular instruction
            my $instr = parse_instruction($line);
        }
    }
}

sub parse_instruction
{
    my ($line) = @_;
    my ($opcode, @tokens) = split / /, $line;

    # Print opcode and tokens for testing
    print "opcode: $opcode ";
    foreach my $token (@tokens) {
        print "token: $token";
        if (my $bin = reg2bin($token)) {
            print "/$bin; ";
        }
        else {
            print ";";
        }
    }
    print "\n";

    # Check if this is a pseudo instruction
    if (grep(/^$opcode$/, @PSEUDO_INSTRS)) {
        my $expected_num_tokens;
        if ($opcode eq 'BR' or $opcode eq 'CALL' or $opcode eq 'JMP') {
            $expected_num_tokens = 1;
        }
        elsif ($opcode eq 'NOT') {
            $expected_num_tokens = 2;
        }
        elsif ($opcode eq 'BLE' or $opcode eq 'BGE') {
            $expected_num_tokens = 3;
        }
        elsif ($opcode eq 'RET') {
            $expected_num_tokens = 0;
        }

        # Check valid number of parameters
        if (scalar @tokens != $expected_num_tokens) {
            print "Invalid number of parameters for '$opcode' on line $.\n";
            return;
        }

        # Individual behaviour for each pseudo instruction
        # TODO: Translate to regular instruction
        if ($opcode eq 'BR') {
        }
        else {
            print "Pseudo opcode $opcode not implemented!\n";
            return;
        }
    }

    # Check if this is a valid opcode
    if (!exists $FN_OPCODE{$opcode}) {
        print "Invalid opcode: $opcode\n";
        return;
    }

    # TODO
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

# Convert a register name to binary number
# Return string with binary value, or undef
sub reg2bin
{
    my ($reg) = @_;
    if (!defined $reg) {
        return undef;
    }
    if (exists $REG_NUM{$reg}) {
        return $REG_NUM{$reg};
    }
    if (exists $REG_ALIAS{$reg}) {
        return $REG_NUM{$REG_ALIAS{$reg}};
    }
    return undef;
}
