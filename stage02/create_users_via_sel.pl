#!/usr/bin/perl
use strict;
require './lib_for_sel.pl';

###
### Initialize
###
$ENV{'SEL_SERVER_IP'} = "192.168.51.187";

print "\n";
print "Running create_users_via_sel.pl\n";
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
my $this_user = "gui-user-00";

###	QUICK HACK TO MAKE IT WORK WITH 3.2
if( 1 ){

	$lines = execute_command_on_NEW_SEL($ENV{'QA_CLC_IP'}, "admin_create_user");
	print $lines . "\n";

}else{
	$cmd = "create_user.pl $ENV{'QA_CLC_IP'} $this_user";

	$lines = execute_command_on_SEL($cmd);

	validate_output($lines);
};


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

if( $lines =~ /$this_user/ ){
	print "[TEST_REPORT]\tFound User $this_user\n";
}else{
	report_fatal_error("adding a new user $this_user!!");
};
print "\n";


###
### End of Script
###
print "\n";
print "[TEST_REPORT]\tRun of Script create_users_via_sel.pl is Successful\n";
print "\n";

exit(0);

1;


