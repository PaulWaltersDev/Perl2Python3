#!/usr/bin/perl -w
#demo00.pl, Paul Walters z5077446

#Taken from http://www.cse.unsw.edu.au/~cs2041/assignments/plpy/examples/4/line_count.1.pl

$line = "";
$line_count = 0;
while ($line = <STDIN>) {
    $line_count++;
}
print "$line_count lines\n";
