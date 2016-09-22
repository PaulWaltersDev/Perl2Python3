#!/usr/bin/perl -w

# written by Paul Walters z5077446 Sep 2016
my $indent = 0; #adding global indent variable
while ($line = <>) {
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
	elsif ($line =~ /^\s*print\s*(\$([a-zA-Z][a-zA-Z0-9_]*)\s*([\*\/\+\-]))\s*"(.*)(\\n)+"[\s;]*$/)
	{
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
