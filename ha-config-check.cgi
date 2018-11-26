#!/usr/bin/perl
# /* $Id: //depot/tools/ngs/CCC/cmdline/ha-config-check.cgi#5 $ */
use Getopt::Std;
use strict;
#use warnings;
use Pod::Usage;

# NOTE: This script supports all Data ONTAP releases >= 5.3.2 and <= 7.x
my $MyVersion = "2.0.0";
my @RshCommand;
my @Filer;
my @Sid;
my %Node;
my $Opt = {};
$RshCommand[0] = "rsh -l :";
$RshCommand[1] = "rsh -l :";

my $VersionCommand = "version";
my $LicenseCommand = "license";
my $OptionsCommand = "options";
my $IfconfigCommand = "ifconfig -a";
my $CfStatusCommand = "cf status";
my $HostnameCommand = "\"priv set -q advanced; hostname\"";
my $CfPartnerCommand = "cf partner";
my $FcpcfModeCommand = "fcp show cfmode";
my $RdrcCommand = "rdfile /etc/rc";
my $RdhostsCommand = "rdfile /etc/hosts";
my $NodeSNCommand = "system node show -fields systemid,serialnumber,health";
my $NodeCmdPre = 'run -node %s -command %s';
my $DataLIFCmd = 'network interface show -role data ' . 
    '-fields lif,curr-node';
my $DataLIFRulesCmd = 'network interface failover show ' . 
    '-fields lif,priority,node,port';
my @Keywords = ("alias", "-alias", "netmask", "netmask", 
		"mtusize", "mediatype", "flowcontrol", 
		"trusted", "untrusted", "wins", "-wins");

my $Script = $ENV{'SCRIPT_NAME'};
my $ActAsCgi = defined( $ENV{ 'GATEWAY_INTERFACE' });
my $Total_issues = 0;
my $WINDOWS = 0;
my $DEBUG = 0;
$WINDOWS = 1 if ($^O eq "MSWin32");

