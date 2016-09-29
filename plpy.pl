#!/usr/bin/perl -w

# Hash linking translation functions to regex keys used in searches

use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_functions;
use plpy_terminals;
# written by Paul Walters z5077446 Sep 2016
my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my @shebang_header = ();
my @python_text = ();

print plpy_terminals::terminals_variable('$hello')."\n";
print plpy_terminals::terminals_variable('@myhello')."\n";
print plpy_terminals::terminals_variable('%myhello')."\n";
print plpy_terminals::terminals_whitespace("   ")."\n";
print plpy_terminals::terminals_or('||')."\n";
print plpy_terminals::terminals_and('&&')."\n";
print plpy_terminals::terminals_arithmetic_operator('+')."\n";
print plpy_terminals::terminals_end_semicolon('}')."\n";
print plpy_terminals::terminals_next('next')."\n";
print plpy_terminals::terminals_last('last')."\n";
print plpy_terminals::terminals_last(';')."\n";

while (my $line = <>) {

	chomp($line);


	#my $plpy_functions = plpy_functions->new();

	$line = plpy_functions::replace_and_operator($line);
	$line = plpy_functions::replace_or_operator($line);
	$line = plpy_functions::replace_not_operator($line);
	$line = plpy_functions::replace_range_operator($line);
	$line = plpy_functions::replace_spaceship_operator($line);

	$line = plpy_functions::replace_next($line);
	$line = plpy_functions::replace_last($line);

	#replace spaceship operator with cmp

	#$line =~ s/(\$\w+)\s*<=>\s*(\$\w+)/cmp($1,$2)/g;

	# replace logical operators || && !

	#$line =~ s/&&/ and /g;
	#$line =~ s/\|\|/ or /g;
	#$line =~ s/\!(.*)(\s*(\)|foreach|for|{|;))/ not\($1\) $2/g;


  if ($line =~ /^#!/ && $. == 1)
	{
        	# translate #! line

        	push @shebang_header, "#!/usr/local/bin/python3.5 -u";
  }
	elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/)
	{
        	# Blank & comment lines can be passed unchanged

        	push @python_text, $line;
    	}
	elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/)
	{
		my $string = $1;
		my @variables = ($string =~ /[\$\@\%](\w+)/g);
		$string =~ s/[\$\@\%](\w+)/\$s/g;

		if (@variables)
		{
			push @python_text, "print(\"$string\" \% (".join(",",@variables)."))";
		}
		else
		{
			push @python_text, "print(\"$string\")";
		}
	}
	elsif ($line =~ /^\s*print.*[^"][\$\@\%]([a-zA-Z0-9_]+)/)
	{
		my @variables_and_ops = ($line =~ /[\$\@\%]([a-zA-Z0-9_]+\s*[\+\-\/\*]*)/g);
		#$1ine =~ s/\$[a-zA-Z0-9_]+/\$s/g;

		push @python_text, "print(".join(" ",@variables_and_ops).")";
	}
	elsif ($line =~ /^\.*\$\w+/gi)
	{
		$line =~ s/(\$|;|(\{\{)|(\}\}))//g;
		push @python_text, "$line";
	}
	else
	{
        	# Lines we can't translate are turned into comments

        	push @python_text, "#$line";
	}
}
print join("\n",@shebang_header);
print("\n\n");
print join("\n",@python_text);
print "\n";
