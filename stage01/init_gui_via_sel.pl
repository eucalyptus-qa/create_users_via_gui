#!/usr/bin/perl
use strict;
require './lib_for_sel.pl';

###
### Initialize
###
$ENV{'SEL_SERVER_IP'} = "192.168.51.187";

print "\n";
print "Running init_gui_via_sel.pl\n";
print "\n";

my $cmd = "";
my $lines = "";



###
### Reading input file ../input/2b_tested.pl
###
read_input_file();



###
### Validate SEL and CLC IPs
###
if( $ENV{'QA_CLC_IP'} eq "" ){
	print "[TEST_REPORT]\tFAILED to detect CLC IP!!\n\n";
	exit(1);
};

print "SEL SERVER IP\t$ENV{'SEL_SERVER_IP'}\n";
print "CLC IP\t$ENV{'QA_CLC_IP'}\n";
print "\n";



###
### Run SEL script
###
$cmd = "test_seq_init.pl $ENV{'QA_CLC_IP'}";

$lines = execute_command_on_SEL($cmd);

validate_output($lines);



###
### Validate the Action on CLC
###


### Unzipping admin crdentials on CLC
$lines = unzip_credentials_on_CLC();

if( $lines =~ /eucarc/m ){
	print "[TEST_REPORT]\tAdmin Credentials eucarc is Ready\n";
}else{
	report_fatal_error("unzipping Admin Credentials on CLC!!");
};
print "\n";


### Running euca-userlistbypath to display the empty user list
$cmd = "euare-userlistbypath";
$lines = execute_command_on_CLC($cmd);

if( $lines =~ /eucalyptus.+admin/ ){
	print "[TEST_REPORT]\tRun of Command $cmd is Successful\n";
}else{
	report_fatal_error("running $cmd on CLC!!");
};
print "\n";



###
### End of Script
###
print "\n";
print "[TEST_REPORT]\tRun of Script init_gui_via_sel.pl is Successful\n";
print "\n";

exit(0);

1;


