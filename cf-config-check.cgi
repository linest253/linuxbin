#!/usr/bin/perl
use Getopt::Std;
# NOTE: This script supports all Data ONTAP releases >= 5.3.2 and <= 7.x
$myVersion = "1.4.4";

$rshCommand[0] = "rsh -l :";
$rshCommand[1] = "rsh -l :";
$versionCommand = "version";
$licenseCommand = "license";
$optionsCommand = "options";
$ifconfigCommand = "ifconfig -a";
$cfStatusCommand = "cf status";
$hostnameCommand = "\"priv set -q advanced; hostname\"";
$cfPartnerCommand = "cf partner";
$fcpcfModeCommand = "fcp show cfmode";
$rdrcCommand = "rdfile /etc/rc";
$rdhostsCommand = "rdfile /etc/hosts";
@keywords = ("alias", "-alias", "netmask", "netmask", "mtusize", "mediatype", "flowcontrol", "trusted", "untrusted", "wins", "-wins");

$script = $ENV{'SCRIPT_NAME'};
$ActAsCgi = defined( $ENV{ 'GATEWAY_INTERFACE' });
$total_issues = 0;
$WINDOWS = 0;
$WINDOWS = 1 if ($^O eq "MSWin32");

#main -- parse input data and call subroutines to do the real work.
if ( $ActAsCgi )
{
# run as cgi script
  # Send error messages to the user, not system log
  open(STDERR,'<&STDOUT');  $| = 1;
  print "Content-type: text/html\n\n";
  print "<HTML><HEAD><TITLE>NetApp HA Configuration Checker</TITLE></HEAD></HTML>";

  use CGI;
  &CGI::ReadParse(*input);

  if ($input{'button'}) 
  {
    if ($input{'button'} =~ "About") 
    {
      printAbout();
    }
    if ($input{'button'} =~ "Help") 
    {
      printHelp();
    }
    if ($input{'button'} =~ "Check Configuration") 
    {
      if ($input{'shell'})
      {
        $rshCommand[0] =~ s/^rsh/$input{'shell'}/;
        $rshCommand[1] =~ s/^rsh/$input{'shell'}/;
      }
      elsif ($input{'proto'} eq "ssh")
      {
        $rshCommand[0] =~ s/^rsh/ssh/;
        $rshCommand[1] =~ s/^rsh/ssh/;
      }
      if ($input{'filer1'} && $input{'filer2'} && 
	  ($input{'filer1'} ne $input{'filer2'}))
      {
	$filer[0] = $input{'filer1'};
	if ($input{'uid1'}) 
        {
	  $rshCommand[0] =~ s/:/$input{'uid1'}:/;
          if ($input{'shell'} eq "rsh")
          {
	    if ($input{'passwd1'}) 
            {
	      $rshCommand[0] =~ s/:/:$input{'passwd1'}/;
	    }
          }
          else
          {
            $rshCommand[0] =~ s/://g;
          }
        }
        else
        {
          $rshCommand[0] =~ s/ -l ://;
        }
	$filer[1] = $input{'filer2'};
	if ($input{'uid2'}) 
        {
	  $rshCommand[1] =~ s/:/$input{'uid2'}:/;
	  if ($input{'proto'} eq "rsh" && $input{'passwd2'}) 
          {
	    $rshCommand[1] =~ s/:/:$input{'passwd2'}/;
	  }
          else
          {
            $rshCommand[1] =~ s/://g;
          }
        }
        else
        {
          $rshCommand[1] =~ s/-l ://;
        }
        $rshCommand[0] .= " $filer[0]";
        $rshCommand[1] .= " $filer[1]";
	print "<H1>Checking NetApp HA system configuration: $filer[0] and $filer[1]</H1>";
	if (&checkLogins == 0) {
	  if (&checkOSversions == 0) {
	    if (&checkLicenseMismatch == 0) {
	      if (&checkClusterIdentity == 0) {
		if (&checkCfStatus == 0) {
		  if (&checkFCPcfmodeMismatch == 0) {
		    if (&checkOptionsMismatch == 0) {
		      if (&checkNetworkConfig == 0) {
			&checkRCfile;
                      }
		    }
		  }
		}
	      }
	    }
	  }
	}
        print "<p>No HA configuration issues found." if (!$total_issues);
        print "<p>HA configuration issue(s) found above. Please correct them and rerun this script." if ($total_issues);
	print "<p>Done." 
      }
      else {
	&showForm;
      }
    }
  }
  else {
    &showForm;
  }
}

