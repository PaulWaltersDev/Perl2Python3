#!/usr/bin/perl -w

# plpy.pm
# Created by Paul Walters z5077446

use strict;
use warnings;
use diagnostics;

use FindBin;
use lib "$FindBin::Bin";
use plpy_functions;
use plpy_engine;
use plpy_terminals;
use plpy_nonterminals;

#my $indent = 0; #adding global indent variable
#my @last_nested = ();	#lists most recent nesting
#my $ind_sep = "   "; 	# variable containing three spaces, used for indenting.

my @shebang_header = ();	# used to retrieve header from plpy_nonterminals
my @python_text = ();		#Stores python code body as taken from plpy_engine

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
#print plpy_engine::iterate_trans_functions('if($x == 3){')."\n";
#print plpy_engine::iterate_trans_functions('elsif(chomp($s))')."\n";
#print plpy_engine::iterate_trans_functions('else{')."\n";
#print plpy_engine::iterate_trans_functions('while(chomp($x) + 4 = 3){')."\n";
#print plpy_engine::iterate_trans_functions('foreach $x (4..10){')."\n";
#print plpy_engine::iterate_trans_functions('$x++;')."\n";
#print plpy_engine::iterate_trans_functions('($x--)')."\n";
#print plpy_engine::iterate_trans_functions('for ($x = 1;$x < 153; $x ++ )')."\n";
#print plpy_engine::iterate_trans_functions('for ($x = 1546;$x > 153; $x -- )')."\n";
#print plpy_engine::iterate_trans_functions("print(\'dgijdoijdoijv oiodhviodhoih\n\');")."\n";
#print plpy_engine::iterate_trans_functions('print "dgijdoijdoijv oiodh viod hoih\n";')."\n";
#print plpy_engine::iterate_trans_functions('print "dgijdoijdoijv $test", $i * $j."oiodh"."viod hoih\n";')."\n";
#print plpy_engine::iterate_trans_functions('print "dgijdoijdoijv $1 $hello oio %hello2 dhv @hello3 iodhoih";')."\n";
#print plpy_engine::iterate_trans_functions('$line1 .= $line2.line3')."\n";
#print plpy_engine::iterate_trans_functions('print "Give me cookie/n";')."\n";
#print plpy_engine::iterate_trans_functions('join(";",@texts)')."\n";
#print plpy_engine::iterate_trans_functions('my $i = 45 + $z')."\n";
#print plpy_engine::iterate_trans_functions('$i = <STDIN>')."\n";
#print plpy_engine::iterate_trans_functions('split /;/,$hello2,3')."\n";
#print plpy_engine::iterate_trans_functions('split /" + "/,@hello2')."\n";
#print plpy_engine::iterate_trans_functions('$text1.$text2 eq $text3 + "hello"')."\n";
#print plpy_engine::iterate_trans_functions('while ($line = <>) {')."\n";
#print plpy_engine::iterate_trans_functions('$list[$item] = $t + 5;')."\n";
#print plpy_engine::iterate_trans_functions('$list[5..23]')."\n";
#print plpy_engine::iterate_trans_functions('my @mylist = [3,4,"hello1",$var1,@list1]')."\n";
#print plpy_engine::iterate_trans_functions('$list[4,5,6,7]')."\n";

#Loops through all STDIN
while (my $line = <>) {

	chomp($line);

	my $translated_line = plpy_engine::translate($line);	#Passes in perl and retrieves python from plpy_engine
	push @python_text, $translated_line if((defined $translated_line)&&($translated_line ne ""));
}

my (%headers) = plpy_nonterminals::get_header();	# Gets Shebang/Python3.5 path and import statements

print join("\n", (sort keys %headers));
print("\n");
print join("\n",@python_text);
print "\n";
