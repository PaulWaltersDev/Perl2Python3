#!/usr/bin/perl -w
# put your demo script here
# demo02.pl Paul Walters z5077446


#taken from http://www.cse.unsw.edu.au/~cs2041/assignments/plpy/examples/4/odd0.pl

$number = 0;
while ($number >= 0) {
    print "Enter number:\n";
    $number = <STDIN>;
    if ($number >= 0) {
        if ($number % 2 == 0) {
            print "Even\n";
        } else {
            print "Odd\n";
        }
    }
}
print "Bye\n";
