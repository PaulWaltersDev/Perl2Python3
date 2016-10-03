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
my $ind_sep = "  "; 	# variable containing three spaces, used for indenting.

my %shebang_header;
my @python_text = ();

my @terminals_list = (
                        \&plpy_terminals::terminals_comment,
                        \&plpy_terminals::terminals_integer,
                        \&plpy_terminals::terminals_float,
                        \&plpy_terminals::terminals_variable,
                        \&plpy_terminals::terminals_whitespace,
                        \&plpy_terminals::terminals_or,
                        \&plpy_terminals::terminals_and,
                        \&plpy_terminals::terminals_regex_comp_operator,
                        \&plpy_terminals::terminals_arithmetic_operator,
                        \&plpy_terminals::terminals_bitwise_operator,
                        \&plpy_terminals::terminals_end_semicolon,
                        \&plpy_terminals::terminals_next,
                        \&plpy_terminals::terminals_last,
                        \&plpy_terminals::terminals_comp_operator,
                        \&plpy_terminals::terminals_stringarith_exp
);

my @nonterminals_list = (
                        \&plpy_nonterminals::header_shebang_perlpath,
                        \&plpy_nonterminals::misc_naked_opening_closing_bracket,
                        \&plpy_nonterminals::misc_stdin,
                        \&plpy_nonterminals::misc_double_brackets,
                        \&plpy_nonterminals::misc_argv_list,
                        \&plpy_nonterminals::nonterminals_regex,
                        \&plpy_nonterminals::nonterminals_print,
                        \&plpy_nonterminals::nonterminals_text_single_quotes,
                        \&plpy_nonterminals::nonterminals_text_with_variables,
                        \&plpy_nonterminals::nonterminals_split,
                        \&plpy_nonterminals::nonterminals_join,
                        \&plpy_nonterminals::nonterminals_if_elsif_else,
                        \&plpy_nonterminals::nonterminals_for,
                        \&plpy_nonterminals::nonterminals_foreach,
                        \&plpy_nonterminals::nonterminals_while,
                        \&plpy_nonterminals::nonterminals_chomp,
                        \&plpy_nonterminals::nonterminals_spaceship,
                        \&plpy_nonterminals::nonterminals_not,
                        \&plpy_nonterminals::nonterminals_increment_decrement,
                        \&plpy_nonterminals::nonterminals_paranthesis,
                        \&plpy_nonterminals::nonterminals_range,
                        \&plpy_nonterminals::nonterminals_regex_match_expr,
                        \&plpy_nonterminals::nonterminals_comp_exp,
                        \&plpy_nonterminals::nonterminals_variable_assignment,
                        \&plpy_nonterminals::nonterminals_bitwise_exp,
                        \&plpy_nonterminals::nonterminals_arith_exp,
                        \&plpy_nonterminals::nonterminals_stringarith_exp,
                        \&plpy_nonterminals::nonterminals_string_equiv_exp
);

{
  my $unrecognised = 0;

  sub set_unrecognised
  {
    $unrecognised = 1;
  }

  sub unset_unrecognised
  {
    $unrecognised = 0;
  }

  sub is_unrecognised
  {
    return $unrecognised;
  }
}

sub translate
{
  my ($line) = @_;
  unset_unrecognised();
  my ($indent) = plpy_nonterminals::get_indent();
  my ($translated) = iterate_trans_functions($line);

  $translated = "#".$translated if is_unrecognised();

  if($translated)
  {
    return ("$ind_sep" x $indent).$translated;
  }
  else
  {
    return "";
  }
}

sub iterate_trans_functions
{
  #print "in trans functions loop\n";
  my ($line) = @_;

  #http://stackoverflow.com/questions/2045644/what-is-the-proper-way-to-check-if-a-string-is-empty-in-perl
  return if(!(defined $line and length $line));
  $line =~ s/^\s+//g;
  $line =~ s/\s+$//g;
  #$line =~ s/^\s+(.*)\s+$//g;
  #print "Caller = ".(caller(1))[3]."\n";
  #print "current line = $line\n";
  #print "indent = ".plpy_nonterminals::get_indent();

  #print "@terminals_list";

  foreach $trans_func(@terminals_list)
  {
    my $newline = &$trans_func($line);
    return $newline if ((!$newline)||($line ne $newline));
    #print "function &$trans_func iterating $line\n"
  }

  foreach $trans_func(@nonterminals_list)
  {
    my $newline = &$trans_func($line);
    return $newline if ($line ne $newline);
    #print "function &$trans_func iterating $line\n"
  }

  set_unrecognised();

  return $line;
}

1;