else {
# run as a command line perl script
  getopts ('sr:lD');
  $SSH = 0;
  $SSH = 1 if ($opt_s);
  if ($opt_r || $opt_s)
  {
    $opt_r = "ssh" if (!$opt_r);
    $rshCommand[0] =~ s/^rsh/$opt_r/;
    $rshCommand[1] =~ s/^rsh/$opt_r/;
  }
  $DEBUG = 0;
  $DEBUG = 1 if ($opt_D);
  $LOGIN = 0;
  $LOGIN = 1 if ($opt_l);
  if ($opt_s && $opt_l)
  {
    print STDERR "Cannot use -s and -l at the same time\n";
    exit (99);
  }
  if ($#ARGV != 1) 
  {
    printUsage();
    exit;
  }
  if ($LOGIN)
  {
    $filer[0] = $ARGV[0];
    $rshCommand[0] = "rsh -l " if ($WINDOWS);
    print "$filer[0] rsh login: ";
    chomp($uid1 = <STDIN>);
    $uid1 =~ s/\r//g;
    system "stty -echo" if (!$WINDOWS);
    print "Password: ";
    chomp($passwd1 = <STDIN>);
    $passwd1 =~ s/&/\\&/g;
    $passwd1 =~ s/\r//g;
    print "\n";
    system "stty echo" if (!$WINDOWS);
    $rshCommand[0] = "rsh $filer[0] -l ".$uid1.":".$passwd1;
    $filer[1] = $ARGV[1];
    $rshCommand[1] = "rsh -l " if ($WINDOWS);
    print "$filer[1] rsh login: ";
    chomp($uid2 = <STDIN>);
    $uid2 =~ s/\r//g;
    system "stty -echo" if (!$WINDOWS);
    print "Password: ";
    chomp($passwd2 = <STDIN>);
    $passwd2 =~ s/&/\\&/g;
    $passwd2 =~ s/\r//g;
    print "\n";
    system "stty echo" if (!$WINDOWS);
    $rshCommand[1] = "rsh $filer[1] -l $uid2:$passwd2";
  }
  else
  {
    $filer[0] = $ARGV[0];
    $filer[1] = $ARGV[1];
    $rshCommand[0] =~ s/-l :/$filer[0]/;
    $rshCommand[1] =~ s/-l :/$filer[1]/;
  }
    print "== NetApp HA Configuration Checker v$myVersion ==\n\n";
    if (&checkLogins == 0) {
      if (&checkOSversions == 0) {
        if (&checkLicenseMismatch == 0) {
          if (&checkClusterIdentity == 0) {
            if (&checkCfStatus == 0) {
	      if (&checkFCPcfmodeMismatch == 0) {
	        if (&checkOptionsMismatch == 0) {
	          if (&checkNetworkConfig == 0) {
		    &checkRCfile;
                  }
		}
              }
            }
          }
        }
      }
    }
    print "No HA configuration issues found.\n" if (!$total_issues);
    print "HA configuration issue(s) found above. Please correct them and rerun this script.\n" if ($total_issues);
    print "Done.\n";
}


#present html form for submitting names of HA nodes
sub showForm {
  print <<EOF;
  <CENTER>
  <SCRIPT>
  function set_login_field()
  {
    if (document.CF_CHECK.proto.selectedIndex == 1)
    {
      document.CF_CHECK.passwd1.disabled = 1;
      document.CF_CHECK.passwd2.disabled = 1;
      document.CF_CHECK.shell.value = "ssh";
    }
    else
    {
      document.CF_CHECK.passwd1.disabled = 0;
      document.CF_CHECK.passwd2.disabled = 0;
      document.CF_CHECK.shell.value = "rsh";
    }
  }
  </SCRIPT>
  <H1>NetApp HA Configuration Checker</H1>
  <FORM NAME="CF_CHECK" METHOD="POST"
  ACTION=$script>
  <INPUT TYPE=submit NAME=button VALUE="About">
  <INPUT TYPE=submit NAME=button VALUE="Help">
  <hr>
  Protocol: <select NAME="proto" onChange="set_login_field()"><option value="rsh" selected>rsh</option>
  <option value="ssh">ssh</option></select>
  <p>Remote Shell: <input name="shell" value="rsh">
  <PRE>
<H3>First HA Node:</H3>
Hostname or IP address <INPUT NAME=filer1>
Account  <INPUT NAME=uid1>
Password <INPUT TYPE="password" NAME=passwd1>
    <P>
<H3>Second HA Node:</H3>
Hostname or IP address <INPUT NAME=filer2>
Account  <INPUT NAME=uid2>
Password <INPUT TYPE="password" NAME=passwd2>
    <P>
  </PRE>
    <INPUT TYPE=submit NAME=button VALUE="Check Configuration">
  </FORM>
  </CENTER>
EOF
}

# Can we rsh into the nodes?
sub checkLogins {
  printHeading("Checking rsh logins ...") if (!$opt_s);
  printHeading("Checking ssh logins ...") if ($opt_s);
  for ($fn = 0; $fn < 2; $fn++) {
    $foundFilerData = 0;
    if (! open(FILERDATA, "$rshCommand[$fn] $versionCommand |") ) {
      print "Can't run $versionCommand on $filer[$fn]";
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
      $rsh_name = "rsh" if (!$opt_s);
      $rsh_name = "ssh" if ($opt_s);
      print "Cannot $rsh_name into $filer[$fn]";
      printNewLine(1);
      exit (1);
    }
  }
  print "OK"; printNewLine(1);
  return 0;
}

# look for OS version mismatch
sub checkOSversions {
my   $foundError = 0;
  printHeading("Checking Data ONTAP versions...");
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $versionCommand |") ) {
      print "Can't run $versionCommand on $filer[$fn]";
      printNewLine(1);
      return 1;
    }
    else {
      $lineNumber = 0;
      while (<FILERDATA>) {
	if ($DEBUG) { print; printNewLine(1);}

        # Can we work with this OS ?
        if ($lineNumber == 0 && ! m/^NetApp.*$/ && !m/^Data ONTAP Release.*$/) {
          print "$filer[$fn] is not a NetApp storage controller";
          printNewLine(1);
          return 1;
        } 
        if ($lineNumber == 0 && $_ =~ /^NetApp Release (\d+)\.(\d+)\.(\d+).*$/) {
          if ($1 < 5) {
            print "cf-config-check.cgi does not support Data ONTAP releases < 5.3.2";
            printNewLine(1);
            print "$filer[$fn] is running $_";
            printNewLine(1);
            return 1;
          }
          if ($1 == 5) {
            if ($2 < 3 || ($2 == 3 && $3 < 2)) {
              print "cf-config-check.cgi does not support Data ONTAP releases < 5.3.2";
              printNewLine(1);
              print "$filer[$fn] is running $_";
              printNewLine(1);
              return 1;
            }
            # if valid 5.x release use rc_toggle_basic
            rcToggleBasicCmds();
          }
          if ($1 > 7) {
            print "cf-config-check.cgi version $myVersion does not support ";
            print "NetApp Releases > 7.x";
            printNewLine(1);
            print "$filer[$fn] is running $_";
            printNewLine(1);
            print "Please download the latest version of cf-config-check.cgi from";
            printNewLine(1);
            if ($ActAsCgi) {
              print "<a href=\"http://now.netapp.com/NOW/tools/\">http://now.netapp.com/NOW/tools/</a>";
            }
            else {
              print "http://now.netapp.com/NOW/tools/";
            }
            printNewLine(1);
            return 1;
          }
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
            $total_issues++;
	  }
	}
      }
    }
    close FILERDATA;
    if ($DEBUG) { printNewLine(1); };
  }
  if ($foundError == 0) {
    print "OK"; printNewLine(1);
  }
  return 0;
}

