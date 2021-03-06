#!/usr/bin/perl -w

package plpy_functions;

#use strict;
use warnings;
use diagnostics;

my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

#my %shebang_header = {};
my @python_text = ();

# Dispatch Table containing all translation functions
local %replace_functions = (
                            'and'             => \&replace_and_operator,
                            'or'              => \&replace_or_operator,
                            'not'             => \&replace_not_operator,
                            'spaceship'       => \&replace_spaceship_operator,
                            'range'           => \&replace_range_operator,
                            'next'            => \&replace_next,
                            'last'            => \&replace_last,
                            'chomp'           => \&replace_chomp,
                            'split'           => \&replace_split,
                            'join'            => \&replace_join,
                            'increments'      => \&replace_increments,
                            'if'              => \&replace_if,
#                            'foreach'         => \&replace_forch,
                            'for'             => \&replace_for,
                            'while'           => \&replace_while,
                            'naked_opening_closing_bracket' => \&replace_naked_opening_closing_bracket,
                            'comment'         => \&leave_comment,
                            'print'           => \&translate_print_statements,
                            'variable'        => \&translate_variable,
                            'untranslatable'  => \&translate_untranslatable_as_comments
                          );

sub new
{
  my $class = shift;
  my $self = {};
  bless($self, $class);
  return $self;
}

sub replace_and_operator
{
  my ($line) = @_;
  $line =~ s/&&/ and /g;
  return $line;
}

sub replace_or_operator
{
  my ($line) = @_;
  $line =~ s/\|\|/ or /g;
  return $line;
}

sub replace_not_operator
{
  my ($line) = @_;
  $line =~ s/\!(.*)(\s*(\)|foreach|for|{|;))/ not\($1\) $2/g;
  return $line;
}

sub replace_spaceship_operator
{
  my ($line) = @_;
  $line =~ s/(\$\w+)\s*<=>\s*(\$\w+)/\($1 > \$2) \- \($1 < $2\)/g;
  return $line;
}

sub replace_range_operator
{
  my ($line) = @_;
  $line =~ s/(\d+)\.\.(\d+)/length\(range\($1,$2\)\)/g;
  return $line;
}

sub replace_next
{
  my ($line) = @_;
  $line =~ s/next/continue/gi;
  return $line;
}

sub replace_last
{
  my ($line) = @_;
  $line =~ s/last/break/gi;
  return $line;
}

sub replace_chomp
{
  # taken from http://stackoverflow.com/questions/275018/how-can-i-remove-chomp-a-newline-in-python
  my ($line) = @_;
  $line =~ s/chomp\s*\(+(.*)\)+;&/$1\.rstrip\('\n'\)/gi;
  return $line;
}

sub replace_split
{
  my ($line) = @_;
  $line =~ s/split\s*\/(.*)\/,([\$a-zA-Z0-9_]+);/$1\.split\($2)/gi;
  return $line;
}

sub replace_join
{
  my ($line) = @_;
  $line =~ s/join\s*\(+"(.*)"\)+,(.*)\)+;&/"$1"\.join\($2\)/gi;
  return $line;
}

sub replace_increments
{
  my ($line) = @_;
  $line =~ s/^\s*([^\s])+\s*\+\+/$1 \+= 1/gi;
  $line =~ s/^\s*([^\s])+\s*--/$1 -= 1/gi;
  return $line;
}

sub replace_variable
{
  my ($line) = @_;
  $line =~ s/[\$\@\%]([a-zA-z0-9]+)/$1/g;
  return $line;
}

sub replace_if
{
  my ($line) = @_;
  $line =~ s/if\(+(.*)\)+\{*;*/if($1):/gi;
  return $line;
}

sub replace_stdin
{
  my ($line) = @_;
  if(($line) !~ /<STDIN>/ || ($line) !~ /<>/)
  {
    return $line;
  }

  $shebang_header{'sys'} = 'import sys';

  if($line =~ /while\s\((.*)=\s*<STDIN>\)/gi)
  {
    return "for $1 in open(sys.stdin):";
  }
  return $line;
}

sub replace_foreach
{
    my ($line) = @_;
    $line =~ s/foreach\s*(.*)\s*\((.*)\)\s*\{*;*/for $1 \($2\):/gi;
    return $line;
}

#sub replace_for
#{
#  my ($line) = @_;
#  $line =~ s/for\s*\((.*)\s*=\s*(.*);(.*)\s*[>=<]+\s*(.*);(.*)++\)\s*\{*;*/for $1 in range\($2,$3\):/gi;
#  return $line;
#}

sub replace_while
{
  my ($line) = @_;
  $line =~ s/while\s*\((.*)\)\s*\{*;*/while $1:/gi;
  return $line;
}

sub replace_naked_opening_closing_bracket
{
  my ($line) = @_;
  $line =~ s/^\s*[\{\}]&//gi;
  return $line;
}

sub add_python_path
{
  my ($line) = @_;
  if ($line =~ /^#!/ && $. == 1)
	{
        	return "#!/usr/local/bin/python3.5 -u";
  }
}

sub leave_comment
{
  my ($line) = @_;
  if ($line =~ /^\s*#/ || $line =~ /^\s*$/)
	{
        	return $line;
  }
}

sub translate_print_statements
{
  my ($line) = @_;
  if ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/)
  {
    my $string = $1;
    my @variables = ($string =~ /[\$\@\%](\w+)/g);
    $string =~ s/[\$\@\%](\w+)/\$s/g;

    if (@variables)
    {
      return "print(\"$string\" \% (".join(",",@variables)."))";
    }
    else
    {
      return "print(\"$string\")";
    }
  }
  elsif ($line =~ /^\s*print.*[^"][\$\@\%]([a-zA-Z0-9_]+)/)
  {
    my @variables_and_ops = ($line =~ /[\$\@\%]([a-zA-Z0-9_]+\s*[\+\-\/\*]*)/g);
    #$1ine =~ s/\$[a-zA-Z0-9_]+/\$s/g;

    return "print(".join(" ",@variables_and_ops).")";
  }
}

sub translate_variable
{
  my ($line) = @_;
  if($line =~ /^\.*\$\w+/gi)
  {
    $line =~ s/(\$|;|(\{\{)|(\}\}))//g;
    return "$line";
  }
}

sub translate_untranslatable_as_comments
{
  my ($line) = @_;
  return "#$line";
}

sub recursive_parse
{
  my ($line) = @_;

  # Attribution: See http://stackoverflow.com/questions/1915616/how-can-i-elegantly-call-a-perl-subroutine-whose-name-is-held-in-a-variable
  foreach $function (sort keys %replace_functions)
  {
    $line = $replace_functions{$function}->($line);
  }
}





1;
