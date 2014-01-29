#!/usr/bin/perl

# Written by Dean Jenkins
# Copyright Mentor Graphics, Inc

# This script idenfies the kernel version of a commit by
# by comparing the commit with commits in the kernel releases.

use strict;
use warnings;

my $version = "Version 1.0";

my $commits_file = "3_CommitsToMerge.log";
my $output_file = "4_KernelCommitsToMerge.log";

# The kernel commit files are created by doing
# git log --pretty=oneline --reverse v3.8..v3.9 > commits_v3.9.txt
# git log --pretty=oneline --reverse v3.9..v3.10 > commits_v3.10.txt
# git log --pretty=oneline --reverse v3.10..v3.11 > commits_v3.11.txt
# git log --pretty=oneline --reverse v3.11..v3.12 > commits_v3.12.txt

my @base_files = (["commits_v3.9.txt", "v3.9 "],
                  ["commits_v3.10.txt", "v3.10"],
                  ["commits_v3.11.txt", "v3.11"],
                  ["commits_v3.12.txt", "v3.12"]);

open(COMMITS, $commits_file) or die "Failed to open $commits_file: $!\n";
open(OUTPUT, ">", $output_file) or die "Failed to open $output_file: $!\n";

print OUTPUT "$0: $version\n\n";
print OUTPUT "Matching commits in $commits_file to kernel.org releases\n";
print OUTPUT "Output file is $output_file\n\n";

my @multi_base;

for my $base_index (0 .. $#base_files)
{
    open(BASE, $base_files[$base_index][0]) or die "Failed to open $base_files[$base_index][0]: $!\n";

    push(@multi_base, [<BASE>]);

    close(BASE);
}

# Now walk through our commits file
while (<COMMITS>)
{
    my $index;
    my $rawline = $_;
    my $matches = 0;

    # get the subject line and ignore the commit ID
    (my $subject) = $rawline =~ m/^\w* (.*)$/;

    if (defined $subject)
    {
        for my $base_index (0 .. $#multi_base)
        {
            # can this subject be found in the base file ?
            for $index (0 .. $#{$multi_base[$base_index]})
            {
                if ($rawline eq $multi_base[$base_index][$index])
                {
                    # matched entry
                    print OUTPUT $base_files[$base_index][1]." $rawline";

                    $matches++;
                }
            } 
        }

        if ($matches > 1)
        {
            print STDERR "WARNING: matched $matches times: \"$rawline\"";
        }
        elsif ($matches == 0)
        {
            print STDERR "WARNING: unmatched: \"$rawline\"";
        }
    }
}

close(COMMITS);
close(OUTPUT);