# for pre 6.0 releases, use rc_toggle_basic instead of "priv set .."
# Note: We assume that the nodes are not in rc_toggle_basic mode when we start.
sub rcToggleBasicCmds {
# $licenseCommand = "\"rc_toggle_basic; registry walk options.license; rc_toggle_basic\"";
# $ifconfigCommand = "\"rc_toggle_basic; registry walk status.if; rc_toggle_basic\"";
  $hostnameCommand = "\"rc_toggle_basic; hostname; rc_toggle_basic\"";
}

# look for license mismatch
sub checkLicenseMismatch {
  my $li;
  my %lic1 = ();
  my %lic2 = ();
  my $foundError = 0;
  printHeading("Checking licenses...");
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $licenseCommand |") ) {
      print "Can't run $licenseCommand on $filer[$fn]";
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
      print "$k exists on $filer[0], but not on $filer[1]";
      printNewLine(1);
      $foundError = 1;
      $total_issues++;
    }
  }
  foreach my $k (keys (%lic2))
  {
    if (!exists ($lic1{$k}))
    {
      print "$k exists on $filer[1], but not on $filer[0]\n";
      $foundError = 1;
      $total_issues++;
    }
  }
  print "OK\n" if (!$foundError);
  return 0;
}

# do the 2 nodes belong to the same HA configuration?
sub checkClusterIdentity {
  printHeading("Checking HA configuration identity...");
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $hostnameCommand |") ) {
      print "Can't run $hostnameCommand on $filer[$fn]";
      printNewLine(1);
      return 1;
    }
    else {
      while (<FILERDATA>) {
        chomp;
        if ($DEBUG) { print; printNewLine(1); }
        $hostName[$fn] = $_;
      }
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $cfPartnerCommand |") ) {
      print "Can't run $cfPartnerCommand on $filer[$fn]";
      printNewLine(1);
      return 1;
    }
    else {
      while (<FILERDATA>) {
        chomp;
        if ($DEBUG) { print; printNewLine(1); }
        $partnerName[$fn] = $_;
      }
    }
    if ($DEBUG) { printNewLine(1); }
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
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $cfStatusCommand |") ) {
      print "Can't run $cfStatusCommand on $filer[$fn]";
      printNewLine(1);
      return 1;
    }
    else {
      while (<FILERDATA>) {
        if ($DEBUG) { print; printNewLine(1); }
        if (m/Cluster disabled\./) {
          $foundError = 1;
          $total_issues++;
        }
      }
    }
    close FILERDATA;
    if ($DEBUG) { printNewLine(1); }
  }
  if ($foundError == 0) {
      print "OK"; printNewLine(1);
  }
  else {
    print "WARNING: The cf service is licensed but disabled.";
          printNewLine(1);
  }
  return 0;
}

