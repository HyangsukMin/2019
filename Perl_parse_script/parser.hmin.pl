#! /usr/bin/perl -s

##################################################################################################
# Author      : Claire Min
# Update      : 2019/06/10
# Description : Ptsi Timing Report Summary
###################################################################################################

# open input and output file
#----------------------------------------
if (@ARGV == 2){
    $input_file = $ARGV[0];
    $output_file = $ARGV[1];
    open(INFILE,$input_file) || die "Cannot find '$input_file'\n";
    open(OUTFILE,'>',$output_file) || die "Cannot generate '$output_file'\n";
} elsif (@ARGV == 1){
    $input_file = $ARGV[0];
    open(INFILE,$input_file) || die "Cannot find '$input_file'\n";
    $output_file = "$input_file.analysis";
    open(OUTFILE,'>',$output_file) || die "Cannot generate '$output_file'\n";
} else {
    die "Syntax1: $0 [Input_filename] [output_filename]\nSyntax2: $0 [input_filename]\n";
}

########################################################################################################
# Variables
########################################################################################################

# Toggle & Custom
#-----------------------------------------

# $cross_clock; set to toggle cross_clock
# $path_group; set to toggle path_group
$dp = 1000 ;

# Theshold
#----------------------------------------
$Incr_threshold  = 0.1;
$Delta_threshold = 0.01;

# Coninue or not
#----------------------------------------
$cont_clock = 0;
$cont_Incr = 0;
$cont_Delta = 0;
$write_continued = 0;
$STARTPOINT_PIN = 0;   # To find Startpoint pin in the table
$ENDPOINT_PIN = 0;     # To find Endpoint Pin in the table

# Declaire Variables
#-----------------------------------------
#%datas;        # store parsed data in each path. It'll be re-defined every path.
## $datas{FF}          # 0 | 1
## $datas{STARTPOINT}  # string  
## $datas{STARTCLOCK}  # string
## $datas{ENDPOINT}    # string
## $datas{ENDCLOCK}    # string
## $datas{INOUT}       # 0 1 2 (max value is 2) 	# For special case like I/O port timing report
## $datas{PATHGROUP}   # string
## $datas{TYPE}        # max/min
## $datas{SCENARIO}    # string
## $datas{INCR_THR}    # number
## $datas{DELTA_THR}   # number
## $datas{LAUNCH}      # float
## $datas{CAPTURE}     # float
## $datas{IN_EXT_DLY}  # float
## $datas{ARRIVAL}     # float
## $datas{CAPTURE}     # float
## $datas{PHASE}       # float
## $datas{CPPR}        # float
## $datas{UNCERTAINTY} # float
## $datas{OUT_EXT_DLY} # float
## $datas{SLACK}       # float
## $datas{IDEAL}       # 0 | 1


#num;           # Count data path -> Used all time. will not be deleted.
#$num2;         # Find Launch and Capture Clock Latency. Updated in every path.
#$cont_Incr_2;  # Find the location of the last word 'r' of Incr in the header.
#$value_Incr;   # Find the value of Incr.
#$cont_Delta_2; # Find the location of the last word 'a' of Delta in the header.
#$value_Delta;  # Find the value of Delta.
#$SKEW;         # | Capture - Launch | - CPPR
#$SKEW_COND;    # Bad for Setup (Capture < Launch) or Bad for Hold (Capture > Launch)
#$SKEW_RATIO;   # SEKW / max(Capture, Launch)
#$DELAY;        # Data Path Delay : Data arrival time - Launch Clock Latuncy (for clock path)
                #                   Data arrival time (for no clock path, when FF == 1) 
#$DELAY_RATIO;  # Data Path Delay / Phase shift

#@array;
#$CLOCK;


#################################################
# Parsing and Writing
#################################################

