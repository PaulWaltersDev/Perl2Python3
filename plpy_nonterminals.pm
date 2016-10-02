#!/usr/bin/perl -w

package plpy_nonterminals;

#use strict;
use warnings;
use diagnostics;
use feature "state";

my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

local $implied_vars_flag = 0;
local %filehandles;

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

#http://perldoc.perl.org/perlsub.html#Persistent-Private-Variables
{
  my $indent = 1;

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
    my ($header_text) = @_;
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
  if ($line  =~ /^#!/)
  {
    add_header('#!/usr/local/bin/python3.5 -u');
    return " ";
  }
  return $line;

}


sub misc_naked_opening_closing_bracket
{
  my ($line) = @_;
  return "" if ($line  =~ /^{$/);
  if ($line =~ /^}$/)
  {
    reduce_indent();
    return " ";
  }

  return $line;
}

sub misc_stdin
{
  my ($line) = @_;
  if ($line =~ /^<STDIN>$/i)
  {
    add_header("import sys");
    return 'sys.stdin.readline()';
  }

  return $line;
}

sub misc_argv_list
{
  my ($line) = @_;
  if ($line eq '@ARGV')
  {
    add_header("import sys");
    return 'sys.argv[1:]';
  }

  return $line;
}

sub misc_exit
{
  my ($line) = @_;
  if ($line =~ /^$exit$/i)
  {
    add_header("import sys");
    return 'sys.exit()';
  }

  return $line;
}

sub misc_double_brackets
{
  my ($line) = @_;
  my $filevariable;
  if ($line =~ /^while\s*\((.*)\s*=\s*<>\s*\)\s*{?$/)
  {
    add_indent();
    add_header("import fileinput");
    $filevariable = plpy_engine::iterate_trans_functions($1);
    return "for $filevariable in fileinput.input():";
  }
  elsif ($line =~ /^while\s*\(\s*<>\s*\)\s*{?$/)
  {
    $implied_vars_flag = 1;
    $filevariable = "temp";
    return "for $filevariable in fileinput.input():";
  }

  return $line;
}

sub non_terminals_regex
{
  my ($line) = @_;
  my $filevariable;
  if ($line =~ m{//})
  {

  }
  elsif ($line =~ /^while\s*\(\s*<>\s*\)\s*{?$/)
  {

  }

  return $line;
}

sub nonterminals_split
{
  #http://perlmaven.com/perl-split
  #https://www.tutorialspoint.com/python3/string_split.htm
  my ($line) = @_;

  #http://www.perlfect.com/articles/regex.shtml
  if ($line =~ m{^split\s*/(.*)/\s*,(.+),?(.+)?$})
  {
    $line =~ s/^split\s*//g;
    $line =~ s/\///g;
    print "line = $line\n";
    my ($a, $b, $c) = split /,/, $line;
    $a =~ s\['"]\\g;
    if(defined $c)
    {
      ($b,$c) = map {plpy_engine::iterate_trans_functions($_)} ($b,$c);
      return "$b.split('$a',$c)";
    }
    else
    {
      $b = plpy_engine::iterate_trans_functions($b);
      return "$b.split('$a')";
    }
  }

  return $line;
}


sub nonterminals_join
{
  my ($line) = @_;
  if ($line =~ /^join\(['"](.*)['"],(.*)\)$/)
  {
    print "joinline = $line ... $1 .... $2\n";
    return "\"$1\".join(".plpy_engine::iterate_trans_functions($2).")";
  }

  return $line;
}

sub nonterminals_variable_assignment
{
  my ($line) = @_;
  if (@items = $line =~ /^(my|local|state)?([^=]+)=([^;]+);?$/)
  {
    my ($a,$b) = map {plpy_engine::iterate_trans_functions($_)} ($2,$3);
    return "$a = $b";
  }
  return $line;
}

sub nonterminals_comp_exp
{
  #print "hello_non_terminals comp_exp\n";
  my ($line) = @_;
  return $line if($line =~ /STDIN/);
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

sub nonterminals_stringarith_exp
{
  my ($line) = @_;
  if (my @items = $line =~ /^(.+)(\.|.=)(.+)$/)
  {
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;
}

sub nonterminals_string_equiv_exp
{
  my ($line) = @_;
  if (my @items = $line =~ /^(.+)\s+(eq|ne|lt|gt)\s+(.+)$/)
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
  if ($line =~ /^chomp\s*\(?([^;]*)\)?;?$/)
  {
    my $string = plpy_engine::iterate_trans_functions($1);
    return "$string = $string.rstrip()";
  }
  return $line;
}

sub nonterminals_if_elsif_else
{
  my ($line) = @_;
  if ($line =~ /^if\s*\((.*)\)\s*{?$/)
  {
      add_indent();
      return "if ".plpy_engine::iterate_trans_functions($1).":";
  }
  elsif ($line =~ /^elsif\s*\((.*)\)\s*{?$/)
  {
      add_indent();
      return "else if ".plpy_engine::iterate_trans_functions($1).":";
  }
  elsif ($line =~ /^else\s*{?$/)
  {
      add_indent();
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
  print "foreach = ......$line...\n";
  if ($line =~ /^foreach\s*(.*)\s*\((.*)\)\s*{?$/)
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
    return "for $a in range($b:".(1+$c)."):";
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
    print "for = ..$1....$2...\n";
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    print "for2 = $a .. $b\n";
    return "range($a:".(1 + $b).")";
  }
  return $line;
}

sub nonterminals_print
{
  my ($line) = @_;
  if ($line =~ /^print([^;]*);?$/)
  {
    my $linebreak = 0;
    my $string = $1;

    if($string =~ /\\n/)
    {
      $linebreak = 1;
      $string =~ s/(\\n|,?\s*"\\n")//g;
    }

    print "string = $string\n";
    my @strings = $string =~ /^(".+")?(\s*join\(.*\))?(,|\.)?([^.,]+)?(,|\.)?$/g;
    #my @strings = split /[,\.]/, $string;
    #print "strings = ".join(' : ',@strings)."\n";
    my @mapped_strings = map {plpy_engine::iterate_trans_functions($_)} (@strings);
    if($linebreak == 1)
    {
      return 'print('.join(' + ',@mapped_strings).')';
    }
    return 'print('.join(' + ',@mapped_strings).', end=\'\')';
  }
  return $line;
}

sub nonterminals_text_single_quotes
{
  my ($line) = @_;
  if ($line =~ /^'.*'$/)
  {
    return " $line ";
  }
  return $line;
}

sub nonterminals_text_with_variables
{
  my ($line) = @_;
  if ($line =~ /^"(.*)"$/)
  {
    my $string = $1;
    my @variables = ($string =~ /([\$@%]\w+)/g);
    #return $string;
    if (@variables)
		{
      $string =~ s/([\$@%]\w+)/%s/g;
      my @mapped_variables = map {plpy_engine::iterate_trans_functions($_)} (@variables);
			return "\"$string\" \% (".join(",",@mapped_variables).")";
		}
		else
		{
			return "$line ";
		}
  }
  return $line;
}

1;