# is fcp cfmode set the same?
sub checkFCPcfmodeMismatch {
  my $foundError = 0;
  #for ($fn = 0; $fn < 2; $fn++) {
  #  if (!open(FILERDATA, "$rshCommand[$fn] $filer[$fn] $licenseCommand|") ) {
  #    print "Can't run $licenseCommand on $filer[$fn]";
  #    printNewLine(1);
  #    return 1;
  #  }
  #  while (<FILERDATA>) {
  #    if(m/options.license.fcp=off/) {
  #	 return 0;
  #    }
  #  }
  #}
  printHeading("Checking fcp cfmode settings...");
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if ($^O ne "MSWin32")
    {
      if (!open(FILERDATA, "$rshCommand[$fn] $fcpcfModeCommand 2>/dev/null |") ) {
        print "Can't run $fcpcfModeCommand on $filer[$fn]";
        printNewLine(1);
        return 1;
      }
      else {
        $fcpcfmodestring[$fn] = <FILERDATA>;
        close FILERDATA;
        if ($fcpcfmodestring[$fn] !~ /fcp show cfmode/) {
          print "N/A\n";
          return 0;
        }
      }
    }
    else
    {
      if (!open(FILERDATA, "$rshCommand[$fn] $fcpcfModeCommand |") ) {
        print "Can't run $fcpcfModeCommand on $filer[$fn]";
        printNewLine(1);
        return 1;
      }
      else {
        $fcpcfmodestring[$fn] = <FILERDATA>;
        close FILERDATA;
        if ($fcpcfmodestring[$fn] !~ /fcp show cfmode/) {
          print "N/A\n";
          return 0;
        }
      }
    }
    if ($DEBUG) { print $fcpcfmodestring[$fn]; printNewLine(1); }
  }
  close FILERDATA;
  if ($fcpcfmodestring[0] ne $fcpcfmodestring[1]) {
    $foundError = 1;
    $total_issues++;
  }
  if ($foundError == 0) {
      print "OK"; printNewLine(1);
  }
  else {
    print "FCP cfmode mismatch on HA configuration."; printNewLine(1);
  }
  return 0;
}

