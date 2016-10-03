#!/usr/bin/perl -w

# plpy.pm
# Created by Paul Walters z5077446 for COMP9041 Assignment 1 Oct 2016

# This interpreter converts basic perl code to python 3
# It uses a recursive , regex-driven parsing method
# to call functions corresponding to terminal and non-terminal
# perl syntax

# For details of the trasnlation engine and functions see plpy_engine.p,,
# plpy_nonterminals.pm and plpy_terminals.pm

#use strict;
#use warnings;
#use diagnostics;

use FindBin;
use lib "$FindBin::Bin";

use plpy_engine;
use plpy_terminals;
use plpy_nonterminals;

my @shebang_header = ();	# used to retrieve header from plpy_nonterminals
my @python_text = ();		#Stores python code body as taken from plpy_engine

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
