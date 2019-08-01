#! /usr/bin/perl -s

##########################################################################################
# author: Claire
# date: 06/18/2019
# input: $ARGV[0] => $ARGV[0].box
##########################################################################################

if (@ARGV == 1){
    $input_file = $ARGV[0];
    open(INFILE,$input_file) || die "Cannot find '$input_file'\n";
    $output_file = "$input_file.box";
    open(OUTFILE,'>',$output_file) || die "Cannot generate '$output_file'\n";
} else {
    die "Syntax: $0 [input_filename] -> output file will be [input_filename].box\n";
}

####################
# Package
####################
use Encode 'encode';

#####################
# Customize Variable
#####################
$title = 'dragonfly';         # Block name of Chip name  string
@SQUARE = qw/0 380 400 950/;  # Set the sqaure           array

####################
# Variable
####################
#@SQUARE2 ;               # Save x1 y1 x2 y2                                         array
#@SAVE;                   # Save the line that pass the rule                         array
$continued_print = 0;    # Continue print or not                                    0|1  #default = 0
$continued_N_of_Vio =0;  # Find the specific line that comes after violation name   0|1  #default = 0
$continued_compare =0 ;  # Continue compare with rule or not                        0|1  #default = 0
$VIO_2 = 0 ;             # of violations that pass the rule                         integer
$BYTE = 0 ;              # Calculate the byte for the file                          integer
#$MOD_POINT ;            # Save the point that we need to modify                    integer  
#$HEADER ;               # Save the line that we need to modify                     string
#$DEVIDER ;              

###################
# Function
###################
sub print_out_1 {   # Print out the variable and calculate the byte of the line
    print OUTFILE $line;
    $BYTE += length(encode('UTF-8',$line));
}
sub print_out_2 {   # Print out the array and calculate the byte of the array
    print OUTFILE @SAVE;
    $x = join("",@SAVE); # change array to string
    $BYTE += length(encode('UTF-8',$x));
    undef $x;
}

####################
# Parsing
####################
while ($line = <INFILE>){
    # Find the title(block of chip) 
    if ($line =~ /$title /){
	# If there is devider, find it
	if ($line =~ /$title (\d+)/){
	    $DEVIDER = $1;
	}
	&print_out_1;
	next;
    }
    # Find the violation name
    if ($line =~ /^[A-Z]{2,}\S+$/){
	# If it is not the 1st, change the # of violation
	if (defined $HEADER){
	    seek(OUTFILE,$MOD_POINT,0);
	    $HEADER =~ s/^$VIO_1 $VIO_1/$VIO_2 $VIO_2/;
	    $HEADER =~ s/\n//;
	    print OUTFILE $HEADER;
	    seek(OUTFILE,0,2);
	    undef $MOD_POINT; undef $HEADER;
	    $VIO_2 = 0 ;
	}
	&print_out_1;
	$continued_N_of_Vio = 1;
	next;
    }
    # Find the # of violations 
    if ($continued_N_of_Vio == 1 and $line =~ /(\d+) (\d+) \d+ \w+/){
	$VIO_1 = $1;
	$MOD_POINT = $BYTE ;
	$HEADER = $line;
	&print_out_1;
	$continued_N_of_Vio = 0 ;
	$continued_print = 1;
	next;
    }
    # Find the violation mark starting point
    if ($line =~ /^[pe] \d+ \d+$/){
	undef @SAVE;
	push @SAVE, "$line";
	$continued_print = 0 ;
	$continued_compare = 1 ;
	next;
    }
    # See if the violation is inside the sqaure
     if ($continued_compare == 1 and $line =~ /\d+ \d+/ ){
	 push @SAVE, "$line";

	 @SQUARE2 = split(/\s+/,$line);
	 @SQUARE2 = map {$_ / $DEVIDER} @SQUARE2;
	 
	 # For the line or square
	 if (defined $SQUARE2[2]) {
	     if (($SQUARE2[0] > $SQUARE[0]) and ($SQUARE2[1] > $SQUARE[1]) and ($SQUARE2[0] < $SQUARE[2]) and ($SQUARE2[1] < $SQUARE[3])){
		 $VIO_2 += 1;
		 $continued_print = 1;
		 $continued_compare = 0;
		 &print_out_2;
		 undef @SAVE;

	     } elsif (($SQUARE2[2] > $SQUARE[0]) and ($SQUARE2[3] > $SQUARE[1]) and ($SQUARE2[2] < $SQUARE[2]) and ($SQUARE2[3] < $SQUARE[3])){
		 $VIO_2 += 1;
		 $continued_print = 1;
		 $continued_compare = 0;
		 &print_out_2;
		 undef @SAVE;
	     }
	 # For the dot
	 } else {
	     if (($SQUARE2[0] > $SQUARE[0]) and ($SQUARE2[0] < $SQUARE[2]) and ($SQUARE2[1] > $SQUARE[1]) and ($SQUARE2[1] < $SQUARE[3])){
		 $VIO_2 += 1;
		 $continued_print = 1;
		 $continued_compare = 0;
		 &print_out_2;
		 undef @SAVE;
	     }
	 }
	 next;
     }
    # Print out line
    if ($continued_print == 1 ){
	&print_out_1;
	$continued_compare = 0;
    	next ;
    }
}

if (defined $HEADER){
    seek(OUTFILE,$MOD_POINT,0);
    $HEADER =~ s/^$VIO_1 $VIO_1/$VIO_2 $VIO_2/;
    $HEADER =~ s/\n//;
    print OUTFILE $HEADER;
    seek(OUTFILE,0,2);
    undef $MOD_POINT; undef $HEADER;
    $VIO_2 = 0 ;
}

print "**Output file is $output_file\n";