# look for options mismatch.
sub checkOptionsMismatch {
  my $foundError = 0;
  printHeading("Checking options...");
  for ($fn = 0; $fn < 2; $fn++) {
    if ($DEBUG) {
      print "$filer[$fn] :-";
      printNewLine(1);
    }
    if (! open(FILERDATA, "$rshCommand[$fn] $optionsCommand |") ) {
      print "Can't run $optionsCommand on $filer[$fn]";
      printNewLine(1);
      return 1;
    }
    else {
      $listIndex = 0;
      while (<FILERDATA>) {
	if (m/same/) {
	  s/\(.*\)//;
	  if ($DEBUG) { print; printNewLine(1);}
	  if ($fn == 0) {
	    $optionsList[$listIndex++] = $_;
	  }
	  else {
	    $listIndex = 0;
	    $foundOption = 0;
	    while ($listIndex <= $#optionsList &&  $foundOption == 0) {
	      if ($optionsList[$listIndex] eq $_) {
		$optionsList[$listIndex] = "ERASED";
		$foundOption = 1;
	      }
	      $listIndex++;
	    }
	    if ($foundOption == 0) {
	      $foundError = 1;
	      print "Option $_ on $filer[1] has no match on $filer[0]";
              printNewLine(1);
	    }
	  }
	}
      }
    }
    close FILERDATA;
    if ($DEBUG) { printNewLine(1); }
  }
  for ($listIndex = 0; $listIndex <= $#optionsList; $listIndex++) {
    if ($optionsList[$listIndex] ne "ERASED") {
      $foundError = 1;
      $total_issues++;
      print "Option $optionsList[$listIndex] on $filer[0] has no match on $filer[1]";
      printNewLine(1);
    }
  }
  if ($foundError == 0) {
    print "OK"; printNewLine(1);
  }
  return 0;
}


sub checkNetworkConfig 
{
  my $err = 0;
  my $in_if = 0, $ifn;
  my %ptnr, %p_ptnr;
  %ip = (), %p_ip = ();
  my $link1, $link2, $url, $url_temp;
  my @lf, @s1, @s2, @if_l;
  my $asup_id, $ifc;
  %ip_failover= (), %p_ip_failover = ();

  printHeading ("Checking network configuration...");
  open (IFC, " $rshCommand[0] $ifconfigCommand|") || die "Can't run $ifconfigCommand on $filer[0]";
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
  open (IFC, "$rshCommand[1] $ifconfigCommand|") ||
	die "Can't $rshCommand[1] $ifconfigCommand";
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
      print "$k ($ip{$k}) on $filer[0] does not have a partner on $filer[1]\n";
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
      print "$k ($p_ip{$k}) on $filer[1] does not have a partner on $filer[0]\n";
    }
  }
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

