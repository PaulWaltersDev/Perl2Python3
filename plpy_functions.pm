#!/usr/bin/perl -w

package plpy_functions;

use strict;
use warnings;
use diagnostics;

sub new
{
  my $class = shift;
  my $self = {};
  bless($self, $class);
  return $self;
}

sub replace_and_operator
{
  my ($line) = @_;
  $line =~ s/&&/ and /g;
  return $line;
}

sub replace_or_operator
{
  my ($line) = @_;
  $line =~ s/\|\|/ or /g;
  return $line;
}

sub replace_not_operator
{
  my ($line) = @_;
  $line =~ s/\!(.*)(\s*(\)|foreach|for|{|;))/ not\($1\) $2/g;
  return $line;
}

sub replace_spaceship_operator
{
  my ($line) = @_;
  $line =~ s/(\$\w+)\s*<=>\s*(\$\w+)/cmp($1,$2)/g;
  return $line;
}

sub replace_range_operator
{
  my ($line) = @_;
  $line =~ s/(\d+)\.\.(\d+)/length\(range\($1,$2\)\)/g;
  return $line;
}

sub replace_next
{
  my ($line) = @_;
  $line =~ s/next/continue/gi;
  return $line;
}

sub replace_last
{
  my ($line) = @_;
  $line =~ s/last/break/gi;
  return $line;
}

1;
