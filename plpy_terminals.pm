#!/usr/bin/perl -w

package plpy_terminals;

#use strict;
use warnings;
use diagnostics;

my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my %shebang_header;
my @python_text = ();


sub terminals_variable
{
  my ($line) = @_;
  return "$1" if ($line =~ /[\$@%]([a-zA-z][a-zA-Z0-9]+)/);
}

sub terminals_whitespace
{
  my ($line) = @_;
  return $1 if ($line =~ /(\s+)/);
}

sub terminals_or
{
  my ($line) = @_;
  return "or" if ($line =~ /\|\|/);
}

sub terminals_and
{
  my ($line) = @_;
  return "and" if ($line =~ /\&\&/);
}

sub terminals_arithmetic_operator
{
  my ($line) = @_;
  return $1 if ($line =~ /((\*|\+|-|\/)?)/);
}

sub terminals_end_semicolon
{
  my ($line) = @_;
  return "" if ($line =~ /;&/);
}

sub terminals_next
{
  my ($line) = @_;
  return "continue" if ($line =~ /next/);
}

sub terminals_last
{
  my ($line) = @_;
  return "break" if ($line =~ /last/);
}

sub terminals_naked_opening_closing_bracket
{
  my ($line) = @_;
  return "" if ($line  =~ /[{}]?/);
}

sub terrminals_shebang_perlpath
{
  my ($line) = @_;
  return '!/usr/local/bin/python3.5 -u' if ($line  =~ /^!#/);
}

1;