# Given an interface (not trunked) that is configured and 
# node to which the interface belongs, check whether it is configured
# correctly w.r.t. its partner.
sub checkInterface
{
  local($foundError) = 0;
  $localInterface = $_[0];
  $localIndex = $_[1];
  $partnerIndex = 1 - $localIndex;

  # every local interface that has a local address assigned must have
  # a unique matching partner interface on partner node.

  if ($addr ne "") {
    $retval = findPartnerInterface($partnerIndex, $localInterface, $addr);
    if ($retval eq "") {
      $foundError = 1;
      print "$localInterface on $filer[$localIndex] will not be taken over because it does not have a matching interface on partner node $filer[$partnerIndex]";
      printNewLine(1);
    }
    else {

      # local and partner interfaces should have same subnet, ipspace, mediatype, type and nfo values

      if ($hashArr[$partnerIndex]{$retval} =~ /^addr=[^, ]*,?[^, ]*,?([^,; ]*).*mediatype=([^ ]*).*$/) {
        if ($1 ne "" && $subnet ne $1) {
          $foundError = 1;
          print "$localInterface on $filer[$localIndex] may not be taken over correctly because it is on subnet $subnet, whereas partner interface $retval on $filer[$partnerIndex] is on subnet $1";
	  printNewLine(1);
        }
        if ($mediatype ne $2) {
          $foundError = 1;
          print "$localInterface on $filer[$localIndex] may not be taken over correctly because it has mediatype $mediatype, whereas partner interface $retval on $filer[$partnerIndex] has mediatype $2";
	  printNewLine(1);
        }        
      }
      if ($hashArr[$partnerIndex]{$retval} =~ /^.*ipspace=([^ ]*).*$/) {
        if ($ipspace ne $1) {
          $foundError = 1;
          print "$localInterface on $filer[$localIndex] may not be taken over correctly because it belongs to ipspace $ipspace, whereas partner interface $retval on $filer[$partnerIndex] belongs to ipspace $1";
	  printNewLine(1);
        } 
      }
      if ($hashArr[$partnerIndex]{$retval} =~ /^.*nfo=([^ ]*).*$/) {
        if ($nfo ne $1) {
          $foundError = 1;
          print "$localInterface on $filer[$localIndex] may not be taken over correctly because it has nfo option set to $nfo, whereas partner interface $retval on $filer[$partnerIndex] has nfo option set to $1";
          printNewLine(1);
        }
      }
      if ($hashArr[$partnerIndex]{$retval} =~ /^.*\stype=([^ ]*).*$/) {
	if ($type ne $1) {
	  $foundError = 1;
	  print "$localInterface on $filer[$localIndex] may not be taken over correctly because it is of type $type, whereas partner interface $retval on $filer[$partnerIndex] is of type $1";
	  printNewLine(1);
	}
      }
      else {
	if ($type ne "") {
	  $foundError = 1;
	  print "$localInterface on $filer[$localIndex] may not be taken over correctly because it is of type $type, whereas partner interface $retval on $filer[$partnerIndex] is of type ";
	  printNewLine(1);
	}
      }
    }
  }

  # every local interface that has a partner interface/address assigned 
  # must have a unique matching local interface/address on partner node

  if ($partner ne "" || ($partneraddr ne "" && $partneraddr ne "0.0.0.0")) {
    $retval = findLocalInterface($partnerIndex, $partner, $partneraddr);
    if ($retval eq "") {
      $foundError = 1;
      print "Takeover of $partner $partneraddr will fail because this interface does not exist on partner node $filer[$partnerIndex]";
      printNewLine(1);
    }
  }

  if ($foundError) {
    printNewLine(1);
  }
  return $foundError;

}

# Given the index into hashArr, and an interface and an addr
# find unique matching partner interface/address
sub findPartnerInterface
{
  $found = 0;
  foreach (keys(%{$hashArr[$_[0]]})) {
    $hashArr[$_[0]]{$_} =~ /^.*partner=([^ ]*).*partneraddr=([^ ]*).*$/;
    if ($1 eq $_[1]) {
      if ($2 ne "" && $2 ne "0.0.0.0" && $2 ne $_[2]) {
        print "$_ on $filer[$_[0]] is the partner interface for $1 on $filer[1-$_[0]], but the partner address $2 and local address $_[2] are not identical.";
	printNewLine(1);
        return "";
      }
      $found++;
      $retval = $_;
    }
    elsif ($2 eq $_[2]) {
      if ($1 ne "" && $1 ne $_[1]) {
        print "$_ on $filer[$_[0]] has partner address $2, which corresponds to local address $_[2] for interface $_[1] on $filer[1-$_[0]]; but the partner interface $1 in $_ and local interface $_[1] are not identical.";
	printNewLine(1);
        return "";
      }
      $found++;
      $retval = $_;
    }
  }
  if ($found == 0) {
    return "";
  }
  elsif ($found == 1) {
    return $retval;
  }
  else {
    print "There is more than 1 partner interface on $filer[$_[0]] for local interface $_[1] on $filer[1-$_[0]].";
    printNewLine(1);
    return "";
  }
}