while ($line = <INFILE>){
    # Check clock exists?
    if ($line =~ /Warning: No clock paths/){
	$datas{FF} = 1;
	next;
    }
    # Find Startpoint and if there is a clock name, find it.
    if ($line =~ /\s+Startpoint: (\S+)/){
	$num += 1;
	$datas{STARTPOINT}=$1;
	$write_continued += 1;
	# For special case like I/O port timing report
	if ($line =~ /Startpoint: \S+ \(/){
	    @array = split(/\s+/,$line);
	    $CLOCK = $array[-1];
	    $CLOCK =~ s/\)//;
#	    $datas{STARTPOINT} .= " '$CLOCK'";
	    $datas{STARTCLOCK} = $CLOCK;
	    $datas{INOUT} += 1;
	    undef @array; undef $CLOCK;
	# For normal case
	} else {
	    $cont_clock=1;
	}
	next;
    }
    # Find Endpoint and if there is a clock name, find it.
    if ($line =~ /\s+Endpoint: (\S+)\s*/){
	$datas{ENDPOINT}=$1;
	# For special case like I/O port timing report
	if ($line =~ /\Endpoint: \S+ \(/){
	    @array = split(/\s+/,$line);
	    $CLOCK = $array[-1];
	    $CLOCK =~ s/\)//;
#	    $datas{ENDPOINT} .= " '$CLOCK'";
	    $datas{ENDCLOCK} = $CLOCK;
	    $datas{INOUT} += 1;
	    undef @array; undef $CLOCK;
	# For normal case
	} else {
	    $cont_clock=1;
	}
	next;
    }
    # Get Clock 
    if ($cont_clock==1){
	@array = split(/\s+/,$line);
	$CLOCK = $array[-1];
	$CLOCK =~ s/\)//;
	if (!defined $datas{ENDPOINT}){
#	    $datas{STARTPOINT} .= " '$CLOCK'";
	    $datas{STARTCLOCK} = $CLOCK;
	} else {
#	    $datas{ENDPOINT} .= " '$CLOCK'";
	    $datas{ENDCLOCK} = $CLOCK;
	}
	undef @array; undef $CLOCK;
	$cont_clock=0;
	next;
    }
    # Grab Path Group
    if ($line =~ /Path Group: (\S+)/ and $path_group ==1 ){
	$datas{PATHGROUP}=$1;
	next;
    }
    # Define max/min
    if ($line =~ /\s+Path Type: ([minax]+)\s+/){
	$datas{TYPE}=$1;
	next;
    }
    # Defind scenario
    if ($line =~ /Scenario: (\S+)/){
	$datas{SCENARIO} = $1;
	next;
    }
    # Split Header of the Table
    if ($line =~ /\s+Point /){
	@columns = split(/\s+/,$line);
	if (grep(/^Incr/,@columns) and $datas{TYPE} eq "max"){
	    $cont_Incr = 1;
	    $idx_Incr = index($line,"Incr")+length("Incr");
#	    $idx_Incr = grep {$columns[$_] eq 'Incr'}(0..$#columns)
	    $datas{INCR_THR}=0;
	}
	if (grep(/^Delta/,@columns)){
	    $cont_Delta = 1;
	    $idx_Delta = index($line,"Delta")+length("Delta");
#	    $idx_Delta =  grep {$columns[$_] eq 'Delta'}(0..$#columns)
	    $datas{DELTA_THR}=0;
	}
	$STARTPOINT_PIN = 1;
	$ENDPOINT_PIN = 1;
	next;
    }
    # Find Launch clock when clock source
    if ($line =~ /clock source latency\s+([-\d.]+)/){
	$num2+=1;
	if ($num2 == 1){
	    $datas{LAUNCH} = $1;
	} elsif ($num2 == 2 ){
	    $datas{CAPTURE} = $1;
	}
	next;
    }
    # Find input external delay (Only when the path is Input port, it exits)
    if ($line =~ /input external delay\s+([-\d.]+)/){
	$datas{IN_EXT_DLY} = $1;
	next;
    }
    # Find Data path delay
    if ($line =~ /data arrival time\s+\D*([-\d.]+)\D*/){
	$cont_Incr=0;
	$cont_Delta=0;
	$datas{ARRIVAL} = $1;
	next;
    }
    # Find Launch and capture clock 
    if ($line =~ /clock network delay \((\S+)\)\s+([-\d.]+)/){
	$num2+=1;
	$data{IDEAL} = $1;
	if ($num2 == 1){
	    $datas{LAUNCH} = $2;
	} elsif ($num2 == 2 ){
	    $datas{CAPTURE} =$2;
	}
	next;
    }
    # Find Phase shift, if it is FF
    if ($line =~ /max_delay\s+([-\d.]+)/){
	$datas{PHASE} = $1;
	next;
    }
    # Find Phase shift
    if ($line =~ /clock $datas{ENDCLOCK} \(\D+\)\s+([-\d.]+)\s+\S+/){
	$datas{PHASE}=$1;
	next;
    }
    # Find CPPR
    if ($line =~ /clock reconvergence pessimism\s+([-\d.]+)\s+\S+/){
	$datas{CPPR}=$1;
	next;
    }
    # Find Uncertainty
    if ($line =~ /clock uncertainty\s+([-\d.]+)\s+\S+/){
	$datas{UNCERTAINTY} = abs($1);
	next;
    }
    # Find output external delay (Only when the path is Output port, it exits)
    if ($line =~ /output external delay\s+([-\d.]+)/){
	$datas{OUT_EXT_DLY} = $1;
	next;
    }
    # Find Startpoint Pin
    if ($STARTPOINT_PIN > 0 and $line =~ /$datas{STARTPOINT}/){
	$line =~ /$datas{STARTPOINT}(\/\S+)/ ;
	$datas{STARTPOINT_PIN} = $1;
	if ($STARTPOINT_PIN > 1){
	    $datas{STARTPOINT} .= $datas{STARTPOINT_PIN};
	    $STARTPOIN_PIN = 0;
	}
	$STARTPOINT_PIN += 1;
    }
    # Find Endpoint Pin
    if ($ENDPOINT_PIN == 1 and $line =~ /$datas{ENDPOINT}/){
	$line =~ /$datas{ENDPOINT}(\/\S+)/ ;
	$datas{ENDPOINT_PIN} = $1;
	$datas{ENDPOINT} .= $datas{ENDPOINT_PIN};
	$ENDPOINT_PIN = 0;
    }
    # Count cases over the threshold
    if ($cont_Incr == 1 or $cont_Delta == 1){
	if ($line =~ /clock $datas{STARTCLOCK} / or $line =~ /clock network delay/ or $line =~ /[inputo]+ external delay/){
	    next;
	}
	if ($cont_Incr == 1){
	    $cont_Incr_2 = substr($line, $idx_Incr);
	    if ($cont_Incr_2 ne ""){
		@array = split(/\s+/,substr($line,0,$idx_Incr));
		$value_Incr = $array[-1];
		if ($value_Incr > $Incr_threshold){
		    $datas{INCR_THR}+=1;
		}
	    }
	}
	if ($cont_Delta == 1){
	    $cont_Delta_2 = substr($line, $idx_Delta);
	    if ($cont_Delta_2 ne ""){
		@array = split(/\s+/,substr($line,0,$idx_Delta));
		$value_Delta = $array[-1];
		if ($value_Delta > $Delta_threshold){
		    $datas{DELTA_THR}+=1;
		}
	    }
	}
	next;
    }
    # Find slack
    if ($line =~ /\s+slack\s+\(\D+\)\s+([-]*[\d.]+)/){
	$datas{SLACK}=$1;
	if ($write_continued == 1){
	    $write_continued += 1;
	} else {
	    $write_continued = 0;
	}
    }
    # Start Writing
    if ($write_continued == 2){
	print OUTFILE "###################################################################################################################################################################################################################\n";
#-----------------------------------------------
# Three types of wrting way.
# Ideal : ?? 
# FF : no clock path
# Clock path : Max(Setup Vio) / Min(Hold Vio)
#-----------------------------------------------

# COMMON : Path num, scenario
#--------------------------------------------------

        # Print PATH number (it has a toggle option)
	if ($path_group ==1 and defined $datas{PATHGROUP}){
	    print OUTFILE "PATH $num $datas{TYPE} $datas{PATHGROUP}\n";
	} else {
	    print OUTFILE "PATH $num $datas{TYPE}\n";
	}

	# Print Scenario, if it has.
	if (defined $datas{SCENARIO} ){
	    print OUTFILE "SCENARIO: $datas{SCENARIO}\n";
	}
	
# Type 1 : Ideal
# Startpoint, Startclock, Endpoint, Endclock, Slack, Uncertainty
#----------------------------------------------------------------------------------------------------
	if ($data{IDEAL} eq 'ideal' ){
	    print OUTFILE "STARTPOINT: $datas{STARTPOINT} '$datas{STARTCLOCK}'\n";
	    print OUTFILE "ENDPOINT: $datas{ENDPOINT} '$datas{ENDCLOCK}'\n";
	    if ($datas{TYPE} eq 'max'){
		print OUTFILE "Uncertainty: $datas{UNCERTAINTY}\n";
	    } 
	    print OUTFILE "Slack: $datas{SLACK}\n";

# Type 2 : No clock path
# Startpoint, Endpoint, Slack, Uncertainty, Phase shift, Slack, Data Path Delay, Data Path Ratio
#-----------------------------------------------------------------------------------------------------  
	} elsif (defined $datas{FF}){
	    print OUTFILE "STARTPOINT: $datas{STARTPOINT}\n";
	    print OUTFILE "ENDPOINT: $datas{ENDPOINT}\n";
	    print OUTFILE "Max delay: $datas{PHASE}\n";
	    print OUTFILE "Slack: $datas{SLACK}\n";
	    print OUTFILE "\n";
	    print OUTFILE "Data Path Delay: $datas{ARRIVAL}\n";
	    if ($datas{PHASE} != 0 ){
		$DELAY_RATIO = $datas{ARRIVAL}/$datas{PHASE};
		if ($DELAY_RATIO > 1.0){
		    printf OUTFILE "Data Path Ratio: %4.3f  <- **RED FLAG**\n",$DELAY_RATIO;
		} else {
		    printf OUTFILE "Data Path Ratio: %4.3f\n",$DELAY_RATIO;
		}
	    } else {
		print OUTFILE "Data Path Ratio: Max delay is 0\n";
	    }

# Type 3 : Clock path - min/max, IO path
# Startpoint, Startclock, Endpoint, Endclock, Phase shift, CPPR, Uncertainty(max), Slack, Launch Clock, Capture Clock
# Skew, Skew/Latency, Data path delay, Data Data path delay ratio(max), Cell delay(max), Delta
# Input external delay(Input Path), Output external delay(Output path)
#---------------------------------------------------------------------------------------------------------------------
	} else {
	    print OUTFILE "STARTPOINT: $datas{STARTPOINT} '$datas{STARTCLOCK}'\n";
	    print OUTFILE "ENDPOINT: $datas{ENDPOINT} '$datas{ENDCLOCK}'\n";
	    print OUTFILE "Phase shift: $datas{PHASE}\n";
	    print OUTFILE "CPPR adjustmant: $datas{CPPR}\n";
	    
	    if ($datas{TYPE} eq 'max'){
		print OUTFILE "Uncertainty: $datas{UNCERTAINTY}\n";
	    }
	    
	    print OUTFILE "Slack: $datas{SLACK}\n";
	    print OUTFILE "\n";
	    # Launch and Capture Clock Latency and Skew
	    if (!defined $datas{LAUNCH}){
		$datas{LAUNCH} = 0 ;
	    }
	    if (!defined $datas{CAPTURE}){
		$datas{CAPTURE} = 0 ;
	    }
	    print OUTFILE "Launch Clock Latency: $datas{LAUNCH}\n";
	    print OUTFILE "Capture Clock Latency: $datas{CAPTURE}\n";
	    
	    $SKEW = $datas{CAPTURE}-$datas{LAUNCH};
	    
	    if ($SKEW < 0){
		$SKEW_COND = "(Bad for Setup)";
	    } elsif ($SKEW > 0) {
		$SKEW_COND = "(Bad for Hold)";
	    } else {
		$SKEW_COND = "";
	    }
	    
	    $SKEW = abs($SKEW)-$datas{CPPR};
	    
	    printf OUTFILE "Skew: %4.3f $SKEW_COND\n",$SKEW;
	    
	    if ($datas{INOUT} < 2 ){
		if (( $datas{CAPTURE} == 0 and $datas{LAUNCH} == 0 )){
		    print OUTFILE "Skew/Latency Ratio : 0 <- Both Clocks are 0 \n";
		} else {
		    if ($datas{LAUNCH} > $datas{CAPTURE}){
			$SKEW_RATIO = $SKEW/$datas{LAUNCH};
		    } else {
			$SKEW_RATIO = $SKEW/$datas{CAPTURE};
		    }
		    if ($SKEW_RATIO >= 0.2){
			printf OUTFILE "Skew/Latency Ratio: %4.4f  <- **RED FLAG**\n",$SKEW_RATIO;
		    } else {
			printf OUTFILE "Skew/Latency Ratio: %4.4f\n",$SKEW_RATIO;
		    }
		}
	    }
	    print OUTFILE "\n";
	    
	    $DELAY = $datas{ARRIVAL}-$datas{LAUNCH};
	    printf OUTFILE "Data Path Delay: %4.4f\n", $DELAY;
	    
	    # WARN:If Phase shift is 0, it'll not print out. (temporary b/c latch)
	    if ($datas{TYPE} eq "max" and $datas{PHASE}!=0){
		$DELAY_RATIO = $DELAY/$datas{PHASE};
		if ($DELAY_RATIO > 1.0){
		    printf OUTFILE "Data Path Ratio: %4.4f  <- **RED FLAG**\n",$DELAY_RATIO;
		} else {
		    printf OUTFILE "Data Path Ratio: %4.4f\n",$DELAY_RATIO;
		}
	    }
	    print OUTFILE "\n";
	    if (defined $datas{IN_EXT_DLY}){
		print OUTFILE "Input external delay : $datas{IN_EXT_DLY}\n";
	    }
	    
	    if (defined $datas{OUT_EXT_DLY}){
		print OUTFILE "Output external delay : $datas{OUT_EXT_DLY}\n";
	    }
	    print OUTFILE "\n";
	    if ($datas{TYPE} eq "max" and defined $datas{INCR_THR}){
		print OUTFILE "[Cell_delay] > $Incr_threshold: $datas{INCR_THR}\n";
	    }
	    if (defined $datas{DELTA_THR}){
		print OUTFILE "[Delta] > $Delta_threshold: $datas{DELTA_THR}\n";
	    }
	}
        ######################
        # Cross clock Option #
        ######################
	if ($cross_clock){
	    if ($datas{STARTCLOCK} ne $datas{ENDCLOCK}){
		print OUTFILE "CROSS_CLOCK($datas{PATHGROUP}): $datas{STARTCLOCK} |  $datas{ENDCLOCK}\n";
	    }
	}
	print OUTFILE "###################################################################################################################################################################################################################\n\n";
        ######################
        # Reset Variables    #
        ######################
	undef %datas;
	undef $cont_Incr_2; undef $cont_Delta_2;
	undef $DELAY; undef $DELAY_RATIO;
	undef $SKEW; undef $SKEW_COND; 	undef $SKEW_RATIO;
	undef $num2;
	undef $STARTPOIN_PIN ; $ENDPOINT_PIN ;
	$write_continued = 0;
	if ($num % $dp == 0){
	    print "$num paths finished\n";
	}
    }
}
print "Total $num paths finished\n";
