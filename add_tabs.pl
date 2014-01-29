#!/usr/bin/perl

# Written by Dean Jenkins
# Copyright Mentor Graphics, Inc

# This program adds tabs into the 4_KernelCommitsToMerge.log
# so that it make it easier to import the information into
# a spreadsheet.

use strict;
use warnings;

my $version = "Version 1.0";

my $kernel_file = "4_KernelCommitsToMerge.log";
my $output_file = "5_CommitsToAnalyse.csv";

open(INPUT, $kernel_file) or die "Failed to open $kernel_file: $!\n";
open(OUTPUT, ">", $output_file) or die "Failed to open $output_file: $!\n";

print "$0: $version\n\n";
print "Adding tabs to $kernel_file\n";
print "Output file is $output_file\n\n";

my $num_entries = 0;

# Now walk through the kernel commits file
while (<INPUT>)
{
    my $rawline = $_;

    # get the subject line and ignore the commit ID
    (my $version, my $commit_id, my $subject) = $rawline =~ m/^(v.+)\s+(\w{40})\s+(.+)$/;

    if (defined $version and defined $commit_id and defined $subject)
    {
        $num_entries++;

        # add tabs
        print OUTPUT"$version\t$commit_id\t$subject\n";

    } else {
        print STDERR "WARNING: line ignored: \"$rawline\"";
    }
}

print "\nTotal number of commits is $num_entries\n\n";

close(INPUT);
close(OUTPUT);