#main -- parse input data and call subroutines to do the real work.
if ( $ActAsCgi )
{
    $DEBUG = 1; # Turn verbose output in web
    # run as cgi script
    # Send error messages to the user, not system log
    open(STDERR,'<&STDOUT');  $| = 1;
    print "Content-type: text/html\n\n";
    print "<HTML><HEAD><TITLE>NetApp HA Configuration Checker " . 
	"</TITLE></HEAD></HTML>";
    
    use CGI;
    my $q = CGI->new();
    if ($q->param('button')) {
	if ($q->param('button') =~ "About"){
	    printAbout();
	}
	if ($q->param('button') =~ "Help"){
	    printHelp();
	}
	if ($q->param('button') =~ "Check Configuration"){
	    if ($q->param('shell')){
		my $shell = $q->param('shell');
		$RshCommand[0] =~ s/^rsh/$shell/;
		$RshCommand[1] =~ s/^rsh/$shell/;
	    }
	    elsif ($q->param('proto') eq "ssh"){
		$RshCommand[0] =~ s/^rsh/ssh/;
		$RshCommand[1] =~ s/^rsh/ssh/;
	    }
	    if ($q->param('filer1') && $q->param('filer2') && 
		($q->param('filer1') ne $q->param('filer2'))) {
		
		$Filer[0] = $q->param('filer1');
		if ($q->param('uid1')){
		    my $uid1 = $q->param('uid1');
		    $RshCommand[0] =~ s/:/$uid1:/;
		    if ($q->param('shell') eq "rsh") {
			if ($q->param('passwd1')) {
			    my $pwd1 = $q->param('passwd1');
			    $RshCommand[0] =~ s/:/:$pwd1/;
			}
		    }
		    else {$RshCommand[0] =~ s/://g;}
		}
		else{ $RshCommand[0] =~ s/ -l ://; }
		
		$Filer[1] = $q->param('filer2');
		if ($q->param('uid2')) 
		{
		    my $uid2 = $q->param('uid2');
		    $RshCommand[1] =~ s/:/$uid2:/;
		    if ($q->param('proto') eq "rsh" && $q->param('passwd2')) {
			my $pwd2 = $q->param('passwd2');
			$RshCommand[1] =~ s/:/:$pwd2/;
		    }
		    else{ $RshCommand[1] =~ s/://g; }
		}
		else{ $RshCommand[1] =~ s/-l ://; }
		$RshCommand[0] .= " $Filer[0]";
		$RshCommand[1] .= " $Filer[1]";
		print "<H1>Checking NetApp HA system configuration: " . 
		    "$Filer[0] and $Filer[1]</H1>";
		performChecks();
		
		print "<p>No HA configuration issues found." 
		    if (!$Total_issues);
		print "<p>HA configuration issue(s) found above. " . 
		    "Please correct them and rerun this script." 
		    if ($Total_issues);
		print "<p>Done." 
		}
	    else {
		showForm($q);
	    }
	}
    }
    else {
	showForm($q);
    }
}
else 
{
    # run as a command line perl script
    getopts ('sr:lDc', $Opt);
    my $SSH = 0;
    $SSH = 1 if ($Opt->{s});
    if ($Opt->{r} || $Opt->{s})
    {
	$Opt->{r} = "ssh" if (!$Opt->{r});
	$RshCommand[0] =~ s/^rsh/$Opt->{r}/;
	$RshCommand[1] =~ s/^rsh/$Opt->{r}/;
    }
    
    $DEBUG = 1 if ($Opt->{D});
    my $LOGIN = 0;
    $LOGIN = 1 if ($Opt->{l});
    if ($Opt->{s} && $Opt->{l})
    {
	print STDERR "Cannot use -s and -l at the same time\n";
	exit (99);
    }
    
    if ($Opt->{'c'} && (@ARGV != 3)){  printUsage();}
    elsif (!$Opt->{'c'} && @ARGV != 2) {printUsage();}
    
    if ($LOGIN)
    {
	$Filer[0] = $ARGV[0];
	$RshCommand[0] = "rsh -l " if ($WINDOWS);
	print "$Filer[0] rsh login: ";
	chomp(my $uid1 = <STDIN>);
	$uid1 =~ s/\r//g;
	system "stty -echo" if (!$WINDOWS);
	print "Password: ";
	chomp(my $passwd1 = <STDIN>);
	$passwd1 =~ s/&/\\&/g;
	$passwd1 =~ s/\r//g;
	print "\n";
	system "stty echo" if (!$WINDOWS);
	$RshCommand[0] = "rsh $Filer[0] -l ".$uid1.":".$passwd1;
	
	# Prompt for second UID only for 7 mode
	if (!$Opt->{'c'})
	{
	    $Filer[1] = $ARGV[1];
	    $RshCommand[1] = "rsh -l " if ($WINDOWS);
	    print "$Filer[1] rsh login: ";
	    chomp(my $uid2 = <STDIN>);
	    $uid2 =~ s/\r//g;
	    system "stty -echo" if (!$WINDOWS);
	    print "Password: ";
	    chomp(my $passwd2 = <STDIN>);
	    $passwd2 =~ s/&/\\&/g;
	    $passwd2 =~ s/\r//g;
	    print "\n";
	    system "stty echo" if (!$WINDOWS);
	    $RshCommand[1] = "rsh $Filer[1] -l $uid2:$passwd2";
	}
    }
    
    # Get the ip address, serial number/sys ID
    elsif ($Opt->{'c'})
    {
	$Filer[0] = $ARGV[0];
	$Filer[1] = $ARGV[0];
	$Sid[0] = $ARGV[1];
	$Sid[1] = $ARGV[2];
	$RshCommand[0] =~ s/-l :/$Filer[0]/;
	$RshCommand[1] =~ s/-l :/$Filer[0]/;
    }
    else
    {
	$Filer[0] = $ARGV[0];
	$Filer[1] = $ARGV[1];
	$RshCommand[0] =~ s/-l :/$Filer[0]/;
	$RshCommand[1] =~ s/-l :/$Filer[1]/;
    }
    
    print "== NetApp HA Configuration Checker v$MyVersion ==\n\n";
    performChecks();
    
    print "No HA configuration issues found.\n" if (!$Total_issues);
    print "HA configuration issue(s) found above. Please correct them and rerun this script.\n" 
	if ($Total_issues);
    print "Done.\n";
}


#present html form for submitting names of HA nodes
sub showForm {
    my $q = shift;
    my $cmode_select = $q->param('cmode_sel') ||'no';
    print <<EOF;

<SCRIPT>
function set_login_field(){
    if (document.CF_CHECK.proto.selectedIndex == 1) {
	document.CF_CHECK.shell.value = "ssh";
	document.CF_CHECK.passwd1.disabled = 1;
	document.CF_CHECK.passwd2.disabled = 1;
    }
    else {
	document.CF_CHECK.shell.value = "rsh";
	document.CF_CHECK.passwd1.disabled = 0;
	document.CF_CHECK.passwd2.disabled = 0;

    }
}

function set_form(select_elem){
    haform = select_elem.form;
    haform.submit();
    return true;
}
</SCRIPT>

<H1>NetApp HA Configuration Checker</H1>
    <FORM NAME="CF_CHECK" METHOD="POST"
    ACTION=$Script>
    <INPUT TYPE="submit" NAME="button" VALUE="About"/>
    <INPUT TYPE="submit" NAME="button" VALUE="Help"/>
    <hr>
    <span>
     Protocol: <select NAME="proto" onChange="set_login_field()">
    <option value="rsh" selected>rsh</option>
    <option value="ssh">ssh</option></select>
    </span>
    &nbsp; &nbsp; &nbsp; &nbsp;
    <span>
    <Remote Shell: <input name="shell" value="rsh">
    </span>
    <p>

    C mode :
    <select NAME="cmode_sel" id="cmode_sel" onChange="set_form(this)">
EOF
    if ($cmode_select =~ /no/i){
	print '<option value="no" selected>No</option>';
	print '<option value="yes">Yes</option></select>';
    }
    else {
	print '<option value="no">No</option>';
	print '<option value="yes" selected>Yes</option></select>';
    }
    
    if ($cmode_select =~ /yes/i){
	printcmodeInfo(); 
    }
    else {
	print7modeInfo();
    }
    
 print <<EOF;
<INPUT TYPE=submit NAME=button VALUE="Check Configuration">
</FORM>
EOF
}

sub printcmodeInfo {
    print <<EOF;
<p>
<table width="100%" cellpadding="0" cellspacing="0">
<tr>

<td>
<table>
<tr>
<th colspan="2">
Any HA Node Info
</th>
</tr>
<tr>
<td>Host Name/IP Address</td><td><INPUT NAME="filer1"></td>
</tr>
</table>
</td>

<td>
<table>
<tr>
<th colspan="2">
Frst HA Node
</th>
</tr>
<tr>
<td>Serial Number OR
<br/>System ID OR
<br/>Node name
</td>

<td style="vertical-align:top"><INPUT NAME="sid1"></td>
</tr>
</table>

</td>

<td>
<table>
<tr>
<th colspan="2">
Second HA Node
</th>
</tr>
<tr>
<td>Serial Number OR 
<br/>System ID OR
<br/>Node name
</td>

<td style="vertical-align:top"><INPUT NAME="sid2"></td>
</tr>
</table>

</td>

</tr>
</table>

EOF
}


sub print7modeInfo {

    print <<EOF;
<p>
<table width="100%" cellpadding="0" cellspacing="0">
<tr>

<td>
<table width="50%">
<tr>
<th colspan="2">
First HA Node
</th>
</tr>
<tr>
<td>Host Name/IP Address</td><td><INPUT NAME="filer1"></td>
</tr>
<tr>
<td>User Name</td><td><INPUT NAME="uid1"></td>
</tr>
<tr><td>Password</td><td><INPUT TYPE="password" NAME="passwd1"></td>
</tr>
</table>
</td>

<td>
<table width="50%">
<tr>
<th colspan="2">
Second HA Node
</th>
</tr>
<tr>
<td>Host Name/IP Address</td><td><INPUT NAME="filer2"></td>
</tr>
<tr>
<td>User Name</td><td><INPUT NAME="uid2"></td>
</tr>
<tr><td>Password</td><td><INPUT TYPE="password" NAME="passwd2"></td>
</tr>
</table>

</td>
</tr>
</table>

EOF
}

sub performChecks {
    my @checks = (\&checkLogins, \&getNodeName,\&checkOSversions, \&checkLicenseMismatch, 
		  \&checkClusterIdentity,
		  \&checkCfStatus, \&checkFCPcfmodeMismatch, \&checkOptionsMismatch,
		  \&checkNetworkConfig, \&checkRCfile);
    foreach my $func (@checks){
	last if $func->() != 0;
    }
}

# Lookup node name for the given serial/system ID
sub getNodeName {
    return 0 unless $Opt->{'c'};
    printHeading("Looking up node names for C mode");
    if (!open(FILERDATA, "$RshCommand[0] $NodeSNCommand |")){
	print "Can't lookup up node name for the given Serial numbers." .
	    "Command used $NodeSNCommand";
	printNewLine(1);
	return 1;
    }
    @Filer = ();
    while (<FILERDATA>) {
	if (m/([^\s]+)\s+(\d+)\s+(\d+)\s+([^\s]+)/) 
	{
	    my ($nodeName, $serialNum, $sysId, $health) = 
		($1, $2, $3, $4);
	    if ($Sid[0] =~ /$nodeName|$serialNum|$sysId/){
		unshift(@Filer, $nodeName);
	    }
	    elsif ($Sid[1] =~ /$nodeName|$serialNum|$sysId/){
		push(@Filer,$nodeName);
	    }	
	    $Node{$nodeName} = $health;
	    if ($DEBUG) { print;}
	}
    }
    
    if ($DEBUG) {
	print "Got Node names " . @Filer . ' : ' . join(',', @Filer) . 
	    " for identifiers " . $Sid[0] . ' and ' . $Sid[1] . "\n";
	foreach (keys %Node) {
	    print $_, ' => ', $Node{$_}, "\n";
	}
    }

    # Did I find some nodes?
    if (@Filer != 2){
	print "Could not find Cluster Nodes matching the given ".
	    "identifiers - " . $Sid[0] . ' and ' . $Sid[1] . "\n";
	$Total_issues++;
	return 1;
    }
    print "OK"; printNewLine(1);
    return 0;
}

# Get the cmd string to be run for c and 7 modes
sub getCmd {
    my $seq = shift;
    my $nodeCmd = shift;
    my $cmd;
    if ($Opt->{'c'}) {
	$cmd = sprintf($NodeCmdPre, $Filer[$seq], $nodeCmd);
    }
    else { $cmd = $nodeCmd; }
    return $cmd;
}

# Can we rsh into the nodes?
sub checkLogins {
    my $limit = $Opt->{'c'} ? 1 :2;
    for (my $fn = 0; $fn < $limit; $fn++) {
	printHeading("Checking rsh logins. $RshCommand[$fn] $VersionCommand") 
	    if (!$Opt->{s});
	printHeading("Checking ssh logins ...") 
	    if ($Opt->{s});
	my $foundFilerData = 0;
	if (! open(FILERDATA, "$RshCommand[$fn] $VersionCommand |") ) {
	    print "Can't run $VersionCommand on $Filer[$fn]";
	    printNewLine(1);
	    exit(1);
	}
	else {
	    while (<FILERDATA>) {
		$foundFilerData++;
	    }
	    close FILERDATA;
	}
	if (!$foundFilerData) {
	    my $rsh_name;
	    $rsh_name = "rsh" if (!$Opt->{s});
	    $rsh_name = "ssh" if ($Opt->{s});
	    print "Cannot $rsh_name into $Filer[$fn]";
	    printNewLine(1);
	    exit (1);
	}
    }
    print "OK"; printNewLine(1);
    return 0;
}

# look for OS version mismatch
sub checkOSversions {
    my $foundError = 0;
    printHeading("Checking Data ONTAP versions...");
    my @versionString;
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmd = getCmd($fn, $VersionCommand);
	if ($DEBUG) {
	    print "$Filer[$fn] :- $cmd";
	    printNewLine(1);
	}
	if (!open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	else {
	    my $lineNumber = 0;
	    while (<FILERDATA>) {
		if ($DEBUG) { print;}
		
		# Can we work with this OS ?
		if ($lineNumber == 0 && ! m/^NetApp.*$/ && !m/^Data ONTAP Release.*$/) {
		    print "$Filer[$fn] is not a NetApp storage controller";
		    printNewLine(1);
		    return 1;
		} 
		# Do the OS versions match ?
		if ($fn == 0) {
		    $versionString[$lineNumber++] = $_;
		}
		else {
		    if ($versionString[$lineNumber++] ne $_) {
			print "WARNING: Data ONTAP versions do not match on HA partners";
			printNewLine(1);
			$foundError = 1;
			$Total_issues++;
		    }
		}
	    }
	}
	close FILERDATA;
    }
    if ($foundError == 0) {
	print "OK"; 
	printNewLine(1);
    }
    return 0;
}

# for pre 6.0 releases, use rc_toggle_basic instead of "priv set .."
# Note: We assume that the nodes are not in rc_toggle_basic mode when we start.
sub rcToggleBasicCmds {
# $licenseCommand = "\"rc_toggle_basic; registry walk options.license; rc_toggle_basic\"";
# $IfconfigCommand = "\"rc_toggle_basic; registry walk status.if; rc_toggle_basic\"";
    $HostnameCommand = "\"rc_toggle_basic; hostname; rc_toggle_basic\"";
}

# look for license mismatch
sub checkLicenseMismatch {
    my $li;
    my %lic1 = ();
    my %lic2 = ();
    my $foundError = 0;
    printHeading("Checking licenses...");
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmd = getCmd($fn, $LicenseCommand);
	if ($DEBUG) {
	    print "$Filer[$fn] :- $cmd";
	    printNewLine(1);
	}
	if (! open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	else {
	    while (<FILERDATA>)
	    {
		my @lf = split (/[ \t]+/);
		$li = 2 if ($lf[0] eq "");
		$li = 1 if ($lf[0] ne "");
		$lic1{$lf[$li-1]} = 1 if ($lf[$li] ne "not" && $fn == 0);
		$lic2{$lf[$li-1]} = 1 if ($lf[$li] ne "not" && $fn == 1);
	    }
	}
	close FILERDATA;
	if ($DEBUG) { printNewLine(1); }
    }
    foreach my $k (keys (%lic1))
    {
	if (!exists ($lic2{$k}))
	{
	    print "$k exists on $Filer[0], but not on $Filer[1]";
	    printNewLine(1);
	    $foundError = 1;
	    $Total_issues++;
	}
    }
    foreach my $k (keys (%lic2))
    {
	if (!exists ($lic1{$k}))
	{
	    print "$k exists on $Filer[1], but not on $Filer[0]\n";
	    $foundError = 1;
	    $Total_issues++;
	}
    }
    print "OK\n" if (!$foundError);
    return 0;
}

# do the 2 nodes belong to the same HA configuration?
sub checkClusterIdentity {
    # This is irrelevant in C mode
    return 0 if $Opt->{'c'};
    
    printHeading("Checking HA configuration identity...");
    my @hostName;
    my @partnerName;
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmd = getCmd($fn, $HostnameCommand);
	if ($DEBUG) {
	    print "$Filer[$fn] :- $cmd";
	    printNewLine(1);
	}
	if (! open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	while (<FILERDATA>) {
	    chomp;
	    if ($DEBUG) { print;}
	    $hostName[$fn] = $_;
	}
	
	$cmd = getCmd($fn, $CfPartnerCommand);
	if (! open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	while (<FILERDATA>) {
	    chomp;
	    if ($DEBUG) { print;}
	    $partnerName[$fn] = $_;
	}
    }
    if ($partnerName[0] ne $hostName[1] || $partnerName[1] ne $hostName[0])
    {
	print "$hostName[0] and $hostName[1] are not members of the same HA configuration";
	printNewLine(1);
	return 1;
    }
    print "OK"; printNewLine(1);
    return 0;
}

# is cf enabled?
sub checkCfStatus {
    my $foundError = 0;
    printHeading("Checking cf status...");
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmd = getCmd($fn, $CfStatusCommand);
	if ($DEBUG) {
	    print "$Filer[$fn] :- $cmd";
	    printNewLine(1);
	}
	if (! open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	while (<FILERDATA>) {
	    if ($DEBUG) { print; }
	    if (m/Cluster disabled\./) {
		$foundError = 1;
		$Total_issues++;
	    }
	}
	close FILERDATA;
	if ($DEBUG) { printNewLine(1); }
    }

    if ($foundError){
	print "WARNING: The cf service is licensed but disabled.";
	printNewLine(1);
	return 1;
    }
    print "OK"; printNewLine(1);
    return 0;
}

# is fcp cfmode set the same?
sub checkFCPcfmodeMismatch {
    
    # Irrelevant in C mode
    return 0 if $Opt->{'c'};
    
    my $foundError = 0;
    my @fcpcfmodestring;
    
    printHeading("Checking fcp cfmode settings...");
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmdStr = ($^O ne "MSWin32") ? $FcpcfModeCommand . ' 2>/dev/null' :
	    $FcpcfModeCommand;
	my $cmd = getCmd($fn, $cmdStr);
	print "$Filer[$fn] :- $cmd \n" if $DEBUG;
	
	if (!open(FILERDATA, "$RshCommand[$fn] $FcpcfModeCommand|") ) {
	    print "Can't run $FcpcfModeCommand on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}

	$fcpcfmodestring[$fn] = <FILERDATA>;
	close FILERDATA;
	if ($fcpcfmodestring[$fn] !~ /fcp show cfmode/) {
	    print "N/A\n";
	    return 0;
	}
	print $fcpcfmodestring[$fn] . "\n" if $DEBUG;
    }
    if ($fcpcfmodestring[0] ne $fcpcfmodestring[1]) {
	$foundError = 1;
	$Total_issues++;
    }
    if ($foundError){
	print "FCP cfmode mismatch on HA configuration."; printNewLine(1);
	return 1;
    }
    
    print "OK"; printNewLine(1);
    return 0;
}

# look for options mismatch.
sub checkOptionsMismatch {
    my $foundError = 0;
    my @optionsList;
    printHeading("Checking options...");
    for (my $fn = 0; $fn < 2; $fn++) {
	my $cmd = getCmd($fn, $OptionsCommand);
	print "$Filer[$fn] :- $cmd \n" if $DEBUG;
	if (! open(FILERDATA, "$RshCommand[$fn] $cmd |") ) {
	    print "Can't run $cmd on $Filer[$fn]";
	    printNewLine(1);
	    return 1;
	}
	my $listIndex = 0;
	while (<FILERDATA>) {
	    next unless m/same/;
	    s/\(.*\)//;
	    if ($DEBUG) { print; }
	    # Getting data of filer
	    if ($fn == 0) {
		$optionsList[$listIndex++] = $_;
	    }
	    
	    # Getting data of partner
	    else {
		$listIndex = 0;
		my $foundOption = 0;
		while ($listIndex <= $#optionsList &&  $foundOption == 0) {
		    if ($optionsList[$listIndex] eq $_) {
			$optionsList[$listIndex] = "ERASED";
			$foundOption = 1;
		    }
		    $listIndex++;
		}
		if ($foundOption == 0) {
		    $foundError = 1;
		    print "Option $_ on $Filer[1] has no match on $Filer[0]";
		    printNewLine(1);
		}
	    }
	}
	close FILERDATA;
	if ($DEBUG) { printNewLine(1); }
    }
    
    for (my $listIndex = 0; $listIndex <= $#optionsList; $listIndex++) {
	if ($optionsList[$listIndex] ne "ERASED") {
	    $foundError = 1;
	    $Total_issues++;
	    print "Option $optionsList[$listIndex] on $Filer[0] has no match on $Filer[1]";
	    printNewLine(1);
	}
    }
    if ($foundError) { return 1;}
    print "OK"; 
    printNewLine(1);
    return 0;
}

# Checks for VIFs in C mode
sub checkVIFs {
    
    #1. Get Data VIFS for each node
    #2. Get Fail over rules for data VIF
    
    #Do validations - 
    #1. Are there data lifs for filer and partner.
    # I dont think it would be an error if there are no data lifs
    #2. Are there fail over rules for each data lifs 
    #If data lifs exist and no fo rules exist, yes it is a failure
    #If data lifs does not exist it is not a failure
    #If data lifs and fo rules exist, but no fail over hosts are online,
    #mark as error

    printHeading("Checking Data LIFs...");
    my %dataVIFs;
    my $cmd = $DataLIFCmd;
    print "$cmd \n" if $DEBUG;
    if (! open(FILERDATA, "$RshCommand[0] $cmd |") ) {
	print "Can't run $cmd on $Filer[0]";
	printNewLine(1);
	return 1;
    }
    while (<FILERDATA>) {
	next if /server\s+lif\s+curr-node/;
	next if /-+\s+-+\s+-+/;
	next if /entries\s+were\s+displayed/i;
	next unless /[^\s]+\s+([^\s]+)\s+([^\s]+)/;
	my $node = $2;
	my $vif = $1;
	if ($DEBUG) { print; }
	$dataVIFs{$vif} = {'vif_curr_node' => $node} if 
	    ($node eq $Filer[0]) || ($node eq $Filer[1]);
    }
    close FILERDATA;
    if ($DEBUG){
	print "Data VIFs are \n";
	foreach (keys %dataVIFs){
	    print $_, ' => ', $dataVIFs{$_}->{'vif_curr_node'}, "\n";
	}
    }
    
    printHeading("Checking Data LIF Failover rules...");
    my @dataVIFRules;
    my $cmd = $DataLIFRulesCmd;
    print "$cmd \n" if $DEBUG;
    if (! open(FILERDATA, "$RshCommand[0] $cmd |") ) {
	print "Can't run $cmd on $Filer[0]";
	printNewLine(1);
	return 1;
    }
    
    while (<FILERDATA>) {
	next unless /[^\s]+\s+([^\s]+)\s+(\d+)\s+([^\s]+)\s+([^\s]+)\b/;
	my ($vif, $pri, $tarNode, $tarPort) = ($1, $2, $3, $4);
	if ($DEBUG) { print; }
	push (@dataVIFRules, 
	      {'vif_name' => $vif,
	       'target_node' => $tarNode, 
	       'priority' => $pri,
	       'target_port' => $tarPort}) if exists $dataVIFs{$vif};
    }
    close FILERDATA;
    if ($DEBUG){
	print "Fail over rules are \n";
	foreach (@dataVIFRules){
	    print $_->{'vif_name'}, ' => ', $_->{'target_node'}, ' ,',
	    $_->{'priority'},  ' ,', $_->{'target_port'},"\n";
	}
    }
    
    # Now get the Data LIFs that does have valid Fail over rules
    # Valid is defined as 
    # having a target node different from current node
    my %validVIFs;
    foreach my $rule (@dataVIFRules) {
	my $vif_name = $rule->{'vif_name'};
	next unless exists $dataVIFs{$vif_name};
	my $vif = $dataVIFs{$vif_name};
	if ($rule->{'target_node'} ne $vif->{'vif_curr_node'}){
	    $validVIFs{$vif_name} = $vif unless
		exists $validVIFs{$vif_name};
	}
    }
    if ($DEBUG){
	print "Valid LIFs are \n";
	foreach (keys %validVIFs){
	    print $_, ' => ', $validVIFs{$_}->{'vif_curr_node'}, "\n";
	}
    }
    
    my %invalidVIFs;
    while (my($k, $v) = each %dataVIFs){
	$invalidVIFs{$k} = $v unless exists $validVIFs{$k};  
    }
    
    if (%invalidVIFs){
	print "Following Data VIFs does NOT  have fail over rules with different target node \n";
	print "VIF\t\tCurrent Node\n";
	while(my($k, $v) = each %invalidVIFs){
	    print $k . "\t\t" . $v->{'vif_curr_node'} . "\n";
	    $Total_issues++;
	}
    }
    
    #If data lifs and fo rules exist, but no fail over hosts are online,
    my %onlineVIFs;
    foreach my $rule (@dataVIFRules){
	next unless exists $validVIFs{$rule->{'vif_name'}};
	my $vif_name = $rule->{'vif_name'};
	my $tar_node = $rule->{'target_node'};
	if (exists $Node{$tar_node} && ($Node{$tar_node} =~ /true/i)){
	    $onlineVIFs{$vif_name} = $validVIFs{$vif_name} unless
		exists $onlineVIFs{$vif_name};
	}
    }
    
    if ($DEBUG){
	print "Target Online LIFs are \n";
	foreach (keys %onlineVIFs){
	    print $_, ' => ', $onlineVIFs{$_}->{'vif_curr_node'}, "\n";
	}
    }
    
    my %offlineVIFs;
    while (my($k, $v) = each %dataVIFs){
	$offlineVIFs{$k} = $v unless exists $onlineVIFs{$k};  
    }
    
    if (%offlineVIFs){
	print "Following Data VIFs does NOT  have fail over target node as Online\n";
	print "VIF\t\tCurrent Node\n";
	while(my($k, $v) = each %offlineVIFs){
	    print $k . "\t\t" . $v->{'vif_curr_node'} . "\n";
	    $Total_issues++;
	}
    }
    
    if (%invalidVIFs || %offlineVIFs){ return 1; }
    print "OK \n";
    return 0;
}

# Checking network fail over rules
sub checkNetworkConfig 
{
    return checkVIFs(@_) if $Opt->{'c'};
    my $err = 0;
    my $in_if = 0;
    my ($ifnl, $ifn);
    my (%ptnr, %p_ptnr);
    my (%ip, %p_ip);
    my ($link1, $link2, $url, $url_temp);
    my (@lf, @s1, @s2, @if_l);
    my ($asup_id, $ifc);
    my (%ip_failover, %p_ip_failover);
    
    printHeading ("Checking network configuration...");
    open (IFC, " $RshCommand[0] $IfconfigCommand|") ||
	die "Can't run $IfconfigCommand on $Filer[0]";

  #e0a:flags=0x2d48867<UP,BROADCAST,RUNNING,MULTICAST,TCPCKSUM> mtu 1500
  #    inet 10.61.73.165 netmask 0xffffff00 broadcast 10.61.73.255
  #    partner e0a (not in use)
  #    ether 00:a0:98:0a:3e:d1 (auto-1000t-fd-up) flowcontrol full
  #e0b:flags=0x2508866<BROADCAST,RUNNING,MULTICAST,TCPCKSUM> mtu 1500
  #    ether 00:a0:98:0a:3e:d0 (auto-unknown-cfg_down) flowcontrol full
  #lo: flags=0x1948049<UP,LOOPBACK,RUNNING,MULTICAST,TCPCKSUM> mtu 8160
  #    inet 127.0.0.1 netmask 0xff000000 broadcast 127.0.0.1
  #    ether 00:00:00:00:00:00 (VIA Provider)

    while (<IFC>)
    {
	chomp;
	my @l = split (/[ \t]+/);
        if ($l[0] ne "")
	{
	    $in_if = 1;
	    $ifn = $l[0];
	    $ifn =~ s/:$//;
	    my @f = split (/[<>]/, $l[1]);
	    my @ff = split (/,/, $f[1]);
	    foreach my $y (@ff)
	    {
		if ($y eq "VLAN" || $y eq "LOOPBACK")
		{
		    $in_if = 0;
		    last;
		}
	    }
	}
	elsif ($in_if)
	{
	    $ip{$ifn} = $l[2] if ($l[1] eq "inet");
	    $ptnr{$ifn} = $l[2] if ($l[1] eq "partner" && $l[2] ne "inet");
	    $ptnr{$ifn} = $l[3] if ($l[1] eq "partner" && $l[2] eq "inet");
	}
    }
    close (IFC);
    open (IFC, "$RshCommand[1] $IfconfigCommand|") ||
	die "Can't $RshCommand[1] $IfconfigCommand";
    while (<IFC>)
    {
	chomp;
	my @l = split (/[ \t]+/);
	if ($l[0] ne "")
	{
	    $in_if = 1;
	    $ifn = $l[0];
	    $ifn =~ s/:$//;
	    my @f = split (/[<>]/, $l[1]);
	    my @ff = split (/,/, $f[1]);
	    foreach my $y (@ff)
	    {
		if ($y eq "VLAN" || $y eq "LOOPBACK")
		{
		    $in_if = 0;
		    last;
		}
	    }
	}
	elsif ($in_if)
	{
	    $p_ip{$ifn} = $l[2] if ($l[1] eq "inet");
	    $p_ptnr{$ifn} = $l[2] if ($l[1] eq "partner" && $l[2] ne "inet");
	    $p_ptnr{$ifn} = $l[3] if ($l[1] eq "partner" && $l[2] eq "inet");
	}
    }
    close (IFC);
    #
    # Do the comparisions, flag errors
    #
    # Filer
    # %ip has interfacename => ip address
    # %ptnr has interfacename => referenced interface name/ip address
    # Partner
    # %p_ip has interfacename => ip address
    # %p_ptnr has interfacename => referenced interface name/ip address

    foreach my $k (keys %ip)
    {
	my $found = 0;
	$ip_failover{$k} = 0;
	foreach my $y (keys %p_ptnr)
	{
	    if ($p_ptnr{$y} eq $k)
	    {
		$found = 1;
		$ip_failover{$k} = 1;
		last;
	    }
	    elsif ($p_ptnr{$y} eq $ip{$k})
	    {
		$found = 1;
		$ip_failover{$k} = 1;
		last;
	    }
	}
	if (!$found)
	{
	    $err++;
	    print "$k ($ip{$k}) on $Filer[0] does not have a partner " .
		"on $Filer[1]\n";
	}
    }
    foreach my $k (keys %p_ip)
    {
	my $found = 0;
	$p_ip_failover{$k} = 0;
	foreach my $y (keys %ptnr)
	{
	    if ($ptnr{$y} eq $k)
	    {
		$found = 1;
		$p_ip_failover{$k} = 1;
		last;
	    }
	    elsif ($ptnr{$y} eq $p_ip{$k})
	    {
		$found = 1;
		$p_ip_failover{$k} = 1;
		last;
	    }
	}
	if (!$found)
	{
	    $err++;
	    print "$k ($p_ip{$k}) on $Filer[1] does not have a " .
		"partner on $Filer[0]\n";
	}
    }
    print "OK \n" unless $err;
    return 0;
}

# Given an ATM interface (not trunked) that is configured and
# node to which the interface belongs, check whether it is configured
# correctly w.r.t. its partner.
sub checkATMInterface
{
# print "$_[0] is an ATM interface, logic to check this is TBD";
# printNewLine(2);
    return 0;
}

sub checkRCfile
{
    # Irrelevant in C mode
    return 0 if $Opt->{'c'};
    my ($int,$found,$f);
    my ($pri_filer, $sec_filer);
    my (%pri, %sec, %pri_part, %sec_part);
    my $foundError = 0;
    printHeading ("Checking network config in /etc/rc");
    if (!open(RC, "$RshCommand[0] $RdrcCommand|"))
    {
	print "Can't run $RdrcCommand on $Filer[0]";
	printNewLine (1);
	return (1);
    }
    while (<RC>)
    {
	chomp;
	next if (/^#/);
	next if (/^$/);
	next if (!/^ifconfig/ && !/^hostname/);
	s/\r//g;
	my @il = split (/[ \t]+/);
	$int = $il[1];

	# Filer details
	# $pri_filer - name of primary filer 	 
	# %pri interfacename => ip address
	# %pri_part interfacename => partner interface name/IP Address

	# Secondary details
	# $sec_filer - name of secondary filer 	 
	# %sec interfacename => ip address
	# %sec_part interfacename => partner interface name/IP Address

	if ($il[0] eq "hostname")
	{
	    $pri_filer = $il[1];
	}
	elsif ($il[2] =~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
	{
	    $pri{$int} = $il[2];
	}
	elsif ($il[2] eq "partner")
	{
	}
	else
	{
	    my $kwhit = 0;
	    foreach my $kw (@Keywords)
	    {
		if ($il[2] eq $kw)
		{ 
		    $kwhit = 1;
		    last;
		}
	    }
	    $pri{$int} = resolve(0,$pri_filer, $Filer[0], $il[2], $int) 
		if (!$kwhit);
	}
	$found = 0;
	my $f;
	for ($f=0; $f <= $#il; $f++)
	{
	    next if ($il[$f] ne "partner");
	    $found = 1;
	    last;
	}
	$pri_part{$int} = $il[$f+1] if ($found);
    }
    close (RC);
	
    if (!open(RC, "$RshCommand[1] $RdrcCommand|"))
    {
	print "Can't run $RdrcCommand on $Filer[1]";
	printNewLine (1);
	return (1);
    }
    while (<RC>)
    {
	chomp;
	next if (/^#/);
	next if (/^$/);
	next if (!/^ifconfig/ && !/^hostname/);
	s/\r//g;
	my @il = split (/[ \t]+/);
	$int = $il[1];
	if ($il[0] eq "hostname")
	{
	    $sec_filer = $il[1];
	}
	elsif ($il[2] =~ /[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/)
	{
	    $sec{$int} = $il[2];
	}
	elsif ($il[2] eq "partner")
	{
	}
	else
	{
	    my $kwhit = 0;
	    foreach my $kw (@Keywords)
	    {
		if ($il[2] eq $kw)
		{
		    $kwhit = 1;
		    last;
		}
	    }
	    $sec{$int} = resolve (1,$sec_filer, $Filer[1], $il[2], $int) 
		if (!$kwhit);
	}
	$found = 0;
	my $f;
	for ($f=0; $f <= $#il; $f++)
	{
	    next if ($il[$f] ne "partner");
	    $found = 1;
	    last;
	}
	$sec_part{$int} = $il[$f+1] if ($found);
    }
    close (RC);

    my @pri_list = keys %pri;
    for (my $i=0; $i <= $#pri_list; $i++)
    {
	my $p_if = $pri_list[$i];
	$found = 0;
	foreach my $part (keys %sec_part)
	{
	    if ($sec_part{$part} eq $p_if || $sec_part{$part} eq $pri{$p_if})
	    {
		$found = 1;
		last;
	    }
	}
	if (!$found)
	{
	    print "NO PARTNER FOR $p_if ($pri{$p_if}) ON " .
		"$pri_filer IN /etc/rc\n";
	    $foundError = 1;
	    $Total_issues++;
	}
    }
    my @sec_list = keys %sec;
    for (my $i=0; $i <= $#sec_list; $i++)
    {
	my $s_if = $sec_list[$i];
	$found = 0;
	foreach my $part (keys %pri_part)
	{
	    if ($pri_part{$part} eq $s_if || $pri_part{$part} eq $sec{$s_if})
	    {
		$found = 1;
		last;
	    }
	}
	if (!$found)
	{
	    print "NO PARTNER FOR $s_if ($sec{$s_if}) ON " .
		"$sec_filer in /etc/rc\n";
	    $foundError = 1;
	    $Total_issues++;
	}
    }
    print "OK\n" if (!$foundError);
}

sub resolve
{
    my $index = shift;
    my $filer_name = shift;
    my $filer_addr = shift;
    my $name = shift;
    my $int_name = shift;
    
    $name =~ s/\`hostname\`/$filer_name/ if ($name =~ /\`hostname\`/);
    if (!open (HOSTS, "$RshCommand[$index] $RdhostsCommand|"))
    {
	print "Can't run $RdhostsCommand on $Filer[$index]";
	printNewLine (1);
	return (0);
    }
    while (<HOSTS>)
    {
	chomp;
	next if (/^\#/);
	next if (/^$/);
	next if (!/$name/);
	s/\r//g;
	my @hl = split (/[ \t]+/);
	close (HOSTS);
	return ($hl[0]);
    }

    print "No entry for $name in /etc/hosts file ON " .
	"$filer_name. $int_name references this entry " .
	"in /etc/rc file \n";
    $Total_issues++;
    return undef;
}

# print new line chars
sub printNewLine
{
    my $i;
    for ($i = 0; $i < $_[0]; $i++) {
	if ($ActAsCgi) {
	    print "<BR>";
	}
	else {
	    print "\n";
	}
    }
}

sub printHeading
{
    if ($ActAsCgi) {
	print "<H3>$_[0]</H3>";
    }
    else {
	print "\n$_[0]\n\n";
    }
}

sub printUsage
{
    my $base_dir = '';
    if ($0 =~ /(.*)([\/|\\])(.*)/) { 
	$base_dir = $1 . $2;
    }
    my $hlpFile = $base_dir . 'README.pod'; 
    if (! $ActAsCgi) {
	pod2usage({-exitval=>1,
		   -verbose=>0,
		   -input=>$hlpFile});
    }
}

sub printAbout
{

    print "<H1>About NetApp HA Configuration Checker</H1>
<H3>Copyright &copy; 2001-2010 NetApp, Inc. All rights reserved.</H3>
<H3>Version $MyVersion</H3>
This tool was developed by NetApp.<BR>
It works on NetApp&reg; HA configurations running Data Ontap&#153; 5.3.2 and later releases.
";
}


sub printHelp
{
    print "<H1>Help for NetApp HA Configuration Checker</H1>
HA Configuration Checker is a tool that detects errors
of a NetApp HA controller configuration.<BR>
It uses rsh to talk to the partners of the HA configuration.
<P>
Errors:
<LI>
If services licensed on the two nodes are not identical,
some services may be not be available in takeover mode.</LI>
<LI>
If options that should be identical in a cluster are not identical,
some options may be altered in takeover mode.</LI>
<LI>
If network interfaces are improperly configured, takeover of
these interfaces will fail, causing clients that access them
to lose connectivity in takeover mode.</LI>
<P>
Warnings:
<LI>
Data ONTAP versions on the two HA nodes are not identical.</LI>
<LI>
HA is licensed, but takeover capability is disabled.</LI>
<P>
Sometimes rsh commands issued to a filer do not complete.<BR>
This may happen because a node is down or is not reachable from
the client that is running this script.<BR>
Click your browser's Stop button to recover.
";
}
