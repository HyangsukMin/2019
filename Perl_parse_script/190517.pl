#! /usr/bin/perl -s

##########################################################################################
# author: Claire
# date: 05/17/2019 
# input: $ARGV[0] => $ARGV[0].reduced
# confirmed by James.  Yell at James if not working.
##########################################################################################

if (@ARGV == 1){
    $input_file = $ARGV[0];
    open(INFILE,$input_file) || die "Cannot find '$input_file'\n";
    $output_file = "$input_file.reduced";
    open(OUTFILE,'>',$output_file) || die "Cannot generate '$output_file'\n";
} else {
    die "Syntax: $0 [input_filename] -> output file will be [input_filename].reduced\n";
}

################################################
# Variables
################################################
@names;
$SUBCKT_continued = 0;
%SUBCKT;
$path = 0 ;
$SUBCKT_mod;
$SUBCKT_pin;
$SUBCKT_name;
#################################################
# Parsing and Writing
#################################################
while ($line = <INFILE>){
    # Find SUBCKT and Parse name and pins
    if ($line =~ /.SUBCKT (\S+)/){
	if ($path % 500 ==0){
	    print "$path paths finished\n";
	}
	$path += 1;
	$SUBCKT_name = $1;
	$SUBCKT_mod = $line;
	$SUBCKT_mod =~ s/.SUBCKT $SUBCKT_name//;
	$SUBCKT_mod =~ s/\n//;
	$SUBCKT_pin = $SUBCKT_mod ;
	if (!grep(/^$SUBCKT_name$/, @names)){
	    push @names, $SUBCKT_name;
	    print OUTFILE "$line";
	    $SUBCKT_continued = 1;
	} 
	next;
    }
    # If Pin is defined, continued
    # If Pin is over 1 line, parsing it and append it.
    if (defined $SUBCKT_pin){
	if ($line =~ /^\+ /){
	    $SUBCKT_mod = $line;
	    $SUBCKT_mod =~ s/\+ //;
	    $SUBCKT_mod =~ s/\n//;
	    $SUBCKT_pin .= $SUBCKT_mod;
	}
	else {
	    if ($SUBCKT_continued == 1){
		$SUBCKT{$SUBCKT_name} = $SUBCKT_pin ;
		undef $SUBCKT_pin;
	    }
	    else {
		if ($SUBCKT_pin ne $SUBCKT{$SUBCKT_name}){
		    print OUTFILE "**UNQ Duplicated!! $SUBCKT_name $SUBCKT_pin\n";
		}
		undef $SUBCKT_pin;
		next;
	    }
	}
    }
    if ($SUBCKT_continued == 1){
	if ($line =~ /.ENDS/){
	    $SUBCKT_continued = 0;
	    print OUTFILE $line;
	}
	else {
	    print OUTFILE $line;
	}
	next;
    }
}
print "output file is \n$output_file\n";
