#!/usr/bin/perl -w
# put your demo script here

#test001.pl. Created by Paul Walters z5077446

#use strict;
use warnings;
use diagnostics;

$total = 0;
$total_string = "";

while($i = <STDIN>)
{
  chomp($i);
  if($i eq "x")
  {
    last;
  }
  $total += $i;
  $total_string .= $i;
}

print "total = $total\n";
print "total_string = $total_string\n";
