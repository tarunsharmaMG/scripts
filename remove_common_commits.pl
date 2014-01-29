#!/usr/bin/perl

# Written by Dean Jenkins
# Copyright Mentor Graphics, Inc

# This program remove duplicates that appear in the Gen3
# and upstream list of commits by ignoring the commit IDs.
# Only the git commit subject text is used for comparison.

# Note that the original commit IDs are not lost.

use strict;
use warnings;

my $version = "Version 1.0";

my $duplicate_file = "1_Gen3CommitsWithCommitID.log";
my $base_file = "2_UpstreamCommitsWithCommitID.log";
my $output_file = "3_CommitsToMerge.log";

open(DUPLICATE, $duplicate_file) or die "Failed to open $duplicate_file: $!\n";
open(BASE, $base_file) or die "Failed to open $base_file: $!\n";
open(OUTPUT, ">", $output_file) or die "Failed to open $base_file: $!\n";

print OUTPUT "$0: $version\n\n";
print OUTPUT "Removing common commits in $duplicate_file from $base_file\n";
print OUTPUT "Output file is $output_file\n";

my @base;

 # read base file into an array
@base = <BASE>;
close(BASE);

my $stripped = 0;
my $num_entries = scalar @base;

# Now walk through the possible duplicate file
while (<DUPLICATE>)
{
    my $index;
    my $rawline = $_;
    my $matches = 0;

    # get the subject line and ignore the commit ID
    (my $subject) = $rawline =~ m/^\w* (.*)$/;

    # can this subject be found in the base file ?
    for ($index = 0; $index < $num_entries; $index++)
    {
        # get the subject line and ignore the commit ID
        (my $base_subject) = $base[$index] =~ m/^\w* (.*)$/;

        if ($subject eq $base_subject)
        {
            # delete the matched commit
            splice(@base, $index, 1);

            $index--;
            $num_entries--;

            $matches++;
            $stripped++;
        }
    } 

    if ($matches > 1)
    {
        print STDERR "WARNING: matched $matches times: \"$subject\"";
    }
}

print OUTPUT "\nRemoved $stripped duplicate entries\n";
print OUTPUT "Total number of remaining commits is $num_entries\n\n";

# print the unmatched items
print OUTPUT @base;

close(DUPLICATE);
close(OUTPUT);