# Given the index into hashArr, and an interface and an addr
# find unique matching local interface/address
sub findLocalInterface
{
  $found = 0;
  foreach (keys(%{$hashArr[$_[0]]})) {
    if ($_[1] ne "") {
      if ($_ eq $_[1]) {
        if ($_[2] ne "" && $_[2] ne "0.0.0.0" && $hashArr[$_[0]]{$_} =~ /^addr=([^, ]*).*$/) {
          if ($_[2] ne $1) {
            print "Local address $1 for interface $_[1] on partner $filer[$_[0]] is not same as partner address $_[2] for partner interface $_ on $filer[1-$_[0]]";
	    printNewLine(1);
            return "";
          }
        }
        $found++;
        $retval = $_;
      }
    }
    else {
      if ($hashArr[$_[0]]{$_} =~ /^addr=([^, ]*).*$/) {
        if ($_[2] eq $1) {
          $found++;
          $retval = $_;
        }
      }
    }
  }
  if ($found == 0) {
    return "";
  }
  elsif ($found == 1) {
    return $retval;
  }
  else {
    print "More than 1 interface has local address $_[2] on partner";
    printNewLine(1);
    return "";
  }
}
sub checkRCfile
{
  my $int,$found,$f;
  my $pri_filer, $sec_filer;
  my %pri, %sec, %pri_part, %sec_part;
  my $foundError = 0;

  printHeading ("Checking network config in /etc/rc");
  if (!open(RC, "$rshCommand[0] $rdrcCommand|"))
  {
    print "Can't run $rdrcCommand on $filer[0]";
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
      foreach my $kw (@keywords)
      {
        if ($il[2] eq $kw)
        { 
          $kwhit = 1;
          last;
        }
      }
      $pri{$int} = resolve (0,$pri_filer, $filer[0], $il[2]) if (!$kwhit);
    }
    $found = 0;
    for ($f=0; $f <= $#il; $f++)
    {
      next if ($il[$f] ne "partner");
      $found = 1;
      last;
    }
    $pri_part{$int} = $il[$f+1] if ($found);
  }
  close (RC);
  if (!open(RC, "$rshCommand[1] $rdrcCommand|"))
  {
    print "Can't run $rdrcCommand on $filer[1]";
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
      $kwhit = 0;
      foreach my $kw (@keywords)
      {
        if ($il[2] eq $kw)
        {
          $kwhit = 1;
          last;
        }
      }
      $sec{$int} = resolve (1,$sec_filer, $filer[1], $il[2]) if (!$kwhit);
    }
    $found = 0;
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
      print "NO PARTNER FOR $p_if ($pri{$p_if}) ON $pri_filer IN /etc/rc\n";
      $foundError = 1;
      $total_issues++;
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
      print "NO PARTNER FOR $s_if ($sec{$s_if}) ON $sec_filer in /etc/rc\n";
      $foundError = 1;
      $total_issues++;
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
  $name =~ s/\`hostname\`/$filer_name/ if ($name =~ /\`hostname\`/);
  if (!open (HOSTS, "$rshCommand[$index] $rdhostsCommand|"))
  {
    print "Can't run $rdhostsCommand on $filer[$index]";
    printNewLine (1);
    return (0);
  }
  while (<HOSTS>)
  {
    chomp;
    next if (/^#/);
    next if (/^$/);
    next if (!/$name/);
    s/\r//g;
    my @hl = split (/[ \t]+/);
    close (HOSTS);
    return ($hl[0]);
  }
}
# print new line chars
sub printNewLine
{
  local($i);
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
  if (! $ActAsCgi) {
    print "Usage: $0 [-s] [-r shell] [-l] <name/IP addr of 1st node> <name/IP addr of 2nd node>\n";
    print "If running Data ONTAP 5.x, rc_toggle_basic must be off.\n";
  }
}

sub printAbout
{

  print "<H1>About NetApp HA Configuration Checker</H1>
<H3>Copyright &copy; 2001-2005 NetApp, Inc. All rights reserved.</H3>
<H3>Version $myVersion</H3>
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
