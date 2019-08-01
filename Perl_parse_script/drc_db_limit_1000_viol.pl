#! /usr/bin/perl -s

##########################################################################################
# author: claire
# date: 03/20/2019
# input: $ARGV[0] => $ARGV[0].summary
##########################################################################################

if (@ARGV == 1){
    $input_file = $ARGV[0];
    open(INFILE,$input_file) || die "Cannot find '$input_file'\n";
    $output_file = "$input_file.summary";
    open(OUTFILE,'>',$output_file) || die "Cannot generate '$output_file'\n";
} else {
    die "Syntax: $0 [input_filename] -> output file will be [input_filename].summary\n";
}

#Variables
$path = 0; 
$write = 1;
#$continue_check;
#@array;


#parse and print
while ($line = <INFILE>){
    # Find DRC Violation Name (except first one, they are special cases.)
    if ($line =~/^GR/ or $line =~ /^DENSITY_RDBS/ or $line=~/^NET_AREA/ or $line=~/DFM_RDBMS/){ 
	if ($path % 100 == 0){                 
	    print "$path paths finished\n";
	}           
	$path +=1 ;                     
	$write = 0;                     
	$continue_check = 1;             
	print OUTFILE "$line";
	next ;
    }
    # Set per DRC violation limit 1000
    if ($continue_check ==1){
	@array = split(/\s/,$line);
	if ($array[0] <= 1000){
	    print OUTFILE "@array\n";
	} else {
	    $array[0] = 1000;
	    $array[1] = 1000;
	    print OUTFILE "@array\n";
	}
	$continue_check = 0;
	$write = 1;
	next ;
    }
    # Print until find new DRC Violation name
    if ( $write == 1 ){
	if ($line=~/^[pe] (\d+) \d+/ and $1 > 1000){
	    $write = 0;
	} else {
	    print OUTFILE "$line";
	}
	next;
    }
    
}
print "Total $path paths finished\n";
