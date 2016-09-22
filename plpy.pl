#!/usr/bin/perl -w

# Hash linking translation functions to regex keys used in searches

use strict;
use warnings;
use diagnostics;

# written by Paul Walters z5077446 Sep 2016
my $indent = 0; #adding global indent variable
while (my $line = <>) {
	
	#replace spaceship operator with cmp
	
	$line =~ s/(\$\w+)\s*<=>\s*(\$\w+)/cmp($1,$2)/g;
	
	# replace logical operators || && !
	
	$line =~ s/&&/ and /g;
	$line =~ s/\|\|/ or /g;
	$line =~ s/\!(.*)(\s*(\)|foreach|for|{|;))/ not\($1\) $2/g;
	
	
    	if ($line =~ /^#!/ && $. == 1)
	{
        	# translate #! line 
        
        	print "#!/usr/local/bin/python3.5 -u";
    	}
	elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/)
	{
        	# Blank & comment lines can be passed unchanged
        
        	print $line;
    	}
	elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/)
	{
		my $string = $1;
		my @variables = ($string =~ /[\$\@\%](\w+)/g);
		$string =~ s/[\$\@\%](\w+)/\$s/g;

		if (@variables)
		{
			print "print(\"$string\" \% (".join(",",@variables)."))\n";
		}
		else
		{
			print "print(\"$string\")\n";
		}
	}
	elsif ($line =~ /^\s*print.*[^"][\$\@\%]([a-zA-Z0-9_]+)/)
	{
		my @variables_and_ops = ($line =~ /[\$\@\%]([a-zA-Z0-9_]+\s*[\+\-\/\*]*)/g);
		#$1ine =~ s/\$[a-zA-Z0-9_]+/\$s/g;
		
		print "print(".join(" ",@variables_and_ops).")\n";
	}
	elsif ($line =~ /^\.*\$\w+/gi)
	{
		$line =~ s/(\$|;|(\{\{)|(\}\}))//g;
		print "$line\n";
	}
	else
	{
        	# Lines we can't translate are turned into comments
        
        	print "#$line\n";
	}
}