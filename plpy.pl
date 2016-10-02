#!/usr/bin/perl -w

# Hash linking translation functions to regex keys used in searches

use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_functions;
use plpy_engine;
use plpy_terminals;
use plpy_nonterminals;
# written by Paul Walters z5077446 Sep 2016
my $indent = 0; #adding global indent variable
my @last_nested = ();	#lists most recent nesting
my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my @shebang_header = ();
my @python_text = ();

#print plpy_engine::iterate_trans_functions('$hello')."\n";
#print plpy_engine::iterate_trans_functions('@myhello')."\n";
#print plpy_engine::iterate_trans_functions('%myhello')."\n";
#print plpy_engine::iterate_trans_functions('78450067')."\n";
#print plpy_engine::iterate_trans_functions('-756')."\n";
#print plpy_engine::iterate_trans_functions('54.67')."\n";
#print plpy_engine::iterate_trans_functions('-45.67')."\n";
#print plpy_engine::iterate_trans_functions('679.67')."\n";
#print plpy_engine::iterate_trans_functions('-.04754')."\n";
#print plpy_engine::iterate_trans_functions("   ")."\n";
#print plpy_engine::iterate_trans_functions('||')."\n";
#print plpy_engine::iterate_trans_functions('&&')."\n";
#print plpy_engine::iterate_trans_functions('+')."\n";
#print plpy_engine::iterate_trans_functions('}')."\n";
#print plpy_engine::iterate_trans_functions('next')."\n";
#print plpy_engine::iterate_trans_functions('last')."\n";
#print plpy_engine::iterate_trans_functions(';')."\n";
#print plpy_engine::iterate_trans_functions('==')."\n";
#print plpy_engine::iterate_trans_functions('!=')."\n";
#print plpy_engine::iterate_trans_functions('!!')."\n";
#print plpy_engine::iterate_trans_functions('chomp($hello)')."\n";
#print plpy_engine::iterate_trans_functions('$left <=> $right')."\n";
#print plpy_engine::iterate_trans_functions('!($test)')."\n";
#print plpy_engine::iterate_trans_functions('($b)')."\n";
#print plpy_engine::iterate_trans_functions('$temp == 6.5')."\n";
#print plpy_engine::iterate_trans_functions('$a + 3 + (6 / 2)')."\n";
#print plpy_engine::iterate_trans_functions('4 ** 12')."\n";
#print plpy_engine::iterate_trans_functions('$a + x != 3 + chomp($r) + (12 % 2) = 12')."\n";
#print plpy_engine::iterate_trans_functions('$a >> x != 3 | chomp($r) + (12 ^ 2) << 12')."\n";
#print plpy_engine::iterate_trans_functions('if($x != 3){')."\n";
#print plpy_engine::iterate_trans_functions('elsif(chomp($s))')."\n";
#print plpy_engine::iterate_trans_functions('else{')."\n";
#print plpy_engine::iterate_trans_functions('while(chomp($x) + 4 = 3){')."\n";
#print plpy_engine::iterate_trans_functions('foreach $x (4..10){')."\n";
#print plpy_engine::iterate_trans_functions('$x++;')."\n";
#print plpy_engine::iterate_trans_functions('($x--)')."\n";
#print plpy_engine::iterate_trans_functions('for ($x = 1;$x < 153; $x ++ )')."\n";
#print plpy_engine::iterate_trans_functions('for ($x = 1546;$x > 153; $x -- )')."\n";
#print plpy_engine::iterate_trans_functions("print(\'dgijdoijdoijv oiodhviodhoih\n\');")."\n";
print plpy_engine::iterate_trans_functions('print("dgijdoijdoijv oiodh viod hoih\n");')."\n";
print plpy_engine::iterate_trans_functions('print("dgijdoijdoijv $1 $hello oio %hello2 dhv @hello3 iodhoih\n");')."\n";


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
