#!/usr/bin/perl -w

# plpy_engine.pm
# Created by Paul Walters z5077446

# Contains the recursive parsing function that calls functions for all
# terminal and non_terminals
# Also adds indentation and comments out all untranslatable lines

package plpy_engine;

use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

my $indent = 0; #adding global indent variable
my $ind_sep = "  "; 	# variable containing three spaces, used for indenting.

# all parsing/translation functions are iterated through as references
# stored in separate arrays for terminals and non-terminals

my @terminals_list = (
                        \&plpy_terminals::terminals_comment,
                        \&plpy_terminals::terminals_integer,
                        \&plpy_terminals::terminals_float,
                        \&plpy_terminals::terminals_variable,
                        \&plpy_terminals::terminals_whitespace,
                        \&plpy_terminals::terminals_regex_comp_operator,
                        \&plpy_terminals::terminals_arithmetic_operator,
                        \&plpy_terminals::terminals_bitwise_operator,
                        \&plpy_terminals::terminals_end_semicolon,
                        \&plpy_terminals::terminals_next,
                        \&plpy_terminals::terminals_last,
			\&plpy_terminals::terminals_and_or,
                        \&plpy_terminals::terminals_comp_operator,
                        \&plpy_terminals::terminals_stringarith_exp
);

my @nonterminals_list = (
                        \&plpy_nonterminals::header_shebang_perlpath,
                        \&plpy_nonterminals::misc_naked_opening_closing_bracket,
                        \&plpy_nonterminals::misc_stdin_while,
                        \&plpy_nonterminals::misc_stdin,
                        \&plpy_nonterminals::misc_double_curly_braces,
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
                        \&plpy_nonterminals::nonterminals_comp_eq,
                        \&plpy_nonterminals::nonterminals_comp_exp,
                        \&plpy_nonterminals::nonterminals_variable_assignment,
			\&plpy_nonterminals::nonterminals_and_or,
                        \&plpy_nonterminals::nonterminals_bitwise_exp,
                        \&plpy_nonterminals::nonterminals_arith_exp,
                        \&plpy_nonterminals::nonterminals_stringarith_exp,
                        \&plpy_nonterminals::nonterminals_string_equiv_exp
);

# Persistent flag, called from plpy_nonterminals.pm,
# to register that a line is not translatable
# If $unrecognised = 1, the line is commented out

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

# Takes the line from plpy.pl and calls the recursive tranbslate
# function
sub translate
{
  my ($line) = @_;
  unset_unrecognised();
  my ($indent) = plpy_nonterminals::get_indent();
  my ($translated) = iterate_trans_functions($line);

  $translated = "#".$translated if is_unrecognised();

  # Adds indentation and returns translated text

  if($translated)
  {
    return ("$ind_sep" x $indent).$translated;
  }
  else
  {
    return "";
  }
}

# Recursively calls all terminal and nonterminal functions
# and passes text to translated
# Also launched by nonterminal functions
# to return translated terminals and smaller nonterminals
sub iterate_trans_functions
{
  my ($line) = @_;

  #Attribution over text to determine is string is empty
  #http://stackoverflow.com/questions/2045644/what-is-the-proper-way-to-check-if-a-string-is-empty-in-perl
  return if(!(defined $line and length $line));
  $line =~ s/^\s+//g;   #Removes leading and trailing whitespace
  $line =~ s/\s+$//g;

  #print "line = ..$line..\n";

  foreach $trans_func(@terminals_list)
  {
    my $newline = &$trans_func($line);
    if ($line ne $newline)
    {
      # Note that all translated lines returned have at least one extra white space
      # This is because the function plpy_engine::iterate_trans_functions
      # compares the resultant python text to the original to determine
      # what is finished python and what is yet to be translated,
      # however there are some expressions (such as floats, integers, some operators etc.)
      # that are identical in perl and python. This is removed below.

      $newline =~ s/^\s+//g;
      $newline =~ s/\s+$//g;
      return $newline;
    }
  }

  foreach $trans_func(@nonterminals_list)
  {
    # A few nonterminal functions also use whitespace
    my $newline = &$trans_func($line);
    if ($line ne $newline)
    {
      $newline =~ s/^\s+//g;
      $newline =~ s/\s+$//g;
      #print "newline = ..$newline..\n";
      return $newline;
    }
  }

  #print "unrecognised = ..$newline..\n";
  set_unrecognised();

  return $line;
}

1;
