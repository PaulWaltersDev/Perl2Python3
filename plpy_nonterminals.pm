
#!/usr/bin/perl -w

# plpy_nonterminals.pm
# Created by Paul Walters z5077446

# Contains translation functions for all included perl syntax
# which are made up of but not in themselves terminals

# Also includes as an special case the shebang header functions
# and functions for dealing with curly braces, brackets, <STDIN> and <>

# Includes the counter for indentations and a flag
# to mark untranslatable perl lines
# Interacts recursively with plpy_engine.pm to receive and perl lines

# Note that all translated lines returned have at least one extra white space
# This is because the function plpy_engine::iterate_trans_functions
# compares the resultant python text to the original to determine
# what is finished python and what is yet to be translated,
# however there are some expressions (suhc as floats, integers, some operators etc.)
# that are identical in perl and python.


package plpy_nonterminals;

# blanked out for submission. They
# can be reintroduced at any time.
#use warnings;
#use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_terminals;
use plpy_nonterminals;

# Closure function to simulate a state variable
# to store the current indent.
#Attribution: http://perldoc.perl.org/perlsub.html#Persistent-Private-Variables
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


# Stores the current python headers (Python3.5 path, import statements)
# Stored as a hash to prevent duplication
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

# Misc Brackets, STDIN, <>, ARGV, exit, curly braces (for indents).

