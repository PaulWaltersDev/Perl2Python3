#!/usr/bin/perl -w

package plpy_nonterminals;

#use strict;
use warnings;
use diagnostics;

my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my %shebang_header;
my @python_text = ();

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

sub nonterminals_arith_exp
{
  my ($line) = @_;
  if (my @items = $line =~ /^((^\s*)+\s*([\+\*\/-])\s*)+$/)
  {
    print "line = $line\n";
    print "items = @items\n";
    #my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    #return "@output";
  }
  return $line;

}

sub nonterminals_paranthesis
{
  my ($line) = @_;
  if ($line =~ /^\((.*)\)$/)
  {
    print "line 1 = $1\n";
    my $trans = plpy_engine::iterate_trans_functions($1);

    #print "trans = $trans\n";
    return "($trans)";
  }
  return $line;
}

sub nonterminals_not
{
  my ($line) = @_;
  if ($line =~ /^!(.*)$/)
  {
    my $trans = plpy_engine::iterate_trans_functions($1);
    #print $line."\n";
    #print "trans = $trans\n";
    return "not $trans";
  }
  return $line;
}

sub nonterminals_chomp
{
  my ($line) = @_;
  if ($line =~ /^chomp\s*\(+(.*)\)+$/)
  {
      return plpy_engine::iterate_trans_functions($1).".rstrip('\\n')";
  }
  return $line;
}

sub nonterminals_spaceship
{
  my ($line) = @_;
  if ($line =~ /^(.*)\s*<=>\s*(.*)$/)
  {
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "($a > $b) - ($a < $b)";
  }
  return $line;
}

1;
