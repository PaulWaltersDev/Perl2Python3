#!/usr/bin/perl -w

# plpy_nonterminals.pm
# Created by Paul Walters z5077446

# Contains translation functions for basic perl syntax
# terminals

# Note that all translated lines returned have at least one extra white space
# This is because the function plpy_engine::iterate_trans_functions
# compares the resultant python text to the original to determine
# what is finished python and what is yet to be translated,
# however there are some expressions (such as floats, integers, some operators etc.)
# that are identical in perl and python. This is removed later in plpy_engine.

package plpy_terminals;

# blanked out for submission. They
# can be reintroduced at any time.

#use strict;
#use warnings;
#use diagnostics;

# Maintains support for existing comments
sub terminals_comment
{
  my ($line) = @_;
  return "$line " if ($line =~ /^#[^!]/);
  return $line;
}

sub terminals_integer
{
  my ($line) = @_;
  return "$1 " if ($line =~ /^(-?\d+)$/);
  return $line;
}

sub terminals_float
{
  my ($line) = @_;
  return "$1 " if ($line =~ /^(-?\d*\.\d+)$/);
  return $line;
}

sub terminals_variable
{
  my ($line) = @_;
  return "$1 " if (($line =~ /^[\$@%]([a-zA-z][a-zA-Z0-9_]*)$/)&&($line ne '@ARGV'));
  return $line;
}

sub terminals_whitespace
{
  my ($line) = @_;
  return "$1 " if ($line =~ /^(\s+)$/);
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
  return "$1 " if ($line =~ /^(\*|\+|-|\/|\*\*|%)$/);
  return $line;
}

sub terminals_bitwise_operator
{
  my ($line) = @_;
  return "$1 " if ($line =~ /^(&|\||~|\^|>>|<<)$/);
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
  elsif ($line eq "+=")
  {
    return "+= "
  }
  elsif ($line eq "-=")
  {
    return "-= "
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

sub terminals_and_or
{
  my ($line) = @_;
  if ($line =~ /^(and|or)$/)
  {
    return "$line ";
  }
  elsif ($line eq "&&")
  {
    return "and";
  }
  elsif ($line eq "||")
  {
    return "or";
  }
  return $line;
}

sub terminals_comp_operator
{
  my ($line) = @_;
  return "$1 " if ($line =~ /^(==|<|>|!=|>=|<=)$/);
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
