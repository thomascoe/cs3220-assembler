#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

## globals
# Size of the memory
my $DEPTH = 2048;           # Number of addresses (i.e. number of words)
my $WIDTH = 32;             # Number of bits per word
# Radixes in BIN, DEC, HEX, OCT, or UNS
my $ADDRESS_RADIX = "HEX";
my $DATA_RADIX = "HEX";
# Opcodes for different instruction types
my %OPCODE = (
    ALU_R   => "1100",
    ALU_I   => "0100",
    LW      => "0111",
    SW      => "0011",
    CMP_R   => "1101",
    CMP_I   => "0101",
    BRANCH  => "0010",
    JAL     => "0110",
);
# Instruction definitions (iword is the binary, fmt is the assembly)
my %INSTR = (
    # ALU-R
    ADD     => {iword => "$OPCODE{ALU_R} 0111 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    SUB     => {iword => "$OPCODE{ALU_R} 0110 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    AND     => {iword => "$OPCODE{ALU_R} 0000 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    OR      => {iword => "$OPCODE{ALU_R} 0001 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    XOR     => {iword => "$OPCODE{ALU_R} 0010 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    NAND    => {iword => "$OPCODE{ALU_R} 1000 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    NOR     => {iword => "$OPCODE{ALU_R} 1001 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    XNOR    => {iword => "$OPCODE{ALU_R} 1010 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    # ALU-I
    ADDI    => {iword => "$OPCODE{ALU_I} 0111 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    SUBI    => {iword => "$OPCODE{ALU_I} 0110 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    ANDI    => {iword => "$OPCODE{ALU_I} 0000 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    ORI     => {iword => "$OPCODE{ALU_I} 0001 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    XORI    => {iword => "$OPCODE{ALU_I} 0010 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    NANDI   => {iword => "$OPCODE{ALU_I} 1000 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    NORI    => {iword => "$OPCODE{ALU_I} 1001 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    XNORI   => {iword => "$OPCODE{ALU_I} 1010 RD RS1  imm",
                fmt => "RD,RS1,imm"},
    MVHI    => {iword => "$OPCODE{ALU_I} 1111 RD 0000 imm",
                fmt => "RD,imm"},
    # Load/Store
    LW      => {iword => "$OPCODE{LW} 0000 RD  RS1 imm",
                fmt => "RD,imm(RS1)"},
    SW      => {iword => "$OPCODE{SW} 0000 RS2 RS1 imm",
                fmt => "RS2,imm(RS1)"},
    # CMP-R
    F       => {iword => "$OPCODE{CMP_R} 0011 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    EQ      => {iword => "$OPCODE{CMP_R} 0110 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    LT      => {iword => "$OPCODE{CMP_R} 1001 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    LTE     => {iword => "$OPCODE{CMP_R} 1100 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    T       => {iword => "$OPCODE{CMP_R} 0000 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    NE      => {iword => "$OPCODE{CMP_R} 0101 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    GTE     => {iword => "$OPCODE{CMP_R} 1010 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    GT      => {iword => "$OPCODE{CMP_R} 1111 RD RS1 RS2 000000000000",
                fmt => "RD,RS1,RS2"},
    # CMP-I
    FI      => {iword => "$OPCODE{CMP_I} 0011 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    EQI     => {iword => "$OPCODE{CMP_I} 0110 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    LTI     => {iword => "$OPCODE{CMP_I} 1001 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    LTEI    => {iword => "$OPCODE{CMP_I} 1100 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    TI      => {iword => "$OPCODE{CMP_I} 0000 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    NEI     => {iword => "$OPCODE{CMP_I} 0101 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    GTEI    => {iword => "$OPCODE{CMP_I} 1010 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    GTI     => {iword => "$OPCODE{CMP_I} 1111 RD RS1 imm",
                fmt => "RD,RS1,imm"},
    # BRANCH
    BF      => {iword => "$OPCODE{BRANCH} 0011 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BEQ     => {iword => "$OPCODE{BRANCH} 0110 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BLT     => {iword => "$OPCODE{BRANCH} 1001 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BLTE    => {iword => "$OPCODE{BRANCH} 1100 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BEQZ    => {iword => "$OPCODE{BRANCH} 0010 RS1 0000 imm",
                fmt => "RS1,imm"},
    BLTZ    => {iword => "$OPCODE{BRANCH} 1101 RS1 0000 imm",
                fmt => "RS1,imm"},
    BLTEZ   => {iword => "$OPCODE{BRANCH} 1000 RS1 0000 imm",
                fmt => "RS1,imm"},
    BT      => {iword => "$OPCODE{BRANCH} 0000 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BNE     => {iword => "$OPCODE{BRANCH} 0101 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BGTE    => {iword => "$OPCODE{BRANCH} 1010 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BGT     => {iword => "$OPCODE{BRANCH} 1011 RS1 RS2  imm",
                fmt => "RS1,RS2,imm"},
    BNEZ    => {iword => "$OPCODE{BRANCH} 0001 RS1 0000 imm",
                fmt => "RS1,imm"},
    BGTEZ   => {iword => "$OPCODE{BRANCH} 1110 RS1 0000 imm",
                fmt => "RS1,imm"},
    BGTZ    => {iword => "$OPCODE{BRANCH} 1111 RS1 0000 imm",
                fmt => "RS1,imm"},
    JAL     => {iword => "$OPCODE{JAL} 0000 RD  RS1 imm",
                fmt => "RD,imm(RS1)"}
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
my %PSEUDO_INSTRS = (
    BR      => {fmt => "imm"},
    NOT     => {fmt => "RD,RS"},
    BLE     => {fmt => "RS1,RS2,imm"},
    BGE     => {fmt => "RS1,RS2,imm"},
    CALL    => {fmt => "imm(RS1)"},
    RET     => {fmt => ""},
    JMP     => {fmt => "imm(RS1)"},
);
my %label;
my %name;
my %data;

{ ## BEGIN main scope block
    # Get command line params. Print usage if undefined
    my ($infile, $outfile) = @ARGV;
    if (not defined $infile or not defined $outfile) {
        print "Syntax: $0 infile outfile\n";
        exit;
    }
    parse_input($infile);
    if ($outfile eq "stdout") {
        $outfile = undef;
    }
    print "\n\n";
    build_memory($outfile);
} ## END main scope block

sub parse_input
{
    my ($infile) = @_;
    return if not defined $infile;
    print "Reading input file $infile...\n";
    open(my $fh, '<', $infile) or die "Couldn't open input file '$infile': $!\n";

    my $cur_word; # Keep track of what word to use for the next instruction

    # Initial pass through, set up labels
    while (my $line = <$fh>) {
        $line = clean($line);
        if ($line =~ /^;/ or $line =~ /^$/) { # comment or newline
            next;
        }
        elsif ($line =~ /^\./) { # special instruction (.ORIG, .WORD, .NAME)
            if ($line =~ /^.ORIG/) {
                my @tokens = split /\s+/, $line;
                if (!defined $tokens[1]) {
                    print "Error: no value provided for .ORIG\n";
                    next;
                }
                # Update current address to the number provided (interperated as hex)
                $cur_word = hex($tokens[1]) >> 2;
            }
            elsif ($line =~ /^.NAME/) {
                $line =~ s/^.NAME\s+//;
                my ($name, $address) = split /\s*=\s*/, $line;
                if (!defined $name or !defined $address) {
                    print "Error: invalid .NAME format\n";
                    next;
                }
                # Save the name defined by .NAME
                if ($address =~ /^0x/) {
                    $name{$name} = hex($address);
                }
                else {
                    $name{$name} = $address;
                }
            }
            else {
                next;
            }
        }
        elsif ($line =~ /^([a-zA-Z0-9]+):/) { # label
            $label{$1} = $cur_word;
        }
        else {
            $cur_word++;
        }
    }

    print "Names defined\n";
    print Dumper(\%name);

    print "Labels defined:\n";
    print Dumper(\%label);
    print "\n";

    # Rewind the file (close and reopen to reset line numbers)
    close($fh);
    open($fh, '<', $infile) or die "Couldn't open input file '$infile': $!\n";

    # Second pass through, generate instructions
    while (my $line = <$fh>) {
        $line = clean($line);
        if ($line =~ /^;/ or $line =~ /^$/) { # comment or newline
            next;
        }
        elsif ($line =~ /^\./) { # special instruction (.ORIG, .WORD, .NAME)
            if ($line =~ /^.ORIG/) {
                my @tokens = split /\s+/, $line;
                if (!defined $tokens[1]) {
                    print "Error: no value provided for .ORIG\n";
                    next;
                }
                # Update current address to the number provided (interperated as hex)
                $cur_word = hex($tokens[1]) >> 2;
            }
            elsif ($line =~ /^.WORD/) {
                $line =~ s/^.WORD\s+//;
                my $value;
                if ($line =~ /^(0x[0-9A-F]+)/) {
                    $value = hex($1);
                }
                elsif ($line =~ /^([0-9]+)$/) {
                    $value = $1;
                }
                elsif (exists $label{$line}) {
                    $value = $label{$line}
                } else {
                    print "Label '$line' not defined\n";
                    next;
                }
                $data{$cur_word} = $value;
            }
        }
        elsif ($line =~ /^[a-zA-Z0-9]+:/) { # label
            next;
        }
        else { # Regular instruction
            my $bin = parse_instruction($line);
            # TODO: handle if string represents multiple instructions
            if (defined $bin) {
                $data{$cur_word} = sprintf("%X", oct("0b$bin"));
                $cur_word++;
            }
        }
    }
}

# Returns binary string representing the instruction defined on the line
sub parse_instruction
{
    my ($line) = @_;
    my ($opcode, @tokens) = split /[\s,\(\)]+/, $line;

    # Print opcode and tokens for testing
    print "opcode: $opcode ";
    foreach my $token (@tokens) {
        print "token: $token; ";
    }
    print "\n";

    # Check if this is a pseudo instruction
    if (exists $PSEUDO_INSTRS{$opcode}) {
        # Check valid number of parameters
        my @fmt = split /[,\(\)]+/, $PSEUDO_INSTRS{$opcode}{fmt};
        if (scalar @tokens != scalar @fmt) {
            print "Invalid number of parameters for '$opcode' on line $.\n";
            return undef;
        }

        # Individual behaviour for each pseudo instruction
        # TODO: Translate to regular instruction
        if ($opcode eq 'BR') {
            #TODO
            return undef;
        }
        else {
            print "Pseudo opcode $opcode not implemented!\n";
            return undef;
        }
    }

    # Check if this is a valid opcode
    if (!exists $INSTR{$opcode}) {
        print "Invalid opcode on line $.: $opcode\n";
        return undef;
    }

    my $iword = $INSTR{$opcode}{iword};
    my @fmt = split /[,\(\)]+/, $INSTR{$opcode}{fmt};
    if (scalar @tokens != scalar @fmt) {
        print "Invalid number of parameters for '$opcode' on line $.. Expected ". scalar @fmt . "\n";
        return undef;
    }

    for (my $i = 0; $i < scalar @tokens; $i++) {
        my $bin = reg2bin($tokens[$i]);
        if (!defined $bin) {
            return undef;
        }
        $iword =~ s/$fmt[$i]/$bin/;
    }

    $iword =~ s/\s+//g;

    if ($iword =~ /^[01]+$/) { # Sanity check
        print "iword: $iword\n";
        return $iword;
    }

    print "iword2: $iword\n";
    return undef;
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
    for my $address (sort(keys %data)) {
        printf("%X : %X\n", $address, $data{$address});
    }
    print $fh "\nEND;\n";
}

sub clean
{
    my ($line) = @_;
    chomp $line;            # Remove trailing \n
    $line =~ s/^[\s\t]+//;  # Remove leading spaces and tabs
    $line =~ s/[\r\n]+$//;  # Remove trailing \r\n (windows newline)
    $line =~ s/;.*$//;      # Remove traling comment
    $line =~ s/\t/ /g;     # Change all tabs to spaces
    return $line;
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
