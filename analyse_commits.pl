#!/usr/bin/perl

# Written by Dean Jenkins
# Copyright Mentor Graphics, Inc

# This script analyses 5_CommitsToAnalyse.csv by
# a) showing the files that changed

use strict;
use warnings;

my $version = "Version 1.0";

my $analyse_file = "5_CommitsToAnalyse.csv";
my $output_file = "6_AnalysedCommits.csv";

my $dirs_list = "list_of_dirs.txt";
my $includes_list = "list_of_includes.txt";

open(INPUT, $analyse_file) or die "Failed to open $analyse_file: $!\n";
open(OUTPUT, ">", $output_file) or die "Failed to open $output_file: $!\n";

print "$0: $version\n\n";

print "Please run this script in the kernel git tree from the kernel.org linux-stable repo.\n";
print "Required input files are: $dirs_list and $includes_list to restrict the git log output to relevant directories and includes\n\n";
print "Analysing $analyse_file\n";
print "Output file is $output_file\n\n";

if (!-e $dirs_list) {
    die "Error: $dirs_list not found\n";
}

if (!-e $includes_list) {
    die "Error: $includes_list not found\n";
}

my $num_entries = 0;
my $num_of_merge_entries = 0;

# Now walk through the commits file
while (<INPUT>)
{
    my $rawline = $_;

    # Input csv file format is <kernel version>\t<commit ID>\t<subject>

    # get all the fields
    (my $version, my $commit_id, my $subject) = $rawline =~ m/^(v.+)\t(\w{40})\t(.+)$/;

    if (defined $version and defined $commit_id and defined $subject)
    {
        my $got_a_merge = 0;

        $num_entries++;

        my @file_info = get_modified_files($commit_id);

        my $files_string = string_filenames(@file_info);

        if ($files_string eq "") {
            $files_string = "MERGE";
            $got_a_merge = 1;
        }

        print OUTPUT"$version\t$commit_id\t$subject\t$files_string\n";

        if ($got_a_merge == 1) {
            # try to get merge commits
            # check commit is a merge
            if ($subject =~ m/Merge/) {
                print OUTPUT "\t\tSTART OF MERGE INFORMATION\n";

                my $commit_dirs = "\`cat $dirs_list\` \`cat $includes_list\`";

                # get the merge commits
                my $git_command = "git log --pretty=oneline \$(git merge-base \$(git log -1 --pretty=format:%P ${commit_id}))..\$(git log -1 --pretty=format:%P ${commit_id} | cut -f 2 -d' ') -- $commit_dirs";
#                print "$git_command\n";

                open(PIPE, "$git_command |") or die "Failed to open git merge command\n";
                my @commit_info = <PIPE>;
                close(PIPE);

                foreach my $line (@commit_info) {
                    # strip tabs and newlines
                    $line =~ s/\t/ /g;
                    chomp($line);
#                    print "$line\n";

                    $num_of_merge_entries++;

                    # get all the fields
                    (my $merged_commit_id, my $merged_subject) = $line =~ m/^(\w{40})\s+(.+)$/;

                    if (defined $merged_commit_id and defined $merged_subject)
                    {
                        my @file_list = get_modified_files($merged_commit_id);
                        my $files = string_filenames(@file_list);
                        print OUTPUT "\t$merged_commit_id\t$merged_subject\t$files\n";

                    } else {
                      print STDERR "Failed to get commit ID and subject: \"$line\"\n";
                    }
               }

            } else {
                print STDERR "Was not a merge commit: \"$commit_id: $subject\"\n";
            }

            print OUTPUT "\t\tEND OF MERGE INFORMATION\n";
        }

    } else {
        print STDERR "WARNING: line ignored: \"$rawline\"";
    }
}

print "\nTotal number of commits is $num_entries (not including commits from merges)\n";
print "Total number of commits in merge commits is $num_of_merge_entries\n\n";

close(INPUT);
close(OUTPUT);

sub get_modified_files {

    my $local_commit_id = shift(@_);

#    print "called get_modified_file $local_commit_id\n";

    # try to find out which files changed
    open(PIPE, "git log --name-status --oneline $local_commit_id -1 |") or die "Failed to open git command\n";

    my @file_raw = <PIPE>;
    close(PIPE);

    # the first line contains the commit ID and subject so delete it
    splice(@file_raw, 0, 1);

    return @file_raw;
}

sub string_filenames {

    my @local_file_info = @_;

    my $num_of_files = scalar @local_file_info;
    my $line_count = 0;
    my $string = "";

    foreach my $line (@local_file_info) {
        # strip tabs and newlines
        $line =~ s/\t/ /g;
        chomp($line);
        $line_count++;
        if ($line_count < $num_of_files) {
            $string .= "$line, ";
        } else {
            $string .= "$line";
        }
    }

    return $string;
}
