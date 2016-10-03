#!/usr/bin/perl -w

package plpy_terminals;

#use strict;
use warnings;
use diagnostics;

my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my %header;
my @python_text = ();

sub terminals_comment
{
  my ($line) = @_;
  return "$line " if ($line =~ /^#[^!]/);
  return $line;
}

sub terminals_integer
{
  my ($line) = @_;
  return "$1" if ($line =~ /^(-?\d+)$/);
  return $line;
}

sub terminals_float
{
  my ($line) = @_;
  return "$1" if ($line =~ /^(-?\d*\.\d+)$/);
  return $line;
}

sub terminals_variable
{
  my ($line) = @_;
  return "$1" if (($line =~ /^[\$@%]([a-zA-z][a-zA-Z0-9]*)$/)&&($line ne '@ARGV'));
  return $line;
}

sub terminals_whitespace
{
  my ($line) = @_;
  return "$1" if ($line =~ /^(\s+)$/);
  return $line;
}

sub terminals_or
{
  my ($line) = @_;
  return "or" if ($line =~ /^\|\|$/);
  return $line;
}

sub terminals_and
{
  my ($line) = @_;
  return "and" if ($line =~ /^\&\&$/);
  return $line;
}

sub terminals_arithmetic_operator
{
  my ($line) = @_;
  return $1 if ($line =~ /^(\*|\+|-|\/|\*\*|%)$/);
  return $line;
}

sub terminals_bitwise_operator
{
  my ($line) = @_;
  return $1 if ($line =~ /^(&|\||~|\^|>>|<<)$/);
  return $line;
}

sub terminals_stringarith_exp
{
  my ($line) = @_;
  if ($line eq ".")
  {
    return "+";
  }
  elsif ($line eq ".=")
  {
    return "+="
  }
  elsif ($line eq "eq")
  {
    return "=="
  }
  elsif ($line eq "ne")
  {
    return "!="
  }
  elsif ($line eq "lt")
  {
    return "<"
  }
  elsif ($line eq "gt")
  {
    return ">"
  }
  return $line;
}

sub terminals_regex_comp_operator
{
  my ($line) = @_;
  if($line eq "=~")
  {
    return "=";
  }
  elsif($line eq '!~')
  {
    return "!=";
  }

  return $line;
}

sub terminals_comp_operator
{
  my ($line) = @_;
  return $1 if ($line =~ /^(==|<|>|!=|>=|<=)$/);
  return $line;
}

sub terminals_end_semicolon
{
  my ($line) = @_;
  return "" if ($line =~ /^;$/);
  return $line;
}

sub terminals_next
{
  my ($line) = @_;
  return "continue" if ($line =~ /^next;?$/);
  return $line;
}

sub terminals_last
{
  my ($line) = @_;
  return "break" if ($line =~ /^last;?$/);
  return $line;
}

1;
