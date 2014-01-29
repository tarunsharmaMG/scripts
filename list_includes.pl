#!/usr/bin/perl

# Written by Dean Jenkins
# Copyright Mentor Graphics, Inc

# This program lists all includes that are directly called
# by the component.

# Use grep to create the raw_includes.txt file by doing
# grep -r -e "#include" * > raw_includes.txt
# in the component low-level directory

use strict;
use warnings;

my $version = "Version 1.0";

my $raw_includes = "raw_includes.txt";
my $output_file = "list_of_includes.txt";

my $path_prefix = "include/";

open(RAW, $raw_includes) or die "Failed to open $raw_includes: $!\n";
open(OUTPUT, ">", $output_file) or die "Failed to open $output_file: $!\n";

print "$0: $version\n\n";
print "Colasing includes from $raw_includes into $output_file\n\n";

my %include_hash;

# walk through the list of includes
while (<RAW>)
{
    my $rawline = $_;

#    print "RAW: $rawline\n";

    # get the include filename
    (my $include_file) = $rawline =~ m/<(.*)>/;

    # ignore #include "..." entries
    if (defined $include_file) {
#        print "$include_file\n";

        # add unique #include files 
        if (!exists $include_hash{$include_file}) {
            $include_hash{$include_file} = "${path_prefix}${include_file} "
        }
    }
}

foreach my $name (keys %include_hash) {
    print OUTPUT $include_hash{$name};
}

close(RAW);
close(OUTPUT);

