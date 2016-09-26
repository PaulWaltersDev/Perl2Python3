#!/usr/bin/perl -w

package plpy_functions;

use strict;
use warnings;
use diagnostics;

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
  $line =~ s/(\$\w+)\s*<=>\s*(\$\w+)/cmp($1,$2)/g;
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

sub replace_if
{
  my ($line) = @_;
  $line =~ s/if\(+(.*)\)+\{*;*/if($1):/gi;
  return $line;
}

sub replace_closing_bracket
{
  my ($line) = @_;
  $line =~ s/\s*\}//gi;
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








1;