sub misc_naked_opening_closing_bracket
{
  my ($line) = @_;
  return "" if ($line  =~ /^{$/);
  if ($line =~ /^}$/)
  {
    reduce_indent(); # Currently the parser only supports
                      # indentation on closing brackets on thier own lines
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

sub misc_stdin_while
{
  my ($line) = @_;
  if ($line =~ /^while\s*\((\$[\w_]+)\s*=\s*<STDIN>\)\s*{?$/i)
  {
    add_indent();
    add_header("import sys");
    $a = plpy_engine::iterate_trans_functions($1);
    return "for $a in sys.stdin:";
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

# This has an known issue that was not fixable in time
# Currently not used.
sub misc_double_curly_braces
{
  my ($line) = @_;
  if ($line =~ /^}(.*){$/)
  {
    #reduce_indent();
    return plpy_engine::iterate_trans_functions($1);
  }

  return $line;
}

#Used to translate <>
# Note that support for implicit variables is not yet finished.
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
    $filevariable = "_";
    return "for $filevariable in fileinput.input():";
  }

  return $line;
}

# A the time of submission the list items and index nonterminals
# had known issues I could not fix in time
# Omitted unfortunately
sub nonterminals_list_items
{
  my ($line) = @_;

  # expects perl arrays of the format (x,y,z...)
  if($line =~ /^\(([\s\w\$%@"']+)(,([\s\w\$%@"']+)*)*\);?$/g)
  {
    $line =~ s/^\(//;
    $line =~ s/\)$//;
    my @items = split /,/,$line;
    my @translated_items = map {plpy_engine::iterate_trans_functions($_)} (@items);
    return "[".join(',',@translated_items)."]";
  }
}

# A the time of submission the list items and index nonterminals
# had known issues I could not fix in time
# Omitted unfortunately
sub nonterminals_list_index
{
  my ($line) = @_;

  if(my @items = $line =~ /^(\$\w*)\[(.*)\];?$/)
  {
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($a, $b);
    $b =~ s/(range[|])//g;
    return "$a[$b]";
  }
}

# Contains support for m// and s///, global or not global
sub nonterminals_regex
{
  my $regex_string;
  my $pattern;

  my ($line) = @_;

  if ($line =~ /^s\/(.*)\/(.*)\/(\w)?;?$/)
  {
    $pattern = $1;
    $pattern.='\n' if($pattern =~ /\.\*$/);

    if(defined $2)
    {
      $regex_string = "re.sub(r\'$pattern\',\'$2\',replacevar";
    }
    else
    {
      $regex_string = "re.sub(r\'$pattern\',\'\',replacevar";
    }

    if(defined $3)
    {

      if ($3 !~ /g/)
      {
        $regex_string .= ",count=1";
      }
    }
    else
    {
      $regex_string .= ",count=1";
    }

    return $regex_string.")";
  }
  elsif ($line =~ m{^/(.*)/(\w)?;?$})
  {
    $pattern = $1;
    $pattern.="\\n" if($pattern =~ /\.\*$/);  # Adds \n to a .* match
                                              # at the end of the pattern
    $regex_string = 're.match(r\''.$pattern.'\',replacevar';

    if(defined $2)
    {
      if($2 !~ /g/)
      {
        $regex_string .= ",count=1";
      }
    }
    else
    {
      $regex_string .= ",count=1";
    }

    return $regex_string.")";
  }

  return $line;
}

sub nonterminals_regex_match_expr
{
  my ($line) = @_;
  if (@strings = $line =~ /^(.*\S)\s*(=~|!~)\s*(\S.*)$/)
  {

    add_header("import re");
    my ($a, $b, $c) = map {plpy_engine::iterate_trans_functions($_)} ($1, $2, $3);

    $c =~ s/replacevar/$a/;
    return "$a $b $c";
  }
  return $line;
}

# Translates the Perl split function
sub nonterminals_split
{
  #Attribution: http://perlmaven.com/perl-split
  #Attribution: https://www.tutorialspoint.com/python3/string_split.htm
  my ($line) = @_;

  #Attribution: http://www.perlfect.com/articles/regex.shtml
  if ($line =~ m{^split\s*/(.*)/\s*,(.+),?(.+)?$})
  {
    $line =~ s/^split\s*//g;
    $line =~ s/\///g;

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

# Creates Python join function "x".join(variable)
sub nonterminals_join
{
  my ($line) = @_;
  if ($line =~ /^join\(['"](.*)['"],(.*)\)$/)
  {

    return "\"$1\".join(".plpy_engine::iterate_trans_functions($2).")";
  }

  return $line;
}

# Support assignment for non-terminals my/loca/state $/@/%x = (some expression)
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

# Comparison Operators
sub nonterminals_comp_eq
{

  my ($line) = @_;
  return $line if($line =~ /STDIN/);
  if (my @items = $line =~ /^(.+)(==|!=|>=|<=|\+=|-=)(.+)$/)
  {
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;
}

# GT and LT Comparison Operator formats
sub nonterminals_comp_exp
{

  my ($line) = @_;
  return $line if($line =~ /STDIN/);
  if (my @items = $line =~ /^(.+)(<|>)(.+)$/)
  {
    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;
}

# bitwise Operator formats
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

# Contains support for basic arithmetic expressions
sub nonterminals_arith_exp
{
  my ($line) = @_;
  if (my @items = $line =~ /^(.+)(\*|\+|-|\/|\*\*|%)(.+)$/)
  {

    my @output = map {plpy_engine::iterate_trans_functions($_)} @items;
    return join('',@output);
  }
  return $line;

}

# Used to hide enclosing ()
# from the arithmetic and equality functions
sub nonterminals_paranthesis
{
  my ($line) = @_;
  if ($line =~ /^\((.*)\)$/)
  {
    my $trans = plpy_engine::iterate_trans_functions($1);

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
    return "not $trans";
  }
  return $line;
}

# Note - no support yet for implicit variables
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
      return "elif ".plpy_engine::iterate_trans_functions($1).":";
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
    my $output = "while ".plpy_engine::iterate_trans_functions($1).":";
    $output =~ s/\s+=\s+/==/g;
    return $output;
  }
  return $line;
}

sub nonterminals_foreach
{
  my ($line) = @_;
  if ($line =~ /^foreach\s*(.*)\s*\((.*)\)\s*{?$/)
  {
    add_indent();
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "for $a in $b:";
  }
  return $line;
}

# Supports C-style for statements. Note that this has not yet beem
# fully tested
sub nonterminals_for
{
  my ($line) = @_;
  if ($line =~ /^for\s*\((.*)=(.*);(.*)<(.*);.*\+\+\s*\){?$/)
  {
    add_indent();
    my ($a, $b, $c) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2,$4);
    return "for $a in range($b,".(1+$c)."):";
  }
  elsif ($line =~ /^for\s*\((.*)=(.*);(.*)>(.*);.*\-\-\s*\){?$/)
  {
    add_indent();
    my ($a, $b, $c) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2,$4);
    return "for $a in range($b,$c,-1):";
  }
  return $line;
}


# For x++ and x--. Note that ++x and --x dont exist in Python
# thus these have bene treated like x++ and x--.
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

# For the <=> operator. Transcribed in Python3 to (a > b) - (a < b)
# Attribution: http://codegolf.stackexchange.com/questions/49778/how-can-i-use-cmpa-b-with-python3
# and https://docs.python.org/3.0/whatsnew/3.0.html
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

#Produces range(x, y) expressions.
sub nonterminals_range
{
  my ($line) = @_;
  if ($line =~ /^(.*)\.\.(.*)$/)
  {
    my ($a, $b) = map {plpy_engine::iterate_trans_functions($_)} ($1,$2);
    return "range($a,".(1 + $b).")";
  }
  return $line;
}

# The print and text functions below support "untouched" single quotes,
# Variable interpolation ( %s ) % $x etc.
# and mixtures of quoted text and expressions.
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

    my @strings = $string =~ /^(".+")?(\s*join\(.*\))?(,|\.)?([^.,]+)?(,|\.)?$/g;
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
			return "(\"$string\" \% (".join(",",@mapped_variables)."))";
		}
		else
		{
			return "$line ";
		}
  }
  return $line;
}

1;
