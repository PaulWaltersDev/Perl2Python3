#!/usr/bin/perl -w
# put your demo script here

#Adapted from https://www.gossland.com/perlcourse/intro/examples

print "Please type in either heads or tails: ";

#The <STDIN> is the way to read keyboard input
$answer = <STDIN>;
chomp $answer;

while ( $answer ne "tails") {
	print "You typed not tails - Try typing tails\n";
	$answer = <STDIN>;
	chomp $answer;
}

print "Thanks, you chose $answer !\n";
print "Hit enter key to continue";

#This line is here to pause the script
#until you hit the carriage return
#but the input is never used for anything.
$temp = <STDIN>;

if ( $answer eq "tails" ) {
	print "TAILS! you WON!\n";
}
else
{
	print "HEADS?! you lost - Try again!\n";
}
