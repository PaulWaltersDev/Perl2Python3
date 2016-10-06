#!/usr/bin/perl -w
# put your demo script here
#test04.pl. Created by Paul Walters z5077446

foreach my $x (5..12)
{
  $y = $x * 4;
  print "x = $x and y = $y\n";
  if($x > 10)
  {
    last;
  }
}
