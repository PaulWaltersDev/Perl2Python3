#!/usr/bin/perl -w

# written by Paul Walters z5077446 for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/assignments/plpy/

while ($line = <>) {
    if ($line =~ /^#!/ && $. == 1) {
    
        # translate #! line 
        
        print "#!/usr/local/bin/python3.5 -u";
    } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
    
        # Blank & comment lines can be passed unchanged
        
        print $line;
    } elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
        # Python's print adds a new-line character by default
        # so we need to delete it from the Perl print statement
        
        print "print(\"$1\")\n";
    } else {
        # Lines we can't translate are turned into comments
        
        print "#$line\n";
    }
}
