#!/usr/bin/perl -w

package plpy_engine;

#use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my %shebang_header;
my @python_text = ();

my @terminals_list = (
                        \&plpy_terminals::terminals_integer,
                        \&plpy_terminals::terminals_float,
                        \&plpy_terminals::terminals_variable,
                        \&plpy_terminals::terminals_whitespace,
                        \&plpy_terminals::terminals_or,
                        \&plpy_terminals::terminals_and,
                        \&plpy_terminals::terminals_arithmetic_operator,
                        \&plpy_terminals::terminals_end_semicolon,
                        \&plpy_terminals::terminals_next,
                        \&plpy_terminals::terminals_last,
                        \&plpy_terminals::terminals_naked_opening_closing_bracket,
                        \&plpy_terminals::terminals_shebang_perlpath
);

my @nonterminals_list = (
                        \&plpy_nonterminals::nonterminals_chomp,
                        \&plpy_nonterminals::nonterminals_spaceship,
                        \&plpy_nonterminals::nonterminals_not,
                        \&plpy_nonterminals::nonterminals_paranthesis,
                        \&plpy_nonterminals::nonterminals_arith_exp
);

sub iterate_trans_functions
{
  #print "in trans functions loop\n";
  my ($line) = @_;
  #$line =~ s/^\s+|\s+$//g;

  #print "@terminals_list";

  foreach $trans_func(@terminals_list)
  {
    $line = &$trans_func($line);
    #print "function &$trans_func iterating $line\n"
  }

  foreach $trans_func(@nonterminals_list)
  {
    $line = &$trans_func($line);
    #print "function &$trans_func iterating $line\n"
  }

  return $line;
}

1;
