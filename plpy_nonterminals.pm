#!/usr/bin/perl -w

package plpy_nonterminals;

#use strict;
use warnings;
use diagnostics;

my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

local %shebang_header;
my @python_text = ();

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

#http://perldoc.perl.org/perlsub.html#Persistent-Private-Variables
{
  my $indent = 0;

  sub add_indent
  {
    $indent++;
  }

  sub reduce_indent
  {
    $indent--;
  }

  sub get_indent
  {
      return $indent;
  }
}

{
  my %headers;

  sub add_header
  {
    my $header_text = @_;
    $headers{$header_text} = 1;
  }

  sub get_header
  {
    return %headers;
  }
}

sub header_shebang_perlpath
{
  my ($line) = @_;
  add_header('!/usr/local/bin/python3.5 -u') if ($line  =~ /^#!/);
  return $line;
}


sub misc_naked_opening_closing_bracket
{
  my ($line) = @_;
  return "" if ($line  =~ /^{$/);
  if ($line =~ /^}$/)
  {
    reduce_indent();
  }

  return $line;
}

sub nonterminals_comp_exp
{
  #print "hello_non_terminals comp_exp\n";
  my ($line) = @_;
  if (my @items = $line =~ /^(.+)(==|<|>|!=|>=|<=)(.+)$/)
  {
    print "line = $line\n";
    print "items = @items\n";
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;
}

sub nonterminals_bitwise_exp
{
  my ($line) = @_;
  if (my @items = $line =~ /^(.+)(&|\||~|\^|>>|<<)(.+)$/)
  {
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;
}

sub nonterminals_arith_exp
{
  my ($line) = @_;
  #if (my @items = $line =~ /^([^\s]+)\s*(\*|\+|-|\/|\*\*|%)(.+)$/)
  if (my @items = $line =~ /^(.+)(\*|\+|-|\/|\*\*|%)(.+)$/)
  {
    #print "line = $line\n";
    #print "items = ".join(',',@items)."\n";
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;

}

sub nonterminals_paranthesis
{
  my ($line) = @_;
  if ($line =~ /^\((.*)\)$/)
  {
    #print "line 1 = $1\n";
    my $trans = plpy_engine::iterate_trans_functions($1);

    #print "trans = $trans\n";
    return "($trans)";
  }
  return $line;
}

sub nonterminals_not
{
  my ($line) = @_;
  if (($line =~ /^!(.*)$/) && ($line !~ /^(!=|!!)$/))
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

sub nonterminals_if_elsif_else
{
  my ($line) = @_;
  if ($line =~ /^if\((.*)\){?$/)
  {
      add_indent();
      return "if ".plpy_engine::iterate_trans_functions($1).":";
  }
  elsif ($line =~ /^elsif\((.*)\){?$/)
  {
      return "else if ".plpy_engine::iterate_trans_functions($1).":";
  }
  elsif ($line =~ /^else{?$/)
  {
      return "else:";
  }
  return $line;
}

sub nonterminals_while
{
  my ($line) = @_;
  if ($line =~ /^while\s*\((.*)\)\s*{?$/)
  {
    add_indent();
    return "while ".plpy_engine::iterate_trans_functions($1).":";
  }
  return $line;
}

sub nonterminals_foreach
{
  my ($line) = @_;
  if ($line =~ /^foreach\s*(.*)\s\((.*)\){?$/)
  {
    add_indent();
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "for $a in $b:";
  }
  return $line;
}

sub nonterminals_for
{
  my ($line) = @_;
  if ($line =~ /^for\s*\((.*)=(.*);(.*)<(.*);.*\+\+\s*\){?$/)
  {
    add_indent();
    my ($a, $b, $c) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2,$4);
    return "for $a in range($b:$c):";
  }
  elsif ($line =~ /^for\s*\((.*)=(.*);(.*)>(.*);.*\-\-\s*\){?$/)
  {
    add_indent();
    my ($a, $b, $c) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2,$4);
    return "for $a in range($b:$c:-1):";
  }
  return $line;
}



sub nonterminals_increment_decrement
{
  my ($line) = @_;
  if (($line =~ /^(.*)\+\+;?$/) || ($line =~ /^--(.*);?$/))
  {
    my $a = plpy_engine::iterate_trans_functions($1);
    return "$a += 1";
  }
  elsif (($line =~ /^(.*)--;?$/) || ($line =~ /^--(.*);?$/))
  {
    my $a = plpy_engine::iterate_trans_functions($1);
    return "$a -= 1";
  }
  return $line;
}

sub nonterminals_spaceship
{
  my ($line) = @_;
  if ($line =~ /^(.*)\s*<=>\s*(.*)$/)
  {
    #print "spaceship= ".$1." ".$2."\n";
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "($a > $b) - ($a < $b)";
  }
  return $line;
}

sub nonterminals_range
{
  my ($line) = @_;
  if ($line =~ /^(.*)\.\.(.*)$/)
  {
    print "for = $1\n";
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "range($a:$b)";
  }
  return $line;
}

sub nonterminals_print_lines_single_quotes
{
  my ($line) = @_;
  if ($line =~ /^print\s*\(?'(.*)'\)?$/)
  {
    return 'print(".$1.")';
  }
  return $line;
}

sub nonterminals_print_with_variables
{
  my ($line) = @_;
  if ($line =~ /^print\s*\(?"(.*)(\\n)?"\)?\s*;?$/)
  {
    my $string = $1;
    my @variables = ($string =~ /([\$\@\%]\w+)/g);
    $string =~ s/[\$\@\%](\w+)/\$s/g;
    $string =~ s/\\n$//g;

    if (@variables)
		{
      my @mapped_variables = map {plpy_engine::iterate_trans_functions($_)} (@variables);
			return "print(\"$string\" \% (".join(",",@mapped_variables)."))";
		}
		else
		{
			return "print(\"$string\")";
		}
  }
  return $line;
}

1;
