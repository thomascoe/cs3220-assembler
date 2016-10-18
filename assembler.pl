#!/usr/bin/perl -w
use strict;

## globals
# Size of the memory
my $DEPTH = 2048;           # Number of addresses (i.e. number of words)
my $WIDTH = 32;             # Number of bits per word
# Radixes in BIN, DEC, HEX, OCT, or UNS
my $ADDRESS_RADIX = "HEX";  
my $DATA_RADIX = "HEX";

{ ## BEGIN main scope block
    # Get command line params. Print usage if undefined
    my ($infile, $outfile) = @ARGV;
    if ((not defined $infile) or (not defined $outfile)) {
        print "Syntax: $0 infile outfile\n";
        exit;
    }
    parse_input($infile);
    build_memory($outfile);
} ## END main scope block

sub parse_input
{
    my ($infile) = @_;
    my $fh;
    return if not defined $infile;
    print "Reading input file $infile...\n";
    open($fh, '<', $infile) or die "Couldn't open input file '$infile': $!\n";
    
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
    
    print $fh "DEPTH = $DEPTH\n";
    print $fh "WIDTH = $WIDTH\n";
    print $fh "ADDRESS_RADIX = $ADDRESS_RADIX\n";
    print $fh "DATA_RADIX = $DATA_RADIX\n\n";
    print $fh "CONTENT\n";
    print $fh "BEGIN\n\n";
    # TODO: Print address content
    print $fh "\nEND;\n";
}
