#!/usr/bin/perl
use strict;

############################### SUB-ROUTINES #####################################

sub execute_command_on_NEW_SEL{

	my $clc_ip = shift @_;

	my $SEL_SERVER_IP = "192.168.51.152";
	my $SSH_PREFIX = "ssh -o BatchMode=yes -o ServerAliveInterval=3 -o ServerAliveCountMax=10 -o StrictHostKeyChecking=no root\@$SEL_SERVER_IP";
	
	my $sel_cmd = "cd /root/eucalyptus_admin_ui_test; export DISPLAY=:0;";
	$sel_cmd .= " ./runtest_admin_create_user.py -i $clc_ip  -p 8443 -t admin_create_user";

	my $cmd = $SSH_PREFIX . " \"" . $sel_cmd . "\"";

	print "CMD: $cmd\n";
	my $output = `$cmd`;
	print "\n";
	return  $output;

};


sub execute_command_on_SEL{

	my $this_command = shift @_;
	my $sel_ip = $ENV{'SEL_SERVER_IP'};
	my $output = "";
	
	my $ssh_cmd = "ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$sel_ip \"cd /root/gui_tests; perl ./$this_command\" ";

	print "\n";
	print "Executing SSH COMMNAD on SEL:\n";
	print "$ssh_cmd\n";
	print "\n";

	$output = `$ssh_cmd`;

	print "RESULT:\n";
	print "$output";
	print "\n";

	return $output;
};


sub validate_output{
	my $lines = shift @_;

	print "\n";
	print "Validating the Result\n";
	print "\n";
	
	if( $lines =~ /\[TEST_REPORT\]\s+FAILED/m ){
		print "Detected FAILED operations\n";
		print "\n";
		return 1;
	};

	print "ALL PASSED\n";
	print "\n";

	return 0;
};



sub execute_command_on_CLC{

	my $this_command = shift @_;
	my $clc_ip = $ENV{'QA_CLC_IP'};
	my $output = "";
	
	my $ssh_cmd = "ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root/; source ./eucarc; $this_command\" ";

	print "\n";
	print "Executing SSH COMMNAD on CLC:\n";
	print "$ssh_cmd\n";
	print "\n";

	$output = `$ssh_cmd`;

	print "RESULT:\n";
	print "$output";
	print "\n";

	return $output;
};



sub unzip_credentials_on_CLC{

	my $this_command = "unzip -o admin_cred.zip";
	my $clc_ip = $ENV{'QA_CLC_IP'};
	my $output = "";
	
	my $ssh_cmd = "ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root/; $this_command\" ";

	print "\n";
	print "Executing SSH COMMNAD on CLC:\n";
	print "$ssh_cmd\n";
	print "\n";

	$output = `$ssh_cmd`;

	print "RESULT:\n";
	print "$output";
	print "\n";

	return $output;
};


sub report_fatal_error{
	my $error_str = shift @_;
	print "[TEST_REPORT]\tFAILED in $error_str\n";
	exit(1);
};


# does_It_Have( $arg1, $arg2 )
# does the string $arg1 have $arg2 in it ??
sub does_It_Have{
	my ($string, $target) = @_;
	if( $string =~ /$target/ ){
		return 1;
	};
	return 0;
};



sub read_input_file{
	open( LIST, "../input/2b_tested.lst" ) or return 1;
	my $is_memo;
	my $memo = "";

	my $line;
	while( $line = <LIST> ){
		chomp($line);
		if( $is_memo ){
			if( $line ne "END_MEMO" ){
				$memo .= $line . "\n";
			};
		};
		if( $line =~ /^(.+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[(.+)\]/ ){
			my $ip = $1;
			my $distro = $2;
			my $distro_ver = $3;
			my $arch = $4;
			my $source = $5;
			my $roll = $6;
			if( does_It_Have($roll, "CLC")  ){
				$ENV{'QA_CLC_IP'} = $ip;
				$ENV{'QA_DISTRO'} = $distro;
				$ENV{'QA_DISTRO_VER'} = $distro_ver;
				$ENV{'QA_ARCH'} = $arch;
				$ENV{'QA_SOURCE'} = $source;
			};
		}elsif( $line =~ /^BZR_BRANCH\t(.+)/ ){
			my $temp = $1;
			chomp($temp);
                        $temp =~ s/\r//g;
			if( $temp =~ /eucalyptus\/(.+)/ ){
				$ENV{'QA_BZR_DIR'} = $1; 
			};
		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		};		
	};
	close(LIST);

	$ENV{'QA_MEMO'} = $memo;

	return 0;
};




1;

