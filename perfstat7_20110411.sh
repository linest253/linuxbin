#!/bin/sh

# Note, some Unix's want the posix version below
###!/usr/bin/posix/sh
# 
# This script is provided "as is" it is
# not warranted but may be supported on a limited basis
# by Network Appliance.
#
### -- Brief Change History -- ###
# v7.36 04-20-11: Added option to test version mapping
# v7.35 04-01-11: Many changes:
#                 Added AWR report collection
#                 Disable mii-tool collection for newer Linux kernels (2.6.17+)
#                 Added -w option
#                 Added domain_stats collection
#                 Added support for Interix os (Windows SUA)
#                 kill_procs() cleanup process tree
#                 Fixed bug with sysstat -m collection on +8 core systems
#                 Improved the robustness of kill_procs routine (burt 386802)
#                 Added toe status 
#                 Changed tmpdir from /tmp/perfstat/$$ to /tmp/perfstat.$$
#                 Fixed bug with Oracle statspack collection from RHEL5
# v7.32 12-15-08: Windows maintenance release
#                 Removed 'snap list -q' from data collection
# v7.31 12-03-08: Removed restrictions on sktrace specifications
#                 Changed ESX Server terminology in help menu
#                 Added sasadmin commands
#                 Don't collect sysstat_1sec if -t == 1
# v7.30 08-04-08: Added support for vmware data collection to/from an ESX server
#                 Standardized timestamp formats
#                 Enhanced support for IC.0
#                 Added support for sktrace data collection
#                 Added -K option (full stutter statit)
#                 Added command logging for those commands that take >= 60 seconds to execute
#                 Added logic for intelligently choosing a timestampping mechanism
#                 Collect Linux multipath info with -d option (dry run) 
#                 Fixed -e and -E options
#                 Corrected syntax on 'sar' commands for RHEL5
# v7.14 09-10-07: Added the -s option to specify additional SEND_ARGs to rsh/ssh
#                 Improved ability to include/exclude commands based on version info
#                 Rebuild vsm exclusion list more frequently
#                 Added storage show -a and A-SIS data collection
#                 Added UNIX dependency checker
# v7.13 04-11-07: Added the -V option to skip vfiler data collection
#                 Fixed condition where perfstat would hang when using ssh to wrfile stats preset file
#                 Added output of '/etc/SuSE-release' and 'aggr show_space'
#                 Added 'flexcache hist' commands back in ONTAP 7.0.5+
# v7.12 12-14-06: Added ability to parse both forms of stats output and convert them to the post 7.2 format
#                 Fixed conditions for which statit is disabled
# v7.11 11-15-06: Fixed vfiler run syntax for nfsstats
# v7.10 11-13-06: Updated support for NA Support Consoles, additional dependency checks (statspack / Linux sysstat),
#                 fixed pretend mode, build and use stats objects white and black lists.
# v7.01 08-15-06: Additional CM commands, and Linux-FCP commands. 
# v7.00 08-04-06: Changed the running time, trimmed total number of commands being rsh'd, added functionality  
#                 to workaround qtree stats bugs and vsm destinations
# v6.50 07-26-06: Updated iscsi commands, removed `qtree stats` and `stats qtree` and `stats` not run on 6.5*
# v6.49 07-21-06: Additional commands: Doesn't run qtree stats if vsm destinations exist
# v6.48 07-14-06: Additional commands: Fixed vfiler issue
# v6.47 04-07-06: Additional per protocol stats
# v6.46 03-10-06: Add cifs & storage commands. Fix problem with -E option.
# v6.45 02-15-06: Timestamp stats,  remove spin
# v6.42 01-06-06: Minor cleanup
# v6.41 12-01-05: Fix vfiler rdfiles
# v6.40 11-14-05: Better DOT version detection.  Fix problem with raid commands.
# v6.39 10-14-05: Support -F and -h concurrently
# v6.38 10-05-05: FlexCache data collection
# v6.37 09-12-05: Timestamp profile data names
# v6.36 08-24-05: Additional cifs data for vfilers
# v6.35 08-18-05: Fix problem with fixed stats ID
# v6.34 08-08-05: Remove prof free
# v6.32 07-13-05: Minor cleanup
# v6.31 06-20-05: Add NFS monitor option
# v6.30 06-13-05: Minor cleanup
# v6.29 06-09-05: Used fixed stats ID
# v6.28 06-01-05: Update oracle statspack support
# v6.27 05-20-05: Fix client only mode
# v6.26 05-13-05: Remove disk_stat, add priority
# v6.25 03-28-05: Minor cleanup
# v6.24 03-11-05: Better license check in pre-6.5 ontap
# v6.23 03-09-05: Added linux nfsstat
# v6.22 02-17-05: Fix iscsi-ls,iostat,sar paths in Linux
# v6.21 02-14-05: Don't do 'stats' on ontap6.5
# v6.20 01-31-05: Minor rework. Parallelize rsh calls. Add more AIX device info.
# v6.11 12-20-04: Clarify profile usage.
# v6.10 12-08-04: Add AIX device info, fix ontap version check, OpenBSD support
# v6.07 10-28-04: Fix -b/-e, pretend, sysstat -M
# v6.06 09-28-04: Histo interval implies no_stutter_statit; FreeBSD cleanup, timestamp to bg files
# v6.05 09-14-04: Add histo_interval option.
# v6.04 09-07-04: Add exclude option.
# v6.03 09-02-04: Fix license issue. Misc cleanup.
# v6.02 09-01-04: Resolve issue with killing vif stat processes.  Reintroduce no stutter statit.
# v6.00 08-03-04: Major rework
# v5.31 06-23-04: vmstat for all unixes, snapmirror log fix
# v5.30 06-16-04: Added -i, -c; New header format; Error log; Misc Cleanups 
# v5.23 03-23-04: More minor clean up header on client background output.
# v5.22 03-19-04: Add hp/ux commands and config files
# v5.21 03-15-04: Clean up header on client background output.
# v5.20 02-18-04: Several changes:
#                 - Some minor reordering, iscsi additions
#                 - Convert stutter sysstat to simply sysstat 1
#                 - Converted stutter statit to 1/2 full + 1/2 stutter
# v5.13 02-16-04: Add Solaris ndd gets for ge/ce/hme/qfe/eri
# v5.12 01-30-04: Add raid_config commands
# v5.11 12-02-03: Some Linux cleanup/enhancements.
# v5.10 11-10-03: Fix priv set command.
# v5.09 10-28-03: Add hp/ux iscsi stats.
# v5.08 09-11-03: Fix stutter_statit bugs.  Add -i option.
# v5.07 07-25-03: Add mount to prestat_unix.  Remove -n outputs. Cleanup output.
# v5.06 07-23-03: Don't print out -l options
# v5.05 07-22-03: Add version output at top.  Remove wafl_susp -w from
#                 prestat.  Fix poststat_filer stutter weirdness.
# v5.04 07-15-03: Capture snapmirror conf and log files
# v5.03 07-16-03: sdy, fix -l, -X add RAM location information and naming
# v5.02 07-11-03: Place stutter headers in output for easy location
# v5.01 07-10-03: Move netstat/ifstat/etc to "perf".  Change headers slightly.
# v5.00 07-09-03: Major rework.
#
# MAIN exists at bottom of file
#

VERSION=7.36
DATE=4-2011
#
usage() 
{
    echo "Perfstat: Version $VERSION $DATE"
    echo "    - perfstat.sh is a simple Bourne Shell script that"
    echo "      captures performance and configuration statistics."
    echo "    - Output from perfstat is sent to standard out and"
    echo "      is typically captured in an output file for"
    echo "      later analysis."
    echo "    - perfstat.sh is capable of capturing info from host(s) and"
    echo "      NetApp storage controllers simultaneously."
    echo "    - Currently perfstat supports these OS platforms:"
    echo "      Solaris, HP-UX, OSF1, Linux, AIX, FreeBSD, OpenBSD, ESX3.5"
    echo "    - perfstat.sh is typically run as root from the host or"
    echo "      as a user with root-level permissions"
    echo "    - For controller data capture, the user must have RSH or"
    echo "      SSH privileges to the controller. Unless instructed otherwise,"
    echo "      perfstat will use 'root' as the default username to communicate" 
    echo "      remotely with storage controllers and hosts."
    echo ""
    echo "Usage: (basic options list)"
    echo " perfstat [-f controllername] [-t time] > perfstat.out"
    echo "    where:"
    echo "    -f controllername - host name (or IP address) of target controller"
    echo "    -t time - collect performance data for 'time' minutes"
    echo " "
    echo " Simple Examples:"
    echo "   Capture data on local host and one controller for 5 minutes:"
    echo "     perfstat -f controller1 -t 5 > perfstat.out"
    echo "   Capture data on multiple hosts and controllers for 10 minutes:"
    echo "     perfstat -h host1,host2 -f controller1,controller2 -t 10 > perfstat.out"
    echo "   Capture data for five 1 minute iterations, with 10 minutes between"
    echo "   successive iterations:"
    echo "     perfstat -f controller1 -t 1 -i 5,10 > perfstat.out"
    echo " "
    echo "Usage: (more complete options list)"
    echo " perfstat "
    echo "          [-f controllername[,controllername1,controllername2,...]]"
    echo "          [-h hostname[,hostname1,hostname2,...]]"
    echo "          [-t time] (sample time per iteration, default 2)"
    echo "          [-i n[,m]] (repeat n times with m minutes between samples,"
    echo "                      defaults: n=1, m=0)"
    echo "          [-I] (force perfstat to execute all iterations)"
    echo " "
    echo "          [-r rootcmd] (e.g. sudo)"
    echo "          [-l login[:password]] (RSH/SSH login and RSH password)"
    echo "          [-S] (use SSH instead of RSH)"
    echo "          [-s param1[,value1][:param2[,value2]]...] (optional RSH/SSH"
    echo "                                                     arguments)"
    echo " "
    echo "          [-F] (do not capture information from local host)"
    echo "          [-V] (do not capture vfiler data)"
    echo "          [-p] (capture performance data only, no config info)"
    echo "          [-c] (capture config info only, no performance data)"
    echo "          [-L] (capture logs - beware verbose output)"
    echo "          [-E cmd[,cmd2,cmd3] (exclude commands)"
    echo "          [-P domain1[,domain2,domain3...] (capture profiles,"
    echo "              use \"-P flat\" to capture complete profile)"
    echo " "
    echo "          [-a app_name -o app_param] (E.g., -a oracle)"
    echo " "
    echo "          [-v] (print version info only)"
    echo "          [-q] (quiet mode - suppress all console output)"
    echo "          [-x] (print what commands will be issued without actually"
    echo "                issuing them)"
    echo "          [-d] (debug mode - beware verbose output)"
    echo " "
    echo "          [-b] (begin sampling and return immediately)"
    echo "          [-e] (end sampling - used in conjunction with -b)"
    echo " "
    echo "          [-n] (RAM Service Invocation)"
    echo " "
    echo "          [-k] (disable collection of \"stutter\" statit; i.e.,"
    echo "                collect 1 statit report that covers the entire "
    echo "                iteration)"
    echo "          [-K] (collect only \"stutter\" statit reports over"
    echo "                the entire iteration)"
    echo " "
    echo "          [-T default | sk_mod,level[,sk_mod2,level,...]] (collect sktrace)"
    echo "          [-B sk_buffer_size] (specify sktrace buffer size)"
    echo "          [--cluster] (toggles C-mode data collection)"
    echo "          [-w] (total number of minutes to wait for perfstat execution to complete. Default would be 5 min.) "
    echo " "
    echo "Notes:"
    echo " -h option adds hosts to be monitored.  By default, the local"
    echo "    host is always monitored, unless the -F flag is specified."
    echo "    E.g., executing this command"
    echo "      perfstat -h host1 > perfstat.out"
    echo "    on machine host0 will result in data captured from both"
    echo "    host0 and host1"
    echo "    This command:"
    echo "      perfstat -F -h host1 > perfstat.out"
    echo "    on machine host0 will result in data captured from host1 only"
    echo " -l option is only applied to RSH/SSH commands to the controller."
    echo "    RSH/SSH commands to other hosts do not use the -l information."
    echo "    perfstat.sh does not support password authentication over SSH,"
    echo "    so if '-S -l login:password' is specified, the password will"
    echo "    be stripped from the subsequent SSH invocations."
    echo " -S requires passwordless (public key) SSH authentication to be"
    echo "    configured for all controllers and hosts"
    echo "    An SSH username may prefix a hostname using a '@'"
    echo "    E.g., "
    echo "      perfstat -S -h root@host1,user@host2"
    echo "    Additionally, the -l option can be used to specify usernames for" 
    echo "    controller login. E.g.,"
    echo "      perfstat -S -f controllername -l user"
    echo " -s arguments to this option use the syntax 'param,value', and param"
    echo "    value pairs can be separated by a ':'"
    echo "    E.g. the syntax '-S -s p1,22:p2:p3,v3' tells perfstat to build"
    echo "    the following SSH invocation string: "
    echo "     'SSH -o BatchMode=yes -2 -ax -p1 22 -p2 -p3 v3'"
    echo " -a is limited to these applications currently:"
    echo "    oracle: -o specifies sub arguments.  run -o help for details"
    echo " -b|-e are provided for legacy compatibility and can be used to"
    echo "    manually perform an iteration. Use -b to start the iteration"
    echo "    and after perfstat returns, use -e to stop that iteration."
    echo " -P saves profiling data in a tar.gz file in the current working"
    echo "    directory and deletes any existing gmon files on the controller"
    echo " -E excludes all foreground commands that have at least the cmd as a"
    echo "    substring; E.g."
    echo "      -E snap,vol       - excludes all 'snap*' and 'vol*' commands"
    echo "      -E \"snap list -v\" - excludes only the command 'snap list -v'"
    echo " -T used to toggle sktrace collection and specify sk modules and the"
    echo "    levels at which trace data should be collected for those modules."
    echo "    Some valid sk modules include SK, WAFL, DISK, and SCSITARGET. For"
    echo "    default values of 'SK 7 WAFL 4', specify '-T default'. sktrace data"
    echo "    will be copied off of the controller(s) and into the current working"
    echo "    directory from where perfstat was invoked."
    echo " -B used to manually set the sktrace buffer size. By default, perfstat"
    echo "    will use a default value of '40m' (40MB). Please note that it is"
    echo "    required that the units be specified with the size in the format:"
    echo "    k (KB), m (MB), or g (GB). This value should only be changed if"
    echo "    specifically advised by global support."
    echo " Early termination of execution: as of v7.00 perfstat will terminate"
    echo "   iterations early if a calculated max runtime is met or exceeded."
    echo "   If it is required that perfstat must execute all iterations regardless"
    echo "   of the total runtime, please use the '-I' option."
    exit 1
}

# if no params are specified, then exit
[ $# = 0 ] && usage

## PRETEND run functions
# Params:
#  $1 command to log
#  $2 type of command
## 
pretend_command()
{
    target=""
    cmd_type=$2

    case $cmd_type in 
        filer*)
            FILER_CMD_COUNT=`expr $FILER_CMD_COUNT + 1`    
            RSH_COUNT=`expr $RSH_COUNT + 1`
            RSH_PER_ITR=`expr $RSH_PER_ITR + 1`
            target=$CUR_FILER
        ;;
        "vfiler")
            FILER_CMD_COUNT=`expr $FILER_CMD_COUNT + 1`
            RSH_COUNT=`expr $RSH_COUNT + 1`
            RSH_PER_ITR=`expr $RSH_PER_ITR + 1`
            target=$CUR_FILER
        ;;
        host*) 
            [ -n "`echo $1 | grep rsh`" ] && RSH_COUNT=`expr $RSH_COUNT + 1` && RSH_PER_ITR=`expr $RSH_PER_ITR + 1`
            target=$CUR_HOST
        ;;
        "config_filer")
            RSH_COUNT=`expr $RSH_COUNT + 1`
            CMD_COUNT=`expr 1 + ${CMD_COUNT}`

            echo "$CMD_COUNT.  config : $CUR_FILER : $1" | sed -n 's/[>|].*//p' >> $TMPDIR/pretend.config
            return
        ;;
        "config_host")
            [ -n "`echo $1 | grep rsh`" ] && RSH_COUNT=`expr $RSH_COUNT + 1`
            CMD_COUNT=`expr 1 + ${CMD_COUNT}`

            echo "$CMD_COUNT.  config : $CUR_HOST : $1" | sed -n 's/[>|].*//p'>> $TMPDIR/pretend.config
            return
        ;;
        "quick") 
            [ -n "`echo $1 | grep rsh`" ] && RSH_COUNT=`expr $RSH_COUNT + 1` && RSH_PER_ITR=`expr $RSH_PER_ITR + 1`
            target=$CUR_HOST
            cmd_type="config"
        ;;
        *)
            echo "Unknown command type: $2, for command $1"
            return
        ;;
    esac 
   
    CMD_COUNT=`expr 1 + ${CMD_COUNT}`   
    echo "$CMD_COUNT.  $cmd_type : $target : $1"
}
#
# Header for pretend mode
#
pretend_header()
{
  echo "
--------------------------------------------------------------
           # Pretend Run Syntax Guide v$VERSION #
--------------------------------------------------------------
  Pretend mode dumps the following to stdout:
    
    - An enumerated list of commands that perfstat intends to execute 
      in the given execution environment. Each element of the enumerat-
      ion contains 3 fields separated by a \" : \"
      
      type : target : command

      1. type -- command type includes one of the following:
        a. filer - \"filer\" commands intended for filers
        b. host - \"host\" commands intended for the host OS
        c. vfiler - \"vfiler\" commands intended for vfilers
        d. config - \"host\", \"filer\", or \"vfiler\" commands 
                    that were executed in order build the list 
                    of \"host\", \"filer\" and \"vfiler\" commands 
                    that perfstat intends to execute
              
        *NOTE* commands of type \"config\" are executed in pretened 
        mode in order to build the comprehensive list of other commands 
        perfstat intendes to execute.
      
      2. target -- the hostname of the target where the command is 
                   intended for execution.
       
      3. command -- the syntax of the command under consideration
  
  - Other information regarding data collection that varies based on 
    values passed to perfstat:  
    
    1. A list of the \"runnable\" stats objects
    2. A list of the \"blacklisted\" stats objects
    3. The statit script used to \"stutter\" statit data collection
    4. Various estimations on the run-time statistics
--------------------------------------------------------------
"
}
#
# Pretend-Footer with calculated run-time statistics 
#
pretend_footer()
{
    echo
    echo "--- Total number of iterations is: $ITERATIONS"
    echo "--- Expected running time per iteration: $TIME_PER_ITR seconds"
    echo "--- Expected total running time is: $RUN_TIME seconds"
    echo "--- Filer-side $rshcmd commands per iteration: $FILER_CMD_COUNT"
    echo "--- Total $rshcmd calls per iteration: $RSH_PER_ITR"
    CFG_RSH=`expr $RSH_COUNT - $RSH_PER_ITR`
    TOTAL_RSH=`expr $ITERATIONS \* $RSH_PER_ITR`
    TOTAL_RSH=`expr $TOTAL_RSH + $CFG_RSH`
    echo "--- Total $rshcmd calls for entire execution: $TOTAL_RSH"
    echo "--- End ---"
}
## End PRETEND Functions

# Toggled using the -N option to test ONTAP version strings
version_tester()
{
    set_filer_context
    console "ONTAP version string $TEST_VERSION mapped to version number $fileros"
}
## Time stamping procedures
#Calculates the epoch in seconds via Unix black magic...
#  NOTE:This SHOULD be portable provided cpio is installed -- (version 7.00)
dc_timestamp()
{
    touch $TIME_FILE 
    cpio -o 2> /dev/null << EOF | od -x | sed -n 'n
s/[^ ]* *\(....\) *\(....\).*/16i\1\2p/;y/abcdef/ABCDEF/;p;q' | dc 
$TIME_FILE
EOF
}
#This routine works for Solaris, Linux, FreeBSD, OSF1 -- requires gawk
gawk_timestamp()
{
    (gawk 'BEGIN {print systime()}') 2> /dev/null || echo 0
}
# Timestamping mechanism for Support Console(burt224699)
#Works for Linux, AIX, FreeBSD -- Requires GNU date
date_timestamp()
{
  (date +%s) 2> /dev/null || echo 0
}
#HP-UX, FreeBSD, OSF1,Solaris,Linux -- requires perl
perl_timestamp(){
  (perl -e 'print time,"\n";') 2> /dev/null || echo 0
}
# PARAMS: $1 == name of timestamp function to check
# RETURNS: 0 if successful and 1 otherwise
# This function performs 2 checks
#  1. Ensures the timestamp function returns only numeric chars
#  2. Ensures the timestamp function doesn't return an error code (non-zero) when invoked
valid_timestamp()
{
    if [ -z "`echo \`${1}\` | grep '[^0-9]'`" ] ; then
        if [ `$1` -gt 0 ] ; then
            # We found a match!
            return 0
        else
            debug "$1 returned error code!"
            return 1
        fi
    else
        debug "$1 returned non-numeric chars!"
        return 1
    fi
}
# Choose timestamping mechanism based on host environment
set_timestamp()
{
    # Support consoles always get the gnu date timestamp
    if [ $RAMRUN = TRUE ] ; then
        TIMESTAMP_FUN="date_timestamp"
    else
        # Else we figure out what timestampping mechanisms are available to us
        for time_func in $TIMESTAMP_FUNCTIONS ; do
            # First check to see if the required tool is in the user's path
            tool="`echo ${time_func} | sed 's/_timestamp//'`"
            
            if check_env_path $tool ; then
                if valid_timestamp $time_func ; then
                    # If we've passed all of our checks, then set the timestamp function
                    debug "Using '${tool}' as timestamp mechanism on ${PERFHOST}"
                    echo "Using '${tool}' as timestamp mechanism on ${PERFHOST}" >> $TMPDIR/error.log
                    TIMESTAMP_FUN="${time_func}"
                    break
                else
                    debug "${time_func} did not produce a valid timestamp!"
                fi
            else
                debug "'${tool}' not installed on ${PERFHOST}"
            fi
        done
    fi
    
    # Check to see if we found a valid timestamping mechanism
    if [ "$TIMESTAMP_FUN" = "none" ] ; then
        console "ERROR: No valid mechanism found for timestamping on $PERFHOST as `whoami`!" 
        console "Please install, perl, gnu date, gawk, dc, or contact NetApp support. Exiting..."
        exit_clean
    fi
}
# Execute the timestamp function
timestamp()
{
    eval $TIMESTAMP_FUN
}
# Print perfstat_epoch label followed by a current timestamp
perfstat_epoch()
{
    current_time=`timestamp`
    echo "PERFSTAT_EPOCH: $current_time"
}
# Used to keep date formats consistent across perfstats
datestamp()
{
    date -u '+%a %b %d %T GMT %Y'
}
# 
toggle_timestamping()
{
    [ $1 = on ] && LOG_TIMESTAMPS=TRUE && return
    #all else means off
    LOG_TIMESTAMPS=FALSE
}
## End time/date stamping procs

#parameters:  variable name, variable value, and default value, eg:  
#  display_var "CONF_ONLY" $CONF_ONLY $D_CONF_ONLY
display_var()
{
    if [ "$2" = "$3" ] ; then
        STATE="default,     " 
    else
        STATE="set,         "
    fi
    if [ -n "$PASSWORD" ] ; then
        echo "$1     $STATE \"$2\""  | sed "s/$PASSWORD/\*/g"
    else
        echo "$1     $STATE \"$2\"" 
    fi
}
#
header()
{
    echo "*------------- Perfstat v$VERSION -------------*"
    display_var "APP_NAME,            " "$APP_NAME" "$D_APP_NAME"
    display_var "BEGIN_ONLY,          " "$BEGIN_ONLY" "$D_BEGIN_ONLY"
    display_var "CONF_ONLY,           " "$CONF_ONLY" "$D_CONF_ONLY"
    display_var "DEBUG,               " "$DEBUG" "$D_DEBUG"
    display_var "END_ONLY,            " "$END_ONLY" "$D_END_ONLY"
    display_var "FILER_TARGETS,       " "$FILER_TARGETS" "$D_FILER_TARGETS"
    display_var "DO_HOST,             " "$DO_HOST" "$D_DO_HOST"
    display_var "HOST_TARGETS,        " "$HOST_TARGETS" "$D_HOST_TARGETS"
    display_var "ITERATIONS,          " "$ITERATIONS" "$D_ITERATIONS"
    display_var "ITER_INTERVAL,       " "$ITER_INTERVAL" "$D_ITER_INTERVAL"
    display_var "FORCE_ITERATIONS,    " "$FORCE_ITERATIONS" "$D_FORCE_ITERATIONS"
    display_var "FILER_LOGIN,         " "$FILER_LOGIN" "$D_FILER_LOGIN"
    display_var "FORCE_OS,            " "$FORCE_OS" ""
    display_var "DO_VFILER,           " "$DO_VFILER" "$D_DO_VFILER"
    display_var "SSH,                 " "$SSH" "$D_SSH"
    display_var "SEND_ARGS,           " "$SEND_ARGS" ""
    display_var "RAMRUN,              " "$RAMRUN" "$D_RAMRUN"
    display_var "APP_PARAM,           " "$APP_PARAM" "$D_APP_PARAM"
    display_var "PERF_ONLY,           " "$PERF_ONLY" "$D_PERF_ONLY"
    display_var "QUIET,               " "$QUIET" "$D_QUIET"
    display_var "ROOT_CMD,            " "$ROOT_CMD" "$D_ROOT_CMD"
    display_var "TIME,                " "$TIME" "$D_TIME"
    display_var "PRETEND,             " "$PRETEND" "$D_PRETEND"
    display_var "LOGS,                " "$LOGS" "$D_LOGS"
    display_var "PROFILES,            " "$PROFILES" "$D_PROFILES"
    display_var "EXCLUDE,             " "$EXCLUDE" "$D_EXCLUDE"
    display_var "STUTTER_STATIT,      " "$STUTTER_STATIT" "$D_STUTTER_STATIT"
    display_var "FULL_STUTTER_STATIT, " "$FULL_STUTTER_STATIT" "$D_FULL_STUTTER_STATIT"
    display_var "MULTI_RSH,           " "$MULTI_RSH" "$D_MULTI_RSH"
    display_var "MONITOR,             " "$MONITOR" "$D_MONITOR"
    display_var "SKTRACE,             " "$SKTRACE" "$D_SKTRACE"
    display_var "CMODE,               " "$CMODE" "$D_CMODE"
    display_var "GXMODE,              " "$GXMODE" "$D_GXMODE"
    echo
}
#
exit_clean()
{
    #assume kill_procs has already been called
    rm -rf $TMPDIR > /dev/null 2>&1
    exit 1
}

#============================================================
#
# define subroutines:
#   set_priv_command()
#
#   check_license()
#
#   do_filer()
#   do_filer_background()
#   do_client()
#
#============================================================


#============================================================
#   privilege manipulation routines
#============================================================
set_priv_command()
{
    PRIV_UNSET=""
    # use cmode command, priv command or old rc_toggle_basic
    if [ $CMODE = TRUE ] ; then
        PRIV_SET='run local \"priv set -q diag ;'
    elif [ $GXMODE = TRUE ] ; then
        PRIV_SET='dbladecli -c \"priv set -q diag ;'
    elif grep priv $TMPDIR/$CUR_FILER/help.out > /dev/null ; then
        PRIV_SET="priv set -q diag ;"
    else
        PRIV_SET="rc_toggle_basic ;"
        PRIV_UNSET="; rc_toggle_basic"
    fi        

    debug "Filer: $CUR_FILER Priv_set: $PRIV_SET Priv_unset: $PRIV_UNSET"
}
#============================================================
#   end - privilege manipulation routines
#============================================================

#determine if program $1 exists at one of the paths in $2
check_path()
{
    for path in $2 ; do 
        if [ $CUR_HOST = $PERFHOST ] ; then
            if [ -f ${path}${1} ] ; then
                echo $path
                return
            fi
        else
            # do_client_quick "ls ${path}${1} 2> /dev/null | wc -l" "ls.out"
            LS_CMD="ls ${path}${1} 2> /dev/null | wc -l"
            do_log "$ROOT_CMD $RSHCMD $CUR_HOST -n \"${LS_CMD}\" > \"$TMPDIR/ls.out\"" "exe"
            if grep 1 $TMPDIR/ls.out > /dev/null 2>&1 ; then
                echo $path
                return
            fi
        fi
    done
}

# check $PATH environment var for the existence of $1
check_env_path()
{
    # Save old separator so we can reset it before we leave...
    old_ifs=$IFS
    # Use : as new field separator
    IFS=':'
    
    for dir in $PATH ; do
        if [ -x "$dir/$1" ] ; then
            IFS=$old_ifs
            return 0
        fi
    done
    
    IFS=$old_ifs
    return 1
}

# Check for some dependencies that must be satisfied before executing perfstat
# If any of these dependencies aren't satisfied, then perfstat will exit, dispalying
# an appropriate error message
check_unix_dependencies()
{
    dependency_list="sed awk"
    # Support consoles use don't have cpio or dc installed, and therefore use a different
    # timestamping mechanism than the rest of UNIXes -- see function set_timestamp()
    if [ $RAMRUN = FALSE ] ; then
        # dc_timestamp also requires cpio
        if [ "$TIMESTAMP_FUN" = "dc_timestamp" ] ; then
            dependency_list="$dependency_list cpio"
        fi
        # Just to make sure, check for rsh/ssh
        if [ $SSH = TRUE ] ; then
            dependency_list="$dependency_list ssh"
        elif [ $MULTI_HOST = TRUE -o $DO_FILER = TRUE ] ; then
            dependency_list="$dependency_list rsh"
        fi
    fi
    
    for dependency in $dependency_list ; do
        if check_env_path $dependency ; then
            if [ $DEBUG = TRUE ] ; then
                debug "'$dependency' installed on $PERFHOST"
            fi
        else
            console "Cannot access '$dependency' on $PERFHOST as `whoami`. Exiting..."
            if [ $dependency = rsh -a `check_vmware $PERFHOST` = 0 ] ; then
                console "WARNING: RSH is not part of the default install for ESX servers."
                console "Please configure SSH on $PERFHOST and use perfstat with the '-S' option."
            fi
            exit_clean
        fi
    done
}
# attempt to locate tools whose path varies among OS/distributions
set_host_specific_paths()
{
    SANLUN_PATHS="/opt/sanlun/bin/ /opt/NetApp/santools/sanlun/ /opt/NTAPsanlun/bin/ /opt/NetApp/santools/bin/ /opt/netapp/santools/ /opt/ontap/santools"
    ISCSI_PATHS="/usr/sbin/ /usr/local/sbin/"
    SAR_PATHS="/usr/bin/ /usr/local/bin/"
    IOSTAT_PATHS="/usr/bin/"
    NFSSTAT_PATHS="/usr/sbin/"

    SANLUN_PATH=`check_path sanlun "$SANLUN_PATHS"`
    ISCSI_PATH=`check_path iscsi-ls "$ISCSI_PATHS"`
    SAR_PATH=`check_path sar "$SAR_PATHS"`
    IOSTAT_PATH=`check_path iostat "$IOSTAT_PATHS"`
    NFSSTAT_PATH=`check_path nfsstat "$NFSSTAT_PATHS"`
}
#
# PRECOND: $machineos = Linux
# PARAMS: $1 == hostname of host to check
# Check to see if we're running from within an ESX server or if a remote host is running ESX server
# If we are not running from an ESX console, then return 1, else return 0
#
check_vmware()
{
    host=$1
    vmware=""
    if [ $host = $PERFHOST ] ; then
        vmware=`vmware -v 2>&1`;
    else 
        vmware=`$ROOT_CMD $RSHCMD $host "vmware -v 2>&1"`
    fi
    # If $vmware contains the string "not found" then we assume command failed
    if [ -n "`echo $vmware | grep \"not found\"`" ] ; then
        echo 1
        return
    fi
    echo 0
}
#
# PRECOND: $machineos = ESX
# Utility function to help gather vm-support data from a local ESX server
# NOTE: This will not get vm-support data from a remote ESX server!!
#
get_vm_support()
{
    host=$1
    remote_host=FALSE
    outdir=$TMPDIR/$host/vmware
    lscmd="ls -1 ${outdir}"
    mk_outdir="mkdir -p $outdir 2> /dev/null"
    vmsupport_cmd="/usr/bin/vm-support -q -n -N -w $outdir > /dev/null 2>&1"
    
    # Setup up commands and vmsupport collection for remote hosts
    if [ $host != $PERFHOST ] ; then 
        if [ $SSH = TRUE ] ; then  
            remote_host=TRUE
            outdir="/tmp/perfstat_vm_support"
            # Remove any previous vm_support files 
            $ROOT_CMD $RSHCMD $host -n "rm -f ${outdir}/*" > /dev/null 2>&1
            lscmd="$ROOT_CMD $RSHCMD $host -n ls -1 ${outdir}"
            mk_outdir="$ROOT_CMD $RSHCMD $host -n \"mkdir -p $outdir\" 2> /dev/null"
            vmsupport_cmd="$ROOT_CMD $RSHCMD $host -n \"/usr/bin/vm-support -q -n -N -w $outdir\" > /dev/null 2>&1"
        else
            debug "WARNING: Gathering vm-support data remotely from ${host} is only supported over SSH"
            echo "`datestamp`: WARNING: Gathering vm-support data remotely from ${host} is only supported over SSH" >> $TMPDIR/error.log
            debug "Skipping vm-support data collection for ${host}..."
            echo "`datestamp`: Skipping vm-support data collection for ${host}..." >> $TMPDIR/error.log
            return
        fi
    fi
    
    echo "`datestamp`: Collecting vm-support -q -n -N on $host" >>$TMPDIR/error.log
    debug "Collecting vm-support -q -n -N on $host"
    # mk tmpdir
    eval "$mk_outdir"
    # run the script (can take 30-60 seconds to complete
    eval "$vmsupport_cmd"
    console "Checking for vm_support output using: $lscmd"
    for vm_support in `$lscmd` ; do
        debug "Moving vmsupport data from ${host}:${outdir}/${vm_support} to ./$vm_support"
        echo "`datestamp`: Moving vmsupport data from ${host}:${outdir}/${vm_support} to ./$vm_support" >>$TMPDIR/error.log
        if [ $remote_host = TRUE ] ; then
            eval "${ROOT_CMD} scp ${host}:${outdir}/${vm_support} ."
            eval "$ROOT_CMD $RSHCMD $host -n \"rm -f ${outdir}/${vm_support}\" 2> /dev/null"
        else
            mv -f $outdir/$vm_support ./ > /dev/null 2>> $TMPDIR/error.log
        fi
        console "Saving vm-support data to: ./${vm_support}"
        console "Please remember to send ./${vm_support} back to global support along with the perfstat output file!"
    done
    
    if [ -z "$vm_support" ] ; then
        debug "WARNING: Failed to collect /usr/bin/vm-support -q -n -N -w ${outdir} on: $host..."
        echo "WARNING: Failed to collect /usr/bin/vm-support -q -n -N -w ${outdir} on: $host..." >> $TMPDIR/error.log
    fi
}
#utility func for check_license
#if MONITOR is set then
# $LICENSE is true, and $LICENSE_MONITOR is true
has_license()
{
    if [ "$ALLSERVICES" = TRUE ]  ; then
        echo TRUE
        return 
    fi 
    if  grep "$1" $TMPDIR/licenses > /dev/null ; then
        echo TRUE
    else
        echo FALSE
    fi
}
#
has_flexcache_option()
{
    if grep "flexcache.enable" $TMPDIR/$CUR_FILER/options.out > /dev/null 2>&1 ; then
        if grep "flexcache.enable" $TMPDIR/$CUR_FILER/options.out | grep 'on' > /dev/null 2>&1 ; then
            echo TRUE
            return
        fi
    fi
    echo FALSE
}
#set fileros variable for current filer
#also sets blacklist and whitelist variables for stats objects, for the current filer
set_filer_context()
{
    #determine filer os version
    fileros=""
    cur_vers_num=0
    stats_ok=FALSE
    sktrace_nok=FALSE
    STATS_BLACKLIST=ONTAP_BLACKLIST
    STATS_WHITELIST=ONTAP_WHITELIST
    # Reset these back to default values so that each time through they are checked and updated appropriately
    NEED_STOPOBJ=$D_NEED_STOPOBJ
    BUILD_SAFE_VOL_LIST=$D_BUILD_SAFE_VOL_LIST
    LEGACY_STATS=$D_LEGACY_STATS
    
    if [ -z "$FORCE_OS" ] ;  then
        fileros=ONTAP
        #this tries to map the Ontap version on the filer to one of several 'well
        #known' version numbers 'well known' version numbers are those for which
        #Perfstat runs a different set of commands. The expectation is that higher
        #versions have all the capabilities of lower ones. For example, if a new 
        #command is introduced between 7.0 and 7.0.2,  then that command can be run on
        #7.0.3 and 7.1 but not 7.0.0.1 or 6.5.6.The mapping is done by converting the
        #version string to a 3 digit number and doing a numerical comparison with
        #the 'well known' version numbers
        #Need to parse the ONTAP version string for 8.0x onwards. It may come with 'R' prefix.

        # If test version is nonzero, then run it through the version mapping logic
        # Else use the version retrieved from the filer
        tmp_cur_vers_num=""
        if [ -n "$TEST_VERSION" ] ; then
            tmp_cur_vers_num=`echo $TEST_VERSION| sed 's/.*\ \([A-Z]*[0-9]*\)\.\([0-9]\)\.\([0-9]\).*/\1\2\3/'`
        else
            tmp_cur_vers_num=`cat $TMPDIR/$CUR_FILER/version.out | sed 's/.*\ \([A-Z]*[0-9]*\)\.\([0-9]\)\.\([0-9]\).*/\1\2\3/'`
        fi
        
        cur_vers_num=`echo $tmp_cur_vers_num | sed 's/.*R\([0-9]*\)\([0-9]\)\([0-9]\).*/\1\2\3/'`
        [ `expr "$cur_vers_num" : NetApp` -gt 0 ] && cur_vers_num=`cat $TMPDIR/$CUR_FILER/version.out | sed 's/.*\ \([0-9]*\)\.\([0-9]\).*/\1\20/'`
        if [ `expr "$cur_vers_num" : NetApp` -eq 0 ] ; then 
            #version_check
			ONTAP_VERSIONS="ONTAP6.5 ONTAP6.5.6 ONTAP7.0 ONTAP7.0.1 ONTAP7.1 ONTAP7.0.2 ONTAP7.0.3 ONTAP7.0.4 ONTAP7.2 ONTAP7.1.1 ONTAP7.0.5 ONTAP7.2.1 ONTAP7.2.2 ONTAP7.0.6 ONTAP7.1.2 ONTAP7.2.3 ONTAP7.0.7 ONTAP7.1.3 ONTAP7.3 ONTAP7.3.1 ONTAP7.3.2 ONTAP8.0 ONTAP7.3.5 ONTAP8.0.1 ONTAP8.0.2 ONTAP10.0 "
            # Remember what the current version number is set to so that we ensure we pick the version of ONTAP that most closely matches what is running on the filer(s)
            set_vers_num=0
            for version in $ONTAP_VERSIONS ; do
                new_vers_num=`echo $version | sed 's/.*P\([0-9]*\)\.\([0-9]\)\.\([0-9]\).*/\1\2\3/'`
                [ `expr "$new_vers_num" : ONTAP` -gt 0 ] && new_vers_num=`echo $version | sed 's/.*P\([0-9]*\)\.\([0-9]\).*/\1\20/'`
                if [ $cur_vers_num -ge $new_vers_num -a $new_vers_num -ge $set_vers_num ] ; then
                    set_vers_num=$new_vers_num
                    fileros=$version
                fi
            done
            # For backgrounded flexcache and per protocol stats...
            [ $cur_vers_num -ge 705 ] && stats_ok=TRUE
            # For regular stats commands (burt214298)
            # NOTE -- This is checked below, but we're just being extra cautious
            [ $cur_vers_num -ge 721 ] && NEED_STOPOBJ=FALSE
            # If we're susceptible to burt 200533, then we need to rebuild VSM exclusion on every iteration
            # NOTE -- This too is checked below, but we're extra cautious
            [ $cur_vers_num -ge 722 ] && BUILD_SAFE_VOL_LIST=FALSE
    	    #Adding a flag to fix BURT 366189 - sktrace can cause panics in IC.0/IC.1
       	    if [ `expr $cur_vers_num` = 730 -o  `expr $cur_vers_num` = 731 ] ; then
                sktrace_nok=TRUE
            fi
            #Disable domain stats collection for ONTAP releases less than 7.3.0
            if [ $cur_vers_num -lt 730 ] ; then
                debug "Disabling domain stats on $CUR_FILER"
                DOMAIN_STATS=FALSE
            fi
        fi
    else
        # If -O option was specified, enable "protocol" stats
        fileros=$FORCE_OS
        stats_ok=TRUE
    	#Adding a flag to fix BURT 366189 - sktrace can cause panics in IC.0/IC.1, Customer might FORCE the 7.3.0/7.3.1 ONTAP version
        if [  "$fileros" =  "ONTAP7.3.1" -o  "$fileros" =  "ONTAP7.3.0" ];then
            sktrace_nok=TRUE
        fi
    fi
    ### Moved these 2 checks here so they will work for all cases (even if FORCE_OS was set)
    # For regular stats commands (burt214298)
    # Note that this is fixed in 7.1.2, 7.0.6, and 7.2.1 and beyond
    if [ -n "`echo $fileros | grep \"7\.2\.[1-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.1\.[2-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.0\.[6-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.3\"`" -o\
         -n "`echo $fileros | grep \"8\.0\"`" -o\
         -n "`echo $fileros | grep \"10\.0\"`" -o\
         $fileros = ONTAP\
       ] ; then
        NEED_STOPOBJ=FALSE
        echo "`datestamp`: No need for 'stats stop -I' stop object on $CUR_FILER -- $fileros" >> $TMPDIR/error.log
        debug "No need for 'stats stop -I' stop object on $CUR_FILER"
    fi
    
    # If we're susceptible to burt 200533, then we need to rebuild VSM exclusion on every iteration
    # Note that this is fixed in 7.1.3, 7.0.6, and 7.2.2 and beyond
    if [ -n "`echo $fileros | grep \"7\.2\.[2-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.1\.[3-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.0\.[6-9]\"`" -o\
         -n "`echo $fileros | grep \"7\.3\"`" -o\
         -n "`echo $fileros | grep \"8\.0\"`" -o\
         -n "`echo $fileros | grep \"10\.0\"`" -o\
         $fileros = ONTAP\
       ] ; then
        debug "Disabling frequent VSM exclusion list rebuilding on $CUR_FILER"
        echo "`datestamp`: Disabling frequent VSM exclusion list rebuilding on $CUR_FILER -- $fileros" >> $TMPDIR/error.log
        BUILD_SAFE_VOL_LIST=FALSE
        debug "Enabling collection of all stats objects on $CUR_FILER"
        echo "`datestamp`: Enabling collection of all stats objects on $CUR_FILER -- $fileros" >> $TMPDIR/error.log
        LEGACY_STATS=FALSE
    fi
    
    # If valid ONTAP version, update the stats lists
    if [ "$fileros" != "ONTAP" -a $GXMODE = FALSE -a $CMODE = FALSE ] ; then
        STATS_BLACKLIST="`echo ${fileros}_BLACKLIST | sed 's/\.//g'`"
        STATS_WHITELIST="`echo ${fileros}_WHITELIST | sed 's/\.//g'`"
    else
        # Else, we assume perfstat is running against an internal build so 
        # toggle a few relevant vars here so that we don't prevent data 
        # collection
        NEED_STOPOBJ=FALSE
        stats_ok=TRUE
    fi
}

#============================================================
#   VSM DESTINATION HANDLERS -- make `qtree stats` "safe" for
#   for versions of ONTAP that don't have fixes for burt200533
#
#  - check_vsm_destinations(): walks the registry of the filer looking
#     looking for the "snapmirrored" field. Builds a safe list of 
#     volumes if the value of snapmirrored is "off"
#
# - add_vsm_safe_prestats(): runs qtree stats on all safe volumes
#
# - add_vsm_safe_poststats(): runs qtree stats on all safe volumes
#============================================================
check_vsm_destinations()
{
    debug "Rebuilding vsm exclusion list on $CUR_FILER..."
    # Remove previous list as filers could have switched roles in vsm relationship
    rm -f $TMPDIR/$CUR_FILER/safe_vols.out 2> /dev/null
    [ $PRETEND = TRUE ] && pretend_command "$FILER_RSH \"priv set -q diag; registry walk options.vols\"" "config_filer"

    VOL_SM_SETTINGS=`$FILER_RSH "priv set -q diag; registry walk options.vols" | grep snapmirrored`
    for setting in $VOL_SM_SETTINGS ; do 
        # look for vsm destinations via the 'snapmirrored=on' setting 
        UNSAFE_VOL=`echo $setting | grep "snapmirrored=on"`
        # if snapmirrored is not on for this volume, add it to our list of safe volumes
        [ -z "$UNSAFE_VOL" ] && echo $setting | cut -d"." -f3 >> $TMPDIR/$CUR_FILER/safe_vols.out
    done

    # Debug mode only -- print out list of volumes identified to be "safe":
    if [ $DEBUG = TRUE ] ; then
        debug "--- List of qtree stats safe volumes ---"
        for vol in `cat $TMPDIR/$CUR_FILER/safe_vols.out` ; do
            debug "  $vol"
        done
        debug "--- End volume list ---"
    fi
  
}
#
add_vsm_safe_prestats()
{
    for vol in `cat $TMPDIR/$CUR_FILER/safe_vols.out` ; do
        echo "qtree stats $vol" >> $PERFCMDS
        echo "qtree stats -z $vol" >> $PERFCMDS
    done
}
#
add_vsm_safe_poststats()
{
    for vol in `cat $TMPDIR/$CUR_FILER/safe_vols.out` ; do
        echo "qtree stats $vol" >> $PERFCMDS
    done
}

#============================================================
#   license checkers.  See what's enabled on the filer.
#============================================================
check_license()
{
    # No support for license checking in GX clusters at this time
    [ $GXMODE = TRUE ] && return
    
    for LICENSE in $LICENSES ; do
        eval "$LICENSE"=TRUE
        eval "$LICENSE"_MONITOR=FALSE
    done

    if [ -n "$MONITOR" ] ; then
        for LICENSE in $LICENSES ; do
            eval "$LICENSE"=FALSE
        done
        eval "$MONITOR"_MONITOR=TRUE
        MULTI_CPU_FILER=TRUE
        return
    fi

    #if license check failed, assume all services are on
    #license.out should always contain 'nfs'
    ALLSERVICES=FALSE
    if grep "nfs" $TMPDIR/$CUR_FILER/license.out > /dev/null ; then
        #ignore those licenses which aren't available
        grep -v "not" $TMPDIR/$CUR_FILER/license.out > $TMPDIR/licenses
    else
        console "Failed to detect licensed services. Attempting all services."
        ALLSERVICES=TRUE
    fi

    set_filer_context

    MULTI_CPU_FILER=TRUE
    num_procs=`grep "Processors:" $TMPDIR/$CUR_FILER/sysconfig.out | awk '{print $2}'`

    if [ $num_procs -gt 1 ] ; then
        MULTI_CPU_FILER=TRUE
    else
        MULTI_CPU_FILER=FALSE
    fi

    # also check to see if we are on a netcache box
    # by checking for existance of the "show" command
    NETCACHE=FALSE
    grep ' show ' $TMPDIR/$CUR_FILER/help.out > /dev/null && NETCACHE=TRUE

    CLUSTER=`has_license cluster`
    NFS=`has_license nfs`
    CIFS=`has_license cifs`
    DAFS=`has_license dafs`
    FCP=`has_license fcp`
    ISCSI=`has_license iscsi`
    SNAPMIRROR=`has_license snapmirror`
    SNAPVAULT=`has_license sv_ontap_pri`
    FLEX_CACHE=`has_license flexcache_nfs`
    # older versions of ONTAP may use the old flexcache license string
    [ $FLEX_CACHE = FALSE ] && FLEX_CACHE=`has_license flex_cache`
    #flexcache enabled if flexcache.enable option is set
    [ $FLEX_CACHE = FALSE ] && FLEX_CACHE=`has_flexcache_option`

    # Check if skipping vfilers was explicitly requested...
    if [ $DO_VFILER = TRUE ] ; then
        #vfiler can have either of these licenses
        VFILER=`has_license multistore`
        [ $VFILER = FALSE ] && VFILER=`has_license vfiler`
    else
        VFILER=FALSE
    fi

    [ $SNAPVAULT = FALSE ] && SNAPVAULT=`has_license sv_ontap_sec`

    #VFILER is a bad idea if license check failed
    [ "$ALLSERVICES" = TRUE ] && VFILER=FALSE

    # If snapmirror license is enabled, we need to build a list of qtree safe volumes
    # We need to walk the registry on the filer to rebuild the vsm exclusion list and this is expensive, 
    # Therefore, we only need to do this we're susceptible to burt200533
    [ $SNAPMIRROR = TRUE -a $BUILD_SAFE_VOL_LIST = TRUE ] && check_vsm_destinations
}

#============================================================
#	End license checkers.
#============================================================

# determine os of current host
check_os()
{
    if [ $CUR_HOST = $PERFHOST ] ; then
        machineos=`uname -s`
    else
        machineos=`$ROOT_CMD $RSHCMD $CUR_HOST "uname -s"`
    fi
    if [ -z "$machineos" ] ; then
        echo "`datestamp`: WARNING: could not identify os of $CUR_HOST using 'uname -s'" >> $TMPDIR/error.log
        console "WARNING: could not identify os of $CUR_HOST using 'uname -s'"
        machineos=UNIX
    fi
    # Special cases for Linux
    if [ $machineos = Linux ] ; then
        # For linux kernels 2.6.18 and beyond, some of the syntax has changed
        if [ `get_linux_ver` -ge 2617 ] ; then
            debug "Toggling syntax for 2.6.17 (RHEL5) Linux kernels on: $CUR_HOST"
            echo "`datestamp`: Toggling syntax for 2.6.17 (RHEL5) Linux kernels on: $CUR_HOST" >> $TMPDIR/error.log
            RHEL5=TRUE
            MII_TOOL=FALSE
        else
            RHEL5=FALSE
        fi
        # Check to see if we're running from within an ESX console (burt 293542)
        if [ `check_vmware "$CUR_HOST"` = 0 ] ; then
            debug "Toggling VMware data collection for: $CUR_HOST"
            echo "`datestamp`: Toggling VMware data collection for: $CUR_HOST" >> $TMPDIR/error.log
            machineos=ESX
        fi
    fi
}
#
#  Returns a 4-digit number that consists of a 1 digit major number, 1 digit minor number, and a 2 digit minor-minor 
#  number representing the Linux kernel verison. For example, 2.6.9-18 would get converted to '2609'
#
get_linux_ver()
{
    cmd=""
    if [ $CUR_HOST != $PERFHOST ] ; then
        cmd="$ROOT_CMD $RSHCMD $CUR_HOST /bin/uname -r"
    else
        cmd="/bin/uname -r"
    fi
    echo `${cmd} | cut -d'.' -f1,2,3 | sed 's/-.*//g' | sed 's/\./ /g' | awk '{printf "%d%d%02d\n", \$1,\$2,\$3}'`
}
#============================================================
# Some utility stuff
#  - Log and execute a command (do_log)
#  - Check to see if a command exists on filer (check_command)
#  - Execute a command on the filer (do_filer)
#  - Execute a background command on filer (do_filer_background)
#  - Execute a command on the client (do_client)
#  - Display timestamps & deltas for "stats start/stop" commands
#============================================================
#
find_stats_tag()
{
    for tmp in $STATS_TAGLIST ; do
        filer_field=`echo $tmp | cut -d":" -f1`
        tag_field=`echo $tmp | cut -d":" -f2`
        time_field=`echo $tmp | cut -d":" -f3`
        [ $filer_field = $CUR_FILER -a $tag_field = $1 ] && echo $time_field && return
    done
    echo 0
}

#For "stats" commands, display time delta between stats start & stop
check_stats_tag()
{
    #stats start: print & save timestamp 
    if [ `expr "$1" : ".*stats start -I"` -gt 0 ] ; then
        tag=`echo $1 | sed 's/.*stats start -I//' | awk '{print $1}'`
        STATS_START_TIME=`timestamp`
        STATS_TAGLIST="$STATS_TAGLIST $CUR_FILER:$tag:$STATS_START_TIME"
        echo "TIME: `datestamp`"
    fi
    #stats start: print timestamp & delta 
    if [ `expr "$1" : ".*stats stop -I"` -gt 0 ] ; then
        tag=`echo $1 | sed 's/.*stats stop -I//' | awk '{print $1}'`
        timestamp1=`find_stats_tag $tag`
        timestamp2=`timestamp`
        delta=`expr $timestamp2 - $timestamp1`
        echo "TIME: `datestamp`"
        min=`expr $delta / 60`
        sec=`expr $delta % 60`
        echo "TIME DELTA: ${min}:${sec} (${delta}s)"
        echo
    fi
}
#
check_excluded()
{
    # Set the internal field separator to a comma so that we can check against the entire command
    old_ifs=$IFS
    IFS=","
    for cmd in $EXCLUDED ; do
        # Strip beginning and ending white space
        cmd=`echo $cmd | sed "s/^[ ]//g"`
        cmd=`echo $cmd | sed "s/[ ]$//g"`
        # debug "Checking if '$1' should be excluded against: '$cmd'"
        if [ -n "`echo \"$1\" | grep \"$cmd\"`" ] ; then
            debug "Excluding command: $1"
            echo "Excluded."
            echo "Excluded: $1" >> $TMPDIR/error.log
            IFS=$old_ifs
            return 1
        fi
    done
    IFS=$old_ifs
    return 0
}

# NOTE: I don't think this procedure is ever invoked
# $1 is command, $2 is type
do_log_work()
{
    [ $PRETEND = TRUE ] && echo "Do Log Work called..." && pretend_command "$1" "$2"
    eval "$1" > $TMPDIR/command.out 2>> $TMPDIR/error.log & #run the command
    bgpid=$!
    (sleep $TIMEOUT ; touch $TMPDIR/failed ; kill -9 $bgpid ) &
    bgpid2=$!
    wait $bgpid 
    echo $? > $TMPDIR/retval
    kill $bgpid2 
}

## Main procedure for executing 'serial' commands
# Params:  
#   $1 = command to execute 
#   $2 = type of command (this param matters only if $PRETEND=TRUE)
#         [vfiler,host,filer] -- $1 gets logged, but not get executed
#         [quick,config]  -- $1 gets logged and executed
#         [exe]                -- $1 get executed but not logged
#  $3 = PERF/CONF (for label)
## 
do_log()
{
    check_excluded "$1" || return 0
  
    if [ $PRETEND = TRUE -a $2 != exe ] ; then 
        pretend_command "$1" "$2"
        [ $2 = filer -o $2 = host -o $2 = vfiler ] && return
        # Execute "quick" or "config" commands
        eval "$1" 2>> $TMPDIR/error.log
        return $?
    # Don't include 'exe' commands in error log
    elif [ $PRETEND = FALSE ] ; then
        echo "`datestamp` $3 $LABEL: $1" >> $TMPDIR/error.log
        check_stats_tag "$1"
    fi
  
    #classic behavior
    if [ $MULTI_RSH = FALSE ] ; then
        CMD_START_TIME=`timestamp`
        eval "$1" 2>> $TMPDIR/error.log
        ret_val=$?
        CMD_STOP_TIME=`timestamp`
        if [ $LOG_TIMESTAMPS = TRUE -a $2 != exe ] ; then
            #Pretty print the command followed by its execution time
            elapsed_time=`expr $CMD_STOP_TIME - $CMD_START_TIME`
            echo ""
            echo "EXE-TIME of: `echo $1 | cut -d';' -f2` :  $elapsed_time seconds"
            perfstat_epoch
            echo ""
            if [ $elapsed_time -ge $CMD_EXE_THRESHOLD ] ; then
                host=""
                if [ $2 = filer ] ; then
                    host=$CUR_FILER
                elif [ $2 = host ] ; then
                    host=$CUR_HOST
                elif [ $2 = vfiler ] ; then
                    host=$CUR_VFILER
                else 
                    host="unknown"
                fi
                log_command "`echo $1 | cut -d\";\" -f2`" "$host" "$CUR_ITERATION" "$elapsed_time"
            fi
        fi
        return $ret_val #return value of last command from eval
    fi
  
    # I don't think we ever get here...but I'm not sure
    (do_log_work "$1" "$3")  > /dev/null 2>&1

    if [ -f $TMPDIR/failed ] ; then
        echo "Command timed out! Killed." >> $TMPDIR/error.log
        rm $TMPDIR/failed
        return 1
    fi
    cat $TMPDIR/command.out
    return `cat $TMPDIR/retval`
}
#
debug()
{
    [ $DEBUG = TRUE ] && echo "Debug:" $1 >&2
}
#
console()
{
    [ $QUIET = FALSE ] && echo "Perfstat:" $1 >&2
}
# To comply with burt 293660 (standardize timestamp formats) we replace date -u with "date" to keep 
# backward compatibility with parsers
print_label()
{
    echo "=-=-=-=-=-= $1 $LABEL =-=-=-=-=-= $2"
}
#
build_filer_rshcmd()
{
    FILER_RSH="$ROOT_CMD $RSHCMD $CUR_FILER -n -l $FILER_LOGIN "
    # RAMRUN used only with the Support Console
    [ $RAMRUN = TRUE ] && FILER_RSH="/usr/local/nasc/bin/nascRemoteCmd -t $RAM_delay_time_secs $CUR_FILER "
}

#execute a batch of commands in parallell
# Don't know if we ever get here...
do_filer_work()
{
    echo "do_filer_work needs to be pretend safe..."
    cmdnum=0
    pidlis=""
    rm $TMPDIR/*bgcmd
    while read command ; do
        cmdnum=`expr $cmdnum + 1`
        echo "`datestamp` $1 $LABEL: $command" > $TMPDIR/${cmdnum}.bgcmd.err
        [ $PRETEND = FALSE ] && print_label "$1 ${CUR_FILER}${CUR_VFILER}" "$command" > $TMPDIR/${cmdnum}.bgcmd
        $FILER_RSH "$PRIV_SET $command $PRIV_UNSET" >> $TMPDIR/${cmdnum}.bgcmd 2>> $TMPDIR/${cmdnum}.bgcmd.err &
        pidlist="$! $pidlist"
    done
    (sleep $TIMEOUT ; for pid in $pidlist ; do kill -9 $pid ; done) &
    sleep_pid=$!
    for pid in $pidlist ; do wait $pid ; done
    kill $sleep_pid
}

#
# main do_filer routine.  Must have a parameter of
# either "CONFIG" or "PERF"
#
# commands executed up to BATCH_SIZE in parallel
do_filer()
{
    [ $PERF_ONLY = TRUE -a "$1" = CONFIG ] && return
    [ $CONF_ONLY = TRUE -a "$1" = PERF ] && return
  
    #classic behavior
    if [ $MULTI_RSH = FALSE ] ; then
        while read command ; do
            [ $PRETEND = FALSE ] && print_label "$1 ${CUR_FILER}${CUR_VFILER}" "$command"
            do_log "$FILER_RSH \"$PRIV_SET $command $PRIV_UNSET\"" "filer" $1
        done
        return
    fi

    #batchify commands
    cur_batch_num=0
    cur_batch_size=0
    rm $TMPDIR/batch* > /dev/null 2>&1
    while read command ; do
        if check_excluded "$command" ; then
            echo "$command" >> $TMPDIR/batch.${cur_batch_num}
            cur_batch_size=`expr $cur_batch_size + 1`
        fi
        if [ $cur_batch_size -ge $BATCH_SIZE ] ; then 
            cur_batch_num=`expr $cur_batch_num + 1`
            cur_batch_size=0
        fi
    done

    #run batches
    for file in `ls $TMPDIR/batch*` ; do
        (do_filer_work $1) < $file > /dev/null 2>&1 
        for file in `ls $TMPDIR/*bgcmd` ; do
            cat ${file}.err >> $TMPDIR/error.log
            cat ${file}
        done
    done
}

# Common formatting worker stub for server requests
#command is $1, output file is $2
do_filer_background()
{
    [ $CONF_ONLY = TRUE ] && return
    if [ $PRETEND = FALSE ] ; then
        echo `datestamp`"$FILER_RSH \"$PRIV_SET $1 $PRIV_UNSET\" (background)" >> $TMPDIR/error.log
        echo "Begin: "`datestamp` > $TMPDIR/$CUR_FILER/$2 
        $FILER_RSH "$PRIV_SET $1 $PRIV_UNSET" 2> /dev/null >> $TMPDIR/$CUR_FILER/$2 &
        echo $! >> $TMPDIR/bg_pidlist  #store process id
        return 0
    else
        pretend_command " $1" "filer (background process)"
        return 0
    fi
}

#
# The main do_client routine.  Must have a parameter of either
# "CONFIG" or "PERF".  
# 
do_client()
{       
    [ $PERF_ONLY = TRUE -a "$1" = CONFIG ] && return
    [ $CONF_ONLY = TRUE -a "$1" = PERF ] && return

    while read command ; do
        if [ $MULTI_HOST = FALSE -o $CUR_HOST = $PERFHOST ] ; then
            debug "$command"
            [ $PRETEND = FALSE ] && print_label "$1 $CUR_HOST" "$command"
            # Special case here for date command to keep in compliance with burt 293660 (standardize date format)
            if [ "$command" = "date" ] ; then
                command="date -u '+%a %b %d %T GMT %Y'"
            fi
            do_log "$command" "host" $1
        else
            debug "$ROOT_CMD $RSHCMD $CUR_HOST -n \"$command\""
            [ $PRETEND = FALSE ] && print_label "$1 $CUR_HOST" "$command"
            # Special case here for date command to keep in compliance with burt 293660 (standardize date format)
            if [ "$command" = "date" ] ; then
                command="date -u '+%a %b %d %T GMT %Y'"
            fi
            do_log "$ROOT_CMD $RSHCMD $CUR_HOST -n \"$command\"" "host" $1
        fi
    done
}

#command is $1, output file is $2
do_client_background()
{
    mkdir -p $TMPDIR/$CUR_HOST 2> /dev/null
    [ $CONF_ONLY = FALSE ] || return
    if [ $PRETEND = FALSE ] ; then
        if [ $CUR_HOST = $PERFHOST ] ; then
            echo `datestamp`"$1 (background)" >> $TMPDIR/error.log
            echo "Begin: "`datestamp` > $TMPDIR/$CUR_HOST/$2 
            eval "$1" 2> /dev/null >> $TMPDIR/$CUR_HOST/$2 & #execute command
            echo $! >> $TMPDIR/bg_pidlist  #store pid
        else
            echo `datestamp`"$ROOT_CMD $RSHCMD $CUR_HOST -n \"$command\" (background)" >> $TMPDIR/error.log
            echo "Begin: "`datestamp` > $TMPDIR/$CUR_HOST/$2 
            $ROOT_CMD $RSHCMD $CUR_HOST -n "$1 " 2> /dev/null >> $TMPDIR/$CUR_HOST/$2 &
            echo $! >> $TMPDIR/bg_pidlist 
        fi
        echo
    else
        # We're in PRETEND MODE, so log host command
        pretend_command "$1" "host (background process)"
    fi
}
#
find_vfilers()
{
    #find names & paths of vfilers.  this is kind of voodoo...
    #NOTE: We don't include vfiler0 in the list as that represents the physical filer
    do_log "$FILER_RSH \"$PRIV_SET vfiler status $PRIV_UNSET\" | awk '{ print \$1}' | sed '/vfiler0/d' > $TMPDIR/vfilers" "config_filer"
    do_log "$FILER_RSH \"$PRIV_SET vfiler status -r $PRIV_UNSET\" > \"$TMPDIR/vfilers2\"" "config_filer"

    NUM_VFILERS=`cat $TMPDIR/vfilers`
    if [ -z "$NUM_VFILERS" ] ; then
        debug "No vfilers detected on $CUR_FILER."
        VFILER=FALSE
    else
        for vfiler in `cat $TMPDIR/vfilers` ; do
            line_no=`grep -n '^'$vfiler[" \n\t"] $TMPDIR/vfilers2 | sed 's/:.*//'`
            path=`sed -n ''$line_no',/Path/{ /Path/p; }' $TMPDIR/vfilers2 | awk '{print $2}'`   
            echo "$vfiler $path" >> $TMPDIR/$CUR_FILER/vfiler.list
        done
    fi
}
#
find_vifs()
{
    echo "" > $TMPDIR/$CUR_FILER/vif.list
    if [ -z "$MONITOR" ] ; then
        do_log "$FILER_RSH \"$PRIV_SET vif status $PRIV_UNSET\" | grep \"VIF Type\" | sed s/:.\*// | grep -v default > $TMPDIR/$CUR_FILER/vif.list" "config_filer"
    fi
}

#Verify that rsh/ssh works for filer, and run a few common commands
check_rsh_filer()
{
    [ $DO_FILER = TRUE ] || return
    rshcmd=rsh
    [ $SSH = TRUE ] && rshcmd=ssh
    
    # NOTE: PRIV_SET has not been set yet...
    run_prefix=""
    run_suffix=""
    if [ $CMODE = TRUE ] ; then
        run_prefix="'run local "
        run_suffix="'"
    fi
    
    console "Verify filer $rshcmd access"
    
    for CUR_FILER in $FILERS ; do
        build_filer_rshcmd
        do_log "$FILER_RSH $run_prefix\"version\"$run_suffix > /dev/null 2>&1" "config_filer"
        if [ $? -ne 0 ] ; then
            console "Filer $CUR_FILER fails $rshcmd test"
            console "Verify connectivity using: '$FILER_RSH \"version\"' from $PERFHOST"
            exit_clean
        fi
        mkdir -p $TMPDIR/$CUR_FILER 2> /dev/null

        do_log "$FILER_RSH $run_prefix\"priv set -q diag ; version\"$run_suffix > $TMPDIR/$CUR_FILER/version.out" "config_filer"

        # Since, nascRemoteCmd returns 0 upon failure we need to check output of version to see if connection exists... 
        if [ $RAMRUN = TRUE ] ; then 
            VERSION_OUTPUT=`cat $TMPDIR/$CUR_FILER/version.out | grep "access not enabled"`
            
            if [ -n "$VERSION_OUTPUT" ] ; then
                console "Filer $CUR_FILER is not configured for connectivity from Support Console $PERFHOST"
                exit_clean
            fi
        fi

        do_log "$FILER_RSH $run_prefix\"priv set -q diag ; help\"$run_suffix > $TMPDIR/$CUR_FILER/help.out" "config_filer"
      
        if [ -z "$MONITOR" ] ; then
            do_log "$FILER_RSH $run_prefix\"priv set -q diag ; sysconfig\"$run_suffix > $TMPDIR/$CUR_FILER/sysconfig.out" "config_filer"
            do_log "$FILER_RSH $run_prefix\"priv set -q diag ; license\"$run_suffix > $TMPDIR/$CUR_FILER/license.out" "config_filer"
            do_log "$FILER_RSH $run_prefix\"priv set -q diag ; options\"$run_suffix > $TMPDIR/$CUR_FILER/options.out" "config_filer"
            # Query the filer to set what stats objects are available if we're in LEGACY mode
            # if [ $LEGACY_STATS = TRUE ] ; then 
                # do_log "$FILER_RSH \"priv set -q diag ; stats list objects\" > $TMPDIR/$CUR_FILER/all_stats.list" "config_filer"
            # fi
        fi
  
        set_priv_command
        check_license
        [ $VFILER = TRUE ] && find_vfilers

        find_vifs
    done
}
# Verify ssh/rsh connectivity to all hosts/filers
check_rsh_host()
{
    [ $DO_HOST = TRUE ] || return
    rshcmd=rsh
    [ $SSH = TRUE ] && rshcmd=ssh
    console "Verify host $rshcmd access"
    # Check for installation of sysstat package on Linux burt186745
    lin_sysstat_check="rpm -q sysstat"
    for CUR_HOST in $HOSTS ; do
        if [ $CUR_HOST != $PERFHOST ]; then
            do_log "$ROOT_CMD $RSHCMD $CUR_HOST -n \"ls\" > /dev/null 2>&1" "config_host"
        
            if [ "$?" -ne 0 ] ; then
                console "ERROR: Host $CUR_HOST fails $rshcmd test"
                exit_clean
            fi
            host_os=`$ROOT_CMD $RSHCMD $CUR_HOST "uname -s"`
            if [ "$host_os" = "" ] ; then
                console "ERROR: Failed to determine OS on $CUR_HOST using \"uname -s\""
                console "Please verify connectivity via the cmd: $ROOT_CMD $RSHCMD $CUR_HOST \"uname -s\""
                exit_clean
            elif [ $host_os = Linux ] ; then
                check_sysstat=`$ROOT_CMD $RSHCMD $CUR_HOST "$lin_sysstat_check"`
                
                if [ -n "`echo $check_sysstat | grep \"not installed\"`" ] ; then 
                    console "WARNING: Linux sysstat package not installed on $CUR_HOST"
                    echo "WARNING: Linux sysstat package not installed on $CUR_HOST" >> $TMPDIR/error.log
                fi
            fi
        else
            host_os=`uname -s`
            # Support Consoles don't use rpm...
            if [ $host_os = Linux -a $RAMRUN = FALSE ] ; then
                check_sysstat=`$lin_sysstat_check`
                
                if [ -n "`echo $check_sysstat | grep \"not installed\"`" ] ; then 
                    console "WARNING: Linux sysstat package not installed on: $CUR_HOST"
                    echo "WARNING: Linux sysstat package not installed on: $CUR_HOST" >> $TMPDIR/error.log
                fi
            fi
        fi
    done
}
#
# Check white and black lists to build appropriate list of stats objects for presets file
# PRECONDITIONS: 
#  1. stats_file exists (done in do_pre_iterations routine)
#  2. STATS_WHITELIST and STATS_BLACKLIST have been set (done in set_filer_context)
#  3. CUR_FILER has been set
#
check_stats_lists()
{
    ALL_STATS="$TMPDIR/$CUR_FILER/all_stats.list"
    RUN_STATS="$TMPDIR/$CUR_FILER/run_stats.list"

    # First check the blacklist to explicitly skip any stats objects...
    for obj in `cat $ALL_STATS` ; do
        # Skip silly 'stats list objects' header
        [ "$obj" = "Objects:" ] && continue
        # If obj is not in blacklist, add it to stats_objs file
        if [ -z "`eval \"echo \$"${STATS_BLACKLIST}" | grep -w $obj\"`" ] ; then 
            echo $obj >> $RUN_STATS
        else 
            debug "stats object \"$obj\" was BLACKLISTED on: $CUR_FILER"
        fi
    done
    
    # Now check the whitelist for any stats objects that should be included
    # NOTE: Whitelisted stats objects take precedence over blacklisted stats objects
    for obj in `eval "echo \$"${STATS_WHITELIST}""` ; do
        if [ -z "`cat $ALL_STATS | grep -w $obj`" ] ; then
            debug "Adding $obj to list of runnable stats objects for: $CUR_FILER"
            echo $obj >> $ALL_STATS
        fi
    done
}

##
# Push the presets file out to the filer -- called from do_pre_iterations
# PRECONDITIONS 
#  1. $TMPDIR/$1/run_stats.list file exists, $histo_interval is defined
#  2. $CUR_FILER set
# 3.  set_filer_context
##
write_stats_preset()
{
    RUN_STATS="$TMPDIR/$CUR_FILER/run_stats.list"
    PRESET_FILE="$TMPDIR/$CUR_FILER/stats.preset"
    WRFILE_RESULTS="$TMPDIR/$CUR_FILER/wrfile.preset"
    ORIENTATION="row"
    INTERVAL=$histo_interval
    PRINT_INSTANCE_NAMES="false"

    # burt 305179 -- If -e was specified don't try writing the preset file again...
    if [ $END_ONLY = TRUE -a $ONESHOT = FALSE ] ; then
        return
    fi
    
    # XML header and preset file settings
    echo "<?xml VERSION = \"1.0.\" ?>" > $PRESET_FILE
    echo "<preset orientation=\"$ORIENTATION\" interval=\"$INTERVAL\" print_instance_names=\"$PRINT_INSTANCE_NAMES\">" >> $PRESET_FILE

    for obj in `cat $RUN_STATS` ; do
        echo "  <object name=\"${obj}\"></object>" >> $PRESET_FILE
    done
    echo "</preset>" >> $PRESET_FILE

    # Handle pretend mode first
    if [ $PRETEND = TRUE ] ; then
        do_log "$ROOT_CMD $RSHCMD $CUR_FILER -l $FILER_LOGIN \"priv set -q diag; wrfile /etc/stats/preset/${PRESET_NAME}.xml\" < $PRESET_FILE" "filer"
        touch $WRFILE_RESULTS
        return
    fi

    # Try writing stats preset file to filer and save any error messages
    # *NOTE* burt241318 and burt174963 -- ssh "wrfile" will hang unless CTRL+C is sent (SIGINT) via interactive shell
    if [ $SSH = FALSE ] ; then
        eval "$ROOT_CMD $RSHCMD $CUR_FILER -l $FILER_LOGIN \"priv set -q diag; wrfile /etc/stats/preset/${PRESET_NAME}.xml\" < $PRESET_FILE 2> $WRFILE_RESULTS"
    fi

    # If the 'wrfile' returned an error message for cur_filer warn the universe...
    if [ -s $WRFILE_RESULTS -a $SSH = FALSE ] ; then 
        debug "Failed to write '/etc/stats/preset/perfstat_preset.xml' on $CUR_FILER"
        echo "
        ** WARNING **
        Failed to write /etc/stats/preset/perfstat_preset.xml on $CUR_FILER.
        Falling back to the long stats CLI command, which can fail if length > 1024 characters
        ** END **" >> $TMPDIR/error.log
    fi
}
#
do_date()
{
    do_client "PERF" <<!
    date
!
}

# Small helper to grab the contents of the error log
append_error_log()
{
    print_label "CONFIG $PERFHOST" "ERROR LOG"
    if [ -n "$PASSWORD" ] ; then
        cat $TMPDIR/error.log | sed "s/$PASSWORD/\*/g"
    else
        cat $TMPDIR/error.log
    fi
}
# Creates temp directory structure for interim data and error logging
create_tmp_dir()
{
    # if -b/-e were used we don't set tmp dir using perfstat pid
    if [ $ONESHOT = FALSE ] ; then
        TMPDIR="/tmp/perfstat/no_pid"
    else
        TMPDIR="/tmp/perfstat.$$"
    fi
    # Create the temp directory structure
    if [ $END_ONLY = FALSE ] ; then
        rm -rf $TMPDIR
        mkdir -p $TMPDIR 
        if [ ! -d $TMPDIR ] ; then
            console "Error: Could not create temporary directory ($TMPDIR)"
            exit_clean
        fi
    fi
}
#============================================================
#   End utility stuff
#============================================================


#============================================================
#   Very specialized stuff (like stutter and stats star/stop)
#============================================================

## Post process the output from the stats command
# PRECONDITION: CUR_FILER is set
format_stats_output()
{
    RESULTS="$TMPDIR/$CUR_FILER/stats.out"
    TIME_DELTA=`expr $STATS_STOP_DELTA - $STATS_START_DELTA`
    ## 
    # Special awk script for converting stats output into the following format (per object)
    #
    #    object:instance:counter.[field]:value
    #
    # NOTE: This script will convert all stats output into the format listed above
    #  e.g., 
    #    object:instance:counter:
    #     field1: value
    #     field2: value
    # Will be converted to:
    #    object:instance:counter.field1:value
    #    object:instance:counter.field2:value
    #
    # NOTE: To support backward compatibility, we convert the stats object name 'nfsv3' to 'nfs'
    # when printing the delimiter
    ##
    awk 'BEGIN { FS=":"; cur_obj = ""; cur_counter=""; cur_instance=""; print_line=1; }\
    {\
        # Skip stats output header
        if ($1 ~ /StatisticsID/) {\
            next;
        }\
        # This case is the clunky format (should have been preceded with a line containing obj and instance names)
        else if ($1 ~ /^\t/) {\
            # Remove the leading space (if any)
            cur_val=substr($2,(index($2," ")+1));\
            cur_field=$1;\
            # Remove any leading tabs
            while (index(cur_field,"\t")) {\
                cur_field=substr(cur_field,(index(cur_field,"\t")+1));\
            }\
            # Pretty print the clunky format
            printf "%s:%s:%s.%s:%s\n",cur_obj,cur_instance,cur_counter,cur_field,cur_val;\
        }\
        # Else we found the nice, one-line format
        else {\
            # This case is for the lines: object:instance:counter: that precede the clunky format
            if ($NF == "") {\
                cur_instance="";\
                # Preserve the instance name, since it can contain the : character that we use as field separators
                for ( x = 2; x < NF - 1; x++ ) {\
                    if ( (x + 1) == NF - 1 ) \
                        cur_instance = (cur_instance $x);\
                    else \
                        cur_instance = (cur_instance $x ":");\
                }\
                cur_counter=$(NF-1);\
                # Skip printing this line
                print_line=0;\
            }\
            # This case means we need to print the typical perfstat delimiter for the new stats object
            if (cur_obj != $1) {\
                # Print the epoch for the last stats obj
                printf "\nPERFSTAT_EPOCH: %d\n", stats_stop_timestamp;\
                # Speical case for nfsv3 and volume objects to support backward compatibility for parsing tools
                if ($1 == "nfsv3") \
                    printf "\n=-=-=-=-=-= PERF %s POSTSTATS =-=-=-=-=-= stats stop -I perfstat_nfs\n", filer;\
                else if ($1 == "volume") \
                    printf "\n=-=-=-=-=-= PERF %s POSTSTATS =-=-=-=-=-= stats stop -I perfstat_vol\n", filer;\
                else \
                    printf "\n=-=-=-=-=-= PERF %s POSTSTATS =-=-=-=-=-= stats stop -I perfstat_%s\n", filer, $1;\
                printf "TIME: %s\n", time_val;\
                printf "TIME_DELTA: %02d:%02d (%ds)\n", delta_val/60, delta_val%60, delta_val;\
                cur_obj=$1;\
            }\
            if (print_line == 1) \
                print $0;\
            # Reset print_line toggle value
            print_line=1;\
        }\
    }' time_val="$STATS_STOP_TIME" delta_val=$TIME_DELTA stats_stop_timestamp=$STATS_STOP_DELTA filer="$CUR_FILER" $RESULTS
    # Uncomment below to remove the temp file containing raw stats output
    # rm -f $RESULTS
}
##
# A joining function that will invoke the correct stats function depending 
# on the mode set.
##
do_stats() {
    action=$1
    if [ $CMODE = TRUE -o $GXMODE = TRUE ] ; then
        do_stats_cmode "$action"
    else
        do_stats_7mode "$action"
    fi    
}
##
# Run stats start/stop on list: $RUN_STATS using either presets or one long command line call
# PRECONDITIONS:
#  1. List of runnable stats for each filer should be constructed ($TMPDIR/$CUR_FILER/run_stats.list)
#  2. CUR_FILER is set
# PARAMS: $1 = [ START | STOP ]
##
do_stats_7mode()
{
    [ $CONF_ONLY = TRUE ] && return
    STATS_ACTION=$1

    # The result of whether or not pushing the presets file to the filer was successful
    WRFILE_RESULTS="$TMPDIR/$CUR_FILER/wrfile.preset"

    PRESET_OK=TRUE
    # If we're using SSH or not in LEGACY_STATS mode (i.e., all stast objs are safe), or writing the preset file was unsuccessful and we're not in pretend mode we won't collect stats data
    if [ $SSH = TRUE -o $LEGACY_STATS = FALSE -o -s $WRFILE_RESULTS -a $PRETEND = FALSE ] ; then 
        PRESET_OK=FALSE
    fi
  
    # First build the stats start or stats stop command
    if [ $STATS_ACTION = START ] ; then 
        
        if [ $PRESET_OK = TRUE ] ; then
            STATS_CMD="stats start -I $STATS_ID -p $PRESET_NAME"
        else
            # If we can't use presets file then issue one stats start command with a big list of runnable objects
            # -- NOTE --
            # This start command will fail in ONTAP7.2+ if it exceeds 1024 chars
            STATS_CMD="stats start -I $STATS_ID"
            # If we're in legacy mode, then build the long list of non-blacklisted stats objects
            if [ $LEGACY_STATS = TRUE ] ; then
                OBJ_LIST=""
                for obj in `cat $TMPDIR/$CUR_FILER/run_stats.list` ; do
                    OBJ_LIST="$OBJ_LIST $obj"
                done
                STATS_CMD="$STATS_CMD $OBJ_LIST"
            fi
        fi
    elif [ $STATS_ACTION = STOP ] ; then
        # burt 305179 -- need to grab stats id from /tmp/perfstat/no_pid/stats_id_list if -b/-e option are being used
        if [ $END_ONLY = TRUE -a $ONESHOT = FALSE ] ; then
            STATS_ID=`cat $TMPDIR/stats_id_list`
            STATS_START_DELTA=`cat $TMPDIR/stats_start_time`
        fi
        
        if [ $PRESET_OK = TRUE ] ; then
          STATS_CMD="stats stop -I $STATS_ID -p $PRESET_NAME"
        else
            STATS_CMD="stats stop -I $STATS_ID"
            #burt214298 and burt200533 -- need to add an object to 'stats stop' so parse_objdefs() does not get invoked
            [ $NEED_STOPOBJ = TRUE ] && STATS_CMD="$STATS_CMD system"
        fi
    else
        return
    fi
  
    # Now decide how to execute the stats command
    if [ $PRETEND = TRUE ] ; then
        do_log "$FILER_RSH \"$PRIV_SET $STATS_CMD $PRIV_UNSET\"" "filer" "PERF"
        return
    fi
  
    if [ $STATS_ACTION = START ] ; then
        print_label "PERF $CUR_FILER" "$STATS_CMD"
        echo "TIME: `datestamp`"
        STATS_START_DELTA=`timestamp`
        # # burt 305179 -- Save the stats start time for -b/-e invocations
        if [ $BEGIN_ONLY = TRUE -a $ONESHOT = FALSE ] ; then
            echo "$STATS_START_DELTA" > $TMPDIR/stats_start_time
        fi
        eval "$FILER_RSH \"$PRIV_SET $STATS_CMD $PRIV_UNSET\" 2>> $TMPDIR/error.log"
    else
        # Save results of stop for pretty printing
        eval "$FILER_RSH \"$PRIV_SET $STATS_CMD $PRIV_UNSET\" > $TMPDIR/$CUR_FILER/stats.out 2>> $TMPDIR/error.log"
        
        if [ ! -s $TMPDIR/$CUR_FILER/stats.out ] ; then
            debug "WARNING Failed to collect stats data on $CUR_FILER"
            echo "WARNING: Failed to collect stats data on $CUR_FILER" >> $TMPDIR/error.log
        else 
            STATS_STOP_TIME=`datestamp`
            STATS_STOP_DELTA=`timestamp`
            format_stats_output
        fi
    fi
}

##
# Run stats for GX/C-Mode systems start/stop on list: $RUN_STATS using either presets or one long command line call
# PRECONDITIONS:
#  1. List of runnable stats for each filer should be constructed ($TMPDIR/$CUR_FILER/run_stats.list)
#  2. CUR_FILER is set
# PARAMS: None
##
do_stats_cmode()
{
    [ $CONF_ONLY = TRUE ] && return
 
    label="C-Mode"
    if [ $GXMODE = TRUE ] ; then
        label="GX"
    fi
    
    STATS_ACTION=$1
    if [ $STATS_ACTION = START ] ; then 
        return
    elif [ $STATS_ACTION = STOP ] ; then
        # Keep going
        echo "test" > /dev/null 2>/dev/null
    else 
        exit 15
    fi
    
    # First build the stats start or stats stop command
    echo "`datestamp`: Collecting ${label} data on $CUR_FILER" >> $TMPDIR/error.log
    debug "`datestamp`: Collecting ${label} data on $CUR_FILER"
    #$FILER_LOGIN = "admin"
    if [ $GXMODE = TRUE ] ; then
        BATCHMODE_SSH="$ROOT_CMD $SSHCMD $CUR_FILER -l $FILER_LOGIN ngsh"
    else
        BATCHMODE_SSH="$ROOT_CMD $SSHCMD $CUR_FILER -l $FILER_LOGIN "
    fi

    print_label "PERF $CUR_FILER" "statistics show"
    echo "TIME: `datestamp`"
    ## Diag statistics show - commented out per burt 378515
    # (echo "rows 0; set -confirmations off -showallfields true -showseparator ":::" -privilege diag; date show; statistics show" ; sleep ${histo_totalsecs} ; echo "date show; statistics show;" ) | $BATCHMODE_SSH    

    ## Non-diag statistics show
    (echo "rows 0; set -confirmations off -showallfields true -showseparator \":::\"; date show; statistics show" ; sleep ${histo_totalsecs} ; echo "date show; statistics show" ) | $BATCHMODE_SSH

    echo "`datestamp`:Finished ${label} data collection on $CUR_FILER" >> $TMPDIR/error.log
    debug "`datestamp`: Finished ${label} data collection on $CUR_FILER"
}

# Specialized "stutter" statit
do_stutter_statit()
{
    [ $CONF_ONLY = FALSE ] || return
    [ -f $TMPDIR/$CUR_FILER/statit_disable ] && return

    # statit has been reworked
    # the new scheme is
    # (1) for 1/2 the total run, take just 1 statit
    # (2) for second 1/2 of run, take them at histo_intervals
    # in reality, we'd like to do both, but statit is not reentrant
    if [ $FULL_STUTTER_STATIT = FALSE ] ; then
        # This is the default behavior to execute stutter statits for 1/2 of the histo_totalsecs and 
        # one long statit for the other half of histo_totalsecs
        statit_first=`expr $histo_totalsecs / 2`
        statit_count=`expr $histo_count / 2`
    else
        # This is the -K behavior which says execute all stutter statits over histo_totalsecs
        statit_first=`expr $histo_totalsecs`
        statit_count=`expr $histo_count`
    fi

    statit_interval=$histo_interval
    statit_count=`expr $statit_count - 2` #trim the end time a little
    debug "statit first: $statit_first  statit count: $statit_count  statit_interval: $statit_interval"

    #ONTAP7.0 is susceptible to 171830 so no stutter stait 
    if [ $STUTTER_STATIT = TRUE -a $fileros != ONTAP7.0 ] ; then
        #####
        # first 1/2 command 
        if [ $FULL_STUTTER_STATIT = FALSE ] ; then
            # This is the regular, default behavior with 1 long statit = 1/2 histo_time followed by a series of stutter statits
            echo "echo ---- statit first 1/2 --- $statit_first  seconds ---- ; echo Begin: \`date -u '+%a %b %d %T GMT %Y'\` ;  $FILER_RSH '$PRIV_SET statit -b $PRIV_UNSET' 2> /dev/null ; sleep  $statit_first  ;  $FILER_RSH '$PRIV_SET statit -e $PRIV_UNSET' 2> /dev/null ; echo End: \`date -u '+%a %b %d %T GMT %Y'\` " > $TMPDIR/$CUR_FILER/sstat.script
        fi
        # second 1/2 command
        echo "(x=1 ; while ( [ \$x -le " $statit_count " ] ) do echo ---- statit --- \$x --- ; echo \"Begin: \`date -u '+%a %b %d %T GMT %Y'\`\" ;   $FILER_RSH '$PRIV_SET statit -b $PRIV_UNSET' 2> /dev/null ; sleep  $statit_interval  ;  $FILER_RSH '$PRIV_SET statit -e $PRIV_UNSET' 2> /dev/null ; x=\`expr \$x + 1\` ; echo \"End: \`date -u '+%a %b %d %T GMT %Y'\`\" ; done)" >> $TMPDIR/$CUR_FILER/sstat.script 
        ######
    else #no stutter statit
    #if histo_interval was explicitly set, use it
        if [ "$histo_interval_set" = true ] ; then
            echo "(x=1 ; while ( [ \$x -le " $histo_count " ] ) do echo ---- statit --- \$x --- ; echo \"Begin: \`date -u '+%a %b %d %T GMT %Y'\`\" ;   $FILER_RSH '$PRIV_SET statit -b $PRIV_UNSET' 2> /dev/null ; sleep  $statit_interval  ;  $FILER_RSH '$PRIV_SET statit -e $PRIV_UNSET' 2> /dev/null ; x=\`expr \$x + 1\` ; echo \"End: \`date -u '+%a %b %d %T GMT %Y'\`\" ; done)" >> $TMPDIR/$CUR_FILER/sstat.script 
        else
            #just do a normal statit -b/statit -e
            do_filer "PERF" <<!
                statit -b
!
            return

        fi
    fi
  
    # Display the stutter statit script adding newlines after each ';'
    if [ $PRETEND = TRUE ] ; then
        echo >> $TMPDIR/pretend.stutter
        echo "=-=-=-=-=-=-= Begin statit script for: $CUR_FILER =-=-=-=-=-=-=" >> $TMPDIR/pretend.stutter
        # For pretty printing, replace the semi-colons with newlines
        cat $TMPDIR/$CUR_FILER/sstat.script | sed 's/;/& \
        /g;' >> $TMPDIR/pretend.stutter
        echo "=-=-=-=-=-=-= End statit script for: $CUR_FILER =-=-=-=-=-=-=" >> $TMPDIR/pretend.stutter
        echo >> $TMPDIR/pretend.stutter
        return
    fi
  
    echo "`datestamp` Statit $CUR_HOST (background)" >> $TMPDIR/error.log

    chmod a+x $TMPDIR/$CUR_FILER/sstat.script
    echo "stutter statit.out" > $TMPDIR/$CUR_FILER/statit.out
    $TMPDIR/$CUR_FILER/sstat.script >> $TMPDIR/$CUR_FILER/statit.out &
    echo $! >> $TMPDIR/bg_pidlist  #store process id
}

#backgrounded 'stats show' commands
do_background_stats()
{
    if [ $stats_ok = TRUE ] ; then
        #custom flexcache stats
        [ $FLEX_CACHE = TRUE ] && do_filer_background "stats show -i $histo_interval -n $sysstat_count  flexcache::total flexcache::hit_pure_perct flexcache::hit_verify_perct flexcache::miss_pure_perct flexcache::miss_verify_perct flexcache::proxy_perct sparse::nrv_op_remote_latency sparse::nrv_bytes_sent sparse::nrv_bytes_received sparse::sent_ops sparse::callback_rcvd_ops nrv::reqs_deferred nrv::reqs_deferred_sendbuf nrv::resp_sent nrv::resp_deferred nrv::reqs_entered_read_defer" "flexcache_stats.out"
        #basic per protocol stats
        do_filer_background "priv set admin ; stats show -r -i $histo_interval -n $sysstat_count system nfsv3 cifs fcp iscsi" "protocol_stats.out"
        #domain-specific stats (burt 358291)
        [ $DOMAIN_STATS = TRUE ] && do_filer_background "priv set -q diag; stats show -r -i $histo_interval -n $sysstat_count  system:system:time processor:*:domain_busy processor:*:processor_busy" "domain_stats.out"
    fi
}

#============================================================
#
# These are the core functions.
#
#   prestat_filer(), poststat_filer()
#   prestat_filer_background(), poststat_filer_background()
#   prestat_host(), poststat_host()
#   prestat_host_background(), poststat_host_background()
#
#============================================================

# background commmands for prestat filer
prestat_filer_background()
{
    if [ $histogram = TRUE ] ; then
        do_stutter_statit

        sysstat_count=`expr $histo_count - 1`
        sysstat_secs=`expr $histo_totalsecs - 5`

        [ $ISCSI = TRUE -o $FCP = TRUE ] && do_filer_background "lun stats -c $histo_count -i $histo_interval -o" "lun_stats.out"

        for vif in `cat $TMPDIR/$CUR_FILER/vif.list` ; do 
            console "VIF: $vif"
            do_filer_background "vif stat $vif 1" "vifstat_${vif}.out"
        done

        # Regular sysstat
        do_filer_background "sysstat -s -c $sysstat_count -x $histo_interval" "sysstat.out"
        # 1 second sysstats
        # If we're already collectin 1 second sysstats, there's no need to do it twice
        if [ $histo_interval -ne 1 ] ; then 
            do_filer_background "sysstat -s -c $sysstat_secs -x 1" "sysstat_1sec.out"
        fi
        # Sysstat with -M
        [ $MULTI_CPU_FILER = TRUE ] && do_filer_background "sysstat -M -s -c $sysstat_count $histo_interval" "sysstatM.out"

        do_background_stats
    fi

    do_profile_prestat
    do_sktrace_prestat
    
    #save stats ids in case of -b/-e
    echo $stats_id_list > $TMPDIR/stats_id_list
}

# background commmands for poststat
poststat_filer_background()
{
    [ $PRETEND = FALSE -o $CONF_ONLY = TRUE ] || return
    do_profile_poststat
    do_sktrace_poststat
    #if doing just a single long statit, do in the main process rather than background
    if [ $fileros = ONTAP7.0 -a ! -f $TMPDIR/$CUR_FILER/statit_disable ] || [ $STUTTER_STATIT = FALSE -a "$histo_interval_set" != true ]  ; then
        do_filer "PERF" <<!
            statit -e
!
    fi

    #display filer logs if any
    if [ $LOGS = TRUE -a $CUR_ITERATION = $ITERATIONS ] ; then
        #currently only log directory is /etc/log...
        for logdir in /etc/log ; do
            # directory listing goes to stderr???
            $FILER_RSH "$PRIV_SET ls $logdir $PRIV_UNSET" 2> $TMPDIR/lsout > /dev/null
#hack...
            TMP_CONF_ONLY=$CONF_ONLY
            CONF_ONLY=FALSE
            for file in `cat $TMPDIR/lsout` ; do
                # Skip some files . .. cm_stats and sktrace
                if [ $file = "." -o $file = ".." -o -n "`echo $file | grep 'cm_stats'`" -o -n "`echo $file | grep 'sktrace'`" ] ; then
                    debug "Skipping $logdir/$file"
                else
                    debug "Copying file $logdir/$file"
                    do_filer "PERF" <<!
                    rdfile $logdir/$file
!
                fi
            done
        CONF_ONLY=$TMP_CONF_ONLY
        done
    fi
}

# collect data dumped to each filer's tmp directory
collect_filer_tmp_data()
{
    # cat all files in /tmp/perfstat/$CUR_FILER
    if [ -d $TMPDIR/$CUR_FILER ] ; then
        for tmpfile in $TMPDIR/$CUR_FILER/* ; do
            filename=".../"`echo $tmpfile | sed 's/.*\///'` #strip path
            print_label "PERF $CUR_FILER" "$filename"
            if [ -n "$PASSWORD" ] ; then
                cat $tmpfile | sed "s/$PASSWORD/\*/g" 2> /dev/null
            else
                cat $tmpfile 2> /dev/null
            fi
            # burt252139 -- Since not all tmp files will gaurantee a trailing 
            # newline to separate command output, we echo one here
            echo
        done
    fi
}

#execute $1 and direct output to $2, $3 is command type
do_client_quick()
{
    if [ $CUR_HOST = $PERFHOST ] ; then
        do_log "$ROOT_CMD $1 > $TMPDIR/$2" $3
    else
        do_log "$ROOT_CMD $RSHCMD $CUR_HOST -n $1 > $TMPDIR/$2" $3
    fi
}
#
prestat_host_background()
{
    if [ "$machineos" = SunOS ] ; then
        #extract interface data for Solaris
        #not really a 'background' command, but this is a logical place for it

        #loop through available interfaces
        print_label "PERF $CUR_HOST" "ndd"
        do_client_quick "/sbin/ifconfig -a" "drivers" "quick"
    
        for driver in `cat $TMPDIR/drivers | sed 's/^\([a-z]*\).*/\1/' | sort -u ` ; do
                echo "Driver: $driver"
                do_client_quick "/usr/sbin/ndd -get /dev/$driver \?" "parameters" "quick"
                #loop through available parameters
                for parameter in `cat $TMPDIR/parameters | awk '{print $1}'` ; do 
                    if [ $parameter != '?' ] ; then
                        do_client_quick	"/usr/sbin/ndd -get /dev/$driver $parameter" "value" "host"
                        val=`cat $TMPDIR/value`
                        [ $PRETEND = FALSE ] && echo " $parameter: $val"
                    fi
                done
            done
    fi

    if [ "$machineos" = Linux -o "$machineos" = ESX ] ; then
        #extract interface data for Linux; Thanks Blake
        #not really a 'background' command, but this is a logical place for it
        print_label "PERF $CUR_HOST" "ethtool/mii-tool"
        do_client_quick "/sbin/ifconfig -a" "interfaces" "quick"
        for interface in `cat $TMPDIR/interfaces| grep eth | awk '{print $1}'` ; do
            do_client_quick "/sbin/ethtool $interface" "ethtool" "host"
            if [ $MII_TOOL = TRUE ] ; then
                do_client_quick "/sbin/mii-tool $interface" "mii-tool" "host"
            fi
            if [ $PRETEND = FALSE ] ; then
                echo "Interface: $interface"
                cat $TMPDIR/ethtool
                if [ $MII_TOOL = TRUE ] ; then
                    cat $TMPDIR/mii-tool
                fi
            fi
        done
    fi

    if [ "$machineos" = AIX ] ; then
        #extract interface data for AIX; Thanks Kevin & Blake
        print_label "PERF $CUR_HOST" "lsattr - interfaces"
        do_client_quick "lsdev -F name" "devices" "quick"
        for interface in `grep ent $TMPDIR/devices` ; do
            do_client_quick "lsattr -El $interface" "lsdev-ent.out" "host"
            if [ $PRETEND = FALSE ] ; then 
                echo "Interface: $interface"
                cat $TMPDIR/lsdev-ent.out
            fi
        done
        print_label "PERF $CUR_HOST" "lsattr - hdisks"
        for hdisk in `grep hdisk $TMPDIR/devices` ; do
            do_client_quick "lsattr -El $hdisk" "lsdev-hdisk.out" "host"
            if [ $PRETEND = FALSE ] ; then 
                echo "HDisk: $hdisk"
                cat $TMPDIR/lsdev-hdisk.out
            fi
        done
    fi
    
    # ESX qlogic node info (part of burt 293542)
    if [ "$machineos" = ESX ] ; then
        # extract HBA info for ESX; Thanks David Kelly!
        for i in `ls -1 /proc/scsi/qla2300 2>/dev/null | grep -v HbaApiNode`; do 
            print_label "PERF $CUR_HOST" "cat /proc/scsi/qla2300/$i"
            do_client_quick "cat /proc/scsi/qla2300/$i" "HbaApiNode.out" "host"
            if [ $PRETEND = FALSE ] ; then 
                echo "QLA2300 HbaApiNode: $i"
                cat $TMPDIR/HbaApiNode.out
            fi
        done
        
        for i in `ls -1 /proc/scsi/qla4022 2>/dev/null | grep -v HbaApiNode`; do 
            print_label "PERF $CUR_HOST" "cat /proc/scsi/qla4022/$i"
            do_client_quick "cat /proc/scsi/qla4022/$i" "HbaApiNode.out" "host"
            if [ $PRETEND = FALSE ] ; then 
                echo "QLA4022 HbaApiNode: $i"
                cat $TMPDIR/HbaApiNode.out
            fi
        done
    fi
    
    if [ $histogram = TRUE ] ; then
        case "$machineos" in 
            "SunOS")
                do_client_background "mpstat $histo_interval $histo_count" "mpstat.out"
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out" 
                do_client_background "iostat -nxz $histo_interval $histo_count" "iostat.out"
                do_client_background "iostat -i $histo_interval $histo_count" "iostat-i.out"
                do_client_background "sar -A $histo_interval $histo_count" "sar.out"
                do_client_background "prstat -ct -n 5 $histo_interval $histo_count" "prstat-ct.out"
                do_client_background "prstat -cv -n 5 $histo_interval $histo_count" "prstat-cv.out"
            ;;
            "Linux"|"ESX")
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out"
                # burt 289226 -- sar command syntax has changed in later versions of Linux RHEL
                # Also, post 2.6.17 kernels provide the -n option for displaying NFS stats via iostat
                if [ $RHEL5 = TRUE ] ; then
                    do_client_background "${SAR_PATH}sar -n ALL $histo_interval $histo_count" "sar.out"
                    do_client_background "${IOSTAT_PATH}iostat -tnkx $histo_interval $histo_count" "iostat-nkx.out"
                else
                    do_client_background "${SAR_PATH}sar -n FULL $histo_interval $histo_count" "sar.out"
                    do_client_background "${IOSTAT_PATH}iostat -t -x $histo_interval $histo_count" "iostat-x.out"
                fi
                do_client_background "${IOSTAT_PATH}iostat -t $histo_interval $histo_count" "iostat.out"
                do_client_background "mpstat -P ALL $histo_interval $histo_count" "mpstat.out"
            ;;
            "HP-UX")
                do_client_background "vmstat -d $histo_interval $histo_count" "vmstat.out" 
                do_client_background "iostat $histo_interval $histo_count" "iostat.out"
                do_client_background "sar -A $histo_interval $histo_count" "sar.out"
            ;;
            "AIX")
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out"
                do_client_background "iostat $histo_interval $histo_count" "iostat.out"
                do_client_background "sar -A $histo_interval $histo_count" "sar.out"
                do_client_background "iostat -D -l $histo_interval $histo_count" "iostat-D.out"
            ;;
            "OSF1")
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out"
                do_client_background "iostat $histo_interval $histo_count" "iostat.out"
            ;;
            "FreeBSD")
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out"
                do_client_background "iostat $histo_interval $histo_count" "iostat.out"
            ;;
            "OpenBSD")
                do_client_background "vmstat $histo_interval $histo_count" "vmstat.out"
                do_client_background "iostat $histo_interval $histo_count" "iostat.out"
            ;;
        esac
    fi
}
#
poststat_host_background()
{
    #display host logs if any
    if [ $LOGS = TRUE -a $CUR_ITERATION = $ITERATIONS ] ; then
        for logdir in /var/log /var/adm /var/adm/syslog /etc; do
            # Disregard named pipes, directories, and symlinks on hosts -- burt193164
            do_client_quick "ls -F1 $logdir | grep [^@\|/]\$" "lsout" "quick"
            for file in `cat $TMPDIR/lsout` ; do
                do_client "PERF" <<!
            cat $logdir/$file
!
            done
        done
    fi

    if [ -d $TMPDIR/$CUR_HOST ] ; then
        for tmpfile in $TMPDIR/$CUR_HOST/* ; do
            # If tmpfile is a file, then cat it up
            if [ -f $tmpfile ] ; then
                filename=".../"`echo $tmpfile | sed 's/.*\///'` #strip path
                print_label "PERF $CUR_HOST" "$filename"
                cat $tmpfile 2> /dev/null
            fi
        done
    fi
}
#
prestat_host_app()
{
    [ $ORACLE_ON = TRUE ] && prestat_oracle
    [ $VERITAS_ON = TRUE ] && prestat_veritas
}
#
poststat_host_app(){
    [ $ORACLE_ON = TRUE ] && poststat_oracle
    [ $VERITAS_ON = TRUE ] && poststat_veritas
}
#
prestat_veritas()
{
    # Solaris
    if [ "$machineos" = SunOS ] ; then
        #check to see if vxdisk installed
        VXD_SOLARIS=/usr/sbin/vxdisk
        if [ -x $VXD_SOLARIS ] ; then
            do_client "CONFIG" <<!
            $VXD_SOLARIS list
            $VXD_SOLARIS -s list
            cat -s /kernel/drv/vxdmp.conf
            cat -s /etc/vx/cntrls.exclude
!
        fi

        #check to see if vxddladm installed
        VXD_SOLARIS="/usr/sbin/vxddladm"
        if [ -x $VXD_SOLARIS ] ; then
            do_client "CONFIG" <<!
            $VXD_SOLARIS listjbod
            $VXD_SOLARIS listsupport
            $VXD_SOLARIS listexclude
!
        fi
fi
}
#
postat_veritas()
{
    :
}
#
oracle_usage()
{
    echo "Perfstat: Version $VERSION $DATE"
    cat << !

    Perfstat can be used to gather Oracle STATSPACK data from one host.
    The Oracle instance must be running before Perfstat is invoked.
    The -o flag is used to pass statspack specific options to perfstat.  
    The options and their default values are:
        oracle_host=\`hostname\`
        sqlplus="sqlplus"
        oracle_login="perfstat/perfstat"
        runas=""
        sysdba="false"

    -oracle_host defaults to localhost, but may be one of the hosts specified with -h
    -sqlplus can be used to specify an absolute path to 'sqlplus' command
    -runas can be used to run sqlplus as a different user
    -sysdba can be used to connect to oracle as sysdba, ignoring the oracle_login parameter

     Examples:

     perfstat.sh -a oracle
     perfstat.sh -h host1 -a oracle -o oracle_host=host1
     perfstat.sh -h host1 -a oracle -o oracle_host=host1,sqlplus=/oracle/bin/sqlplus/
     perfstat.sh -a oracle -o oracle_login=user/pass
     perfstat.sh -a oracle -o runas=oracle,sysdba=true
     ...
!

    exit 1
}

#extract oracle specific options (APP_PARAM, after -o)
parse_oracle_options()
{
    ORACLE_HOST=`hostname`
    SEQLPLUS="sqlplus"
    ORACLE_LOGIN="perfstat/perfstat"
    ORACLE_RUNAS=""
    ORACLE_SYSDBA="false"
    for param in `echo $APP_PARAM | sed 's/,/ /g'` ; do
        opt=`echo $param | sed 's/=.*//'`
        arg=`echo $param | sed 's/.*=//'`
        case "$opt" in
            "oracle_host") ORACLE_HOST="$arg"
            ;;
            "sqlplus") SEQLPLUS="$arg"
            ;;
            "oracle_login") ORACLE_LOGIN="$arg"
            ;;
            "sysdba") ORACLE_SYSDBA="$arg"
            ;;
            "runas") ORACLE_RUNAS="$arg"
            ;;
            *) oracle_usage
            ;;
        esac
    done

    [ $ORACLE_SYSDBA = true ]  && ORACLE_LOGIN="/nolog"
}
#
prestat_oracle()
{
    [ $CONF_ONLY = FALSE -a $PRETEND = FALSE -a $CUR_HOST = $ORACLE_HOST ] || return
    #create AWR report script
    echo "" > $TMPDIR/awr_snap
    [ $ORACLE_SYSDBA = true ] && echo "connect / as sysdba" >> $TMPDIR//awr_snap
	echo "BEGIN " >> $TMPDIR//awr_snap
	echo "DBMS_WORKLOAD_REPOSITORY.create_snapshot();" >>$TMPDIR/awr_snap
	echo "END; " >>$TMPDIR/awr_snap
	echo "/"  >>$TMPDIR/awr_snap;
	echo "exit;" >> $TMPDIR/awr_snap
	
    if [ $CUR_HOST = $PERFHOST ] ; then
        if [ -z "$ORACLE_RUNAS" ]  ; then
		    do_log "$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/awr_snap > $TMPDIR/awr_snap.out" "host"
        else
            console "Running SeEQLPLUS as user $ORACLE_RUNAS"
            chmod a+w $TMPDIR
		do_log "su - $ORACLE_RUNAS -c \"$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/awr_snap > $TMPDIR/awr_snap.out\"" "host"
        fi
    else
        [ -n "$ORACLE_RUNAS" ] && console "Warning: Ignoring oracle_login for remote oracle host $CUR_HOST!"
	    do_log "$ROOT_CMD $RSHCMD $CUR_HOST \"$SEQLPLUS $ORACLE_LOGIN\" < $TMPDIR/awr_snap > $TMPDIR/awr_snap.out" "host"
    fi
    
	#Now Query the Oracle DB to get this SnapShot ID
	echo "" > $TMPDIR/snap_shot
	[ $ORACLE_SYSDBA = true ] && echo "connect / as sysdba" >> $TMPDIR/snap_shot
	echo "select SNAP_ID from dba_hist_snapshot order by SNAP_ID;" >>$TMPDIR/snap_shot
	echo "exit;" >>$TMPDIR/snap_shot

    if [ $CUR_HOST = $PERFHOST ] ; then
        if [ -z "$ORACLE_RUNAS" ]  ; then
            do_log "$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out" "host"
        else
            console "Running SeEQLPLUS as user $ORACLE_RUNAS"
            chmod a+w $TMPDIR
            do_log "su - $ORACLE_RUNAS -c \"$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out\"" "host"
        fi
    else
        [ -n "$ORACLE_RUNAS" ] && console "Warning: Ignoring oracle_login for remote oracle host $CUR_HOST!"
        do_log "$ROOT_CMD $RSHCMD $CUR_HOST \"$SEQLPLUS $ORACLE_LOGIN\" < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out" "host"
    fi
	#End shapShot ID
	
	BEGIN_SNAP_ID=`cat $TMPDIR/snap_shot.out |grep '^[ \t\r\n\f]' |tail -n 1`
	print_label "PERF $CUR_HOST" "ORACLE AWR Report begin"
	echo ; echo "AWR Report Begin Snap ID: $BEGIN_SNAP_ID"
	console "Saved beginning snapshot of Oracle AWR Report - ID: $BEGIN_SNAP_ID"
}
#
poststat_oracle()
{
    [ $CONF_ONLY = FALSE -a $PRETEND = FALSE -a $CUR_HOST = $ORACLE_HOST ] || return

	print_label "PERF $CUR_HOST" "ORACLE AWR Report End"
    #get end snapshot
    if [ $CUR_HOST = $PERFHOST ] ; then
        if [ -z "$ORACLE_RUNAS" ]  ; then
		do_log "$SEQLPLUS $ORACLE_LOGIN <$TMPDIR/awr_snap > $TMPDIR/awr_snap.out_2" "host"
        else
            console "Running $SEQLPLUS as user $ORACLE_RUNAS"
            chmod a+w $TMPDIR
		do_log "su - "$ORACLE_RUNAS" -c \"$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/awr_snap > $TMPDIR/awr_snap.out_2\"" "host"
        fi
    else
        [ -n "$ORACLE_RUNAS" ] && console "Warning: Ignoring oracle_login for remote oracle host $CUR_HOST!"
	do_log "$ROOT_CMD $RSHCMD $CUR_HOST \"$SEQLPLUS $ORACLE_LOGIN\" < $TMPDIR/awr_snap > $TMPDIR/awr_snap.out_2"  "host"
    fi

	#Get the End snapshot ID

    if [ $CUR_HOST = $PERFHOST ] ; then
        if [ -z "$ORACLE_RUNAS" ]  ; then
                do_log "$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out_2" "host"
        else
            console "Running SeEQLPLUS as user $ORACLE_RUNAS"
            chmod a+w $TMPDIR
                do_log "su - $ORACLE_RUNAS -c \"$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out_2\"" "host"
        fi
    else
        [ -n "$ORACLE_RUNAS" ] && console "Warning: Ignoring oracle_login for remote oracle host $CUR_HOST!"
        do_log "$ROOT_CMD $RSHCMD $CUR_HOST \"$SEQLPLUS $ORACLE_LOGIN\" < $TMPDIR/snap_shot > $TMPDIR/snap_shot.out_2" "host"
    fi

	#extract snap id from the output...
	
	END_SNAP_ID=`cat $TMPDIR/snap_shot.out_2 |grep '^[ \t\r\n\f]' |tail -n 1`

	#create AWR report script
	echo "" >  $TMPDIR/AWR_rep
	[ $ORACLE_SYSDBA = true ] && echo "connect / as sysdba" >> $TMPDIR/AWR_rep
	echo "define report_type  = 'text';" >>$TMPDIR/AWR_rep
	echo "define   num_days     = 1;"  >>$TMPDIR/AWR_rep
	echo "define  begin_snap=$BEGIN_SNAP_ID" >> $TMPDIR/AWR_rep
	echo "define  end_snap=$END_SNAP_ID" >> $TMPDIR/AWR_rep
	echo "define report_name  = AWR_report.text" >> $TMPDIR/AWR_rep
	echo "@\$ORACLE_HOME/rdbms/admin/awrrpt.sql;" >> $TMPDIR/AWR_rep
	echo "exit;" >>$TMPDIR/AWR_rep
	echo ; echo "AWR Report End Snap ID: $END_SNAP_ID"
	

    #generate report
    if [ $CUR_HOST = $PERFHOST ] ; then
        if [ -z "$ORACLE_RUNAS" ]  ; then
		do_log "$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/AWR_rep" "host"
        else
            console "Running $SEQLPLUS as user $ORACLE_RUNAS"
            chmod a+w $TMPDIR
		do_log "su - $ORACLE_RUNAS -c \"$SEQLPLUS $ORACLE_LOGIN < $TMPDIR/AWR_rep\"" "host"
        fi
    else
        [ -n "$ORACLE_RUNAS" ] && console "Warning: Ignoring oracle_login for remote oracle host $CUR_HOST!"
	do_log "$ROOT_CMD $RSHCMD $CUR_HOST \"$SEQLPLUS $ORACLE_LOGIN\" < $TMPDIR/AWR_rep" "host"
    fi

    console "Saved ending snapshot of Oracle AWR Report- ID: $END_SNAP_ID"
    console "Generated Oracle AWR report"
}
#
do_vfiler()
{
    while read vfiler ; do
        name=`echo $vfiler | awk '{print $1}'`
        path=`echo $vfiler | awk '{print $2}'`
        CUR_VFILER=":[VF]:$name"
        debug " VFiler: $vfiler on $CUR_FILER"
        print_label "BEGIN" "${CUR_FILER}${CUR_VFILER}"
        #CONFCMDS_VFILER & $PERFCMDS_VFILER are created in pre/poststat_filer
        sed s/VFNAME/$name/ < $CONFCMDS_VFILER > $TMPDIR/tmp
        sed "s|VFPATH|$path|" < $TMPDIR/tmp > $CONFCMDS

        sed s/VFNAME/$name/ < $PERFCMDS_VFILER > $TMPDIR/tmp
        sed "s|VFPATH|$path|" < $TMPDIR/tmp > $PERFCMDS

        if [ "$PERF_ONLY" = "FALSE" ] ; then
            do_filer "CONFIG" < $CONFCMDS
        fi
        if [ "$CONF_ONLY" = "FALSE" ] ; then
            do_filer "PERF" < $PERFCMDS
        fi

        print_label "END" "${CUR_FILER}${CUR_VFILER}"
        CUR_VFILER=""
    done
}
#
# use 'script building' technique from stutter statit
#
do_profile_prestat()
{
    # Why is this here??
    MULTI_CPU_FILER=TRUE

    [ $CONF_ONLY = TRUE -o $PRETEND = TRUE -o $PROFILES = FALSE -o $histogram = FALSE ] && return

    rm -f $TMPDIR/$CUR_FILER/profile_info.txt > /dev/null  2>&1
    rm -f $TMPDIR/$CUR_FILER/profile.script > /dev/null  2>&1

    #ls output goes to stderr...
    $FILER_RSH "$PRIV_SET ls / $PRIV_UNSET" 2> $TMPDIR/lsout > /dev/null
    for file in `cat $TMPDIR/lsout | grep gmon` ; do
        debug "Deleting existing profile file: $file"
        do_log "$FILER_RSH \"$PRIV_SET rm /$file $PRIV_UNSET\"" "filer"
    done
    num_domains=`echo $DOMAINS | wc -w`
    prof_time=`expr $histo_totalsecs / $num_domains`
    prof_time=`expr $prof_time - 5`

    debug "Profile domains: $DOMAINS ($num_domains)"
    debug "Profile time: $prof_time"
    debug "Capturing profiles on $CUR_FILER: $DOMAINS"

    echo "Capturing profiles: $PROFILE_DOMAINS on $CUR_FILER" > $TMPDIR/$CUR_FILER/profile_info.txt
    for domain in $DOMAINS ; do
        if [ $MULTI_CPU_FILER = FALSE ]  &&  [ "$domain" != flat ] ; then
            console "Warning: Collecting \"$domain\" profile on single processor filer."
        fi
        [ "$domain" = flat ] && domain=""
        echo  "echo Begin profile $domain on $CUR_FILER: \`date -u '+%a %b %d %T GMT %Y'\` >> $TMPDIR/$CUR_FILER/profile_info.txt ; $FILER_RSH '$PRIV_SET prof reset ; prof on $domain $PRIV_UNSET' 2> /dev/null ; sleep $prof_time ; $FILER_RSH '$PRIV_SET prof off ; prof dump ' 2> /dev/null ; echo End profile $domain on $CUR_FILER: \`date -u '+%a %b %d %T GMT %Y'\` >> $TMPDIR/$CUR_FILER/profile_info.txt "  >> $TMPDIR/$CUR_FILER/profile.script
    done

    echo "`datestamp` Profile $CUR_FILER (background)" >> $TMPDIR/error.log
    chmod a+x $TMPDIR/$CUR_FILER/profile.script
    $TMPDIR/$CUR_FILER/profile.script 2> /dev/null &
    echo $! >> $TMPDIR/bg_pidlist  #store process id
}
#
do_profile_poststat()
{
    [ $CONF_ONLY = TRUE -o $PRETEND = TRUE -o $PROFILES = FALSE -o $histogram = FALSE ] && return
    # Unique id for prof data tar file name
    prof_id=`date +"%Y%m%d%H%M%S"`
    # Temp dir for profile data
    prof_tmp=$TMPDIR/$CUR_FILER/gmon
    debug "Creating profile tmp dir $prof_tmp..."
    mkdir -p ${prof_tmp}
    
    echo "-Finished capturing profiles on $CUR_FILER; `datestamp`" >> $TMPDIR/$CUR_FILER/profile_info.txt
    echo "Saving profile data files as ${CUR_FILER}_${prof_id}_gmon.tar.gz : " >> $TMPDIR/$CUR_FILER/profile_info.txt
    $FILER_RSH "$PRIV_SET ls / $PRIV_UNSET" 2>&1 | grep gmon > $TMPDIR/lsout 
    cat $TMPDIR/lsout  >> $TMPDIR/$CUR_FILER/profile_info.txt
    for file in `cat $TMPDIR/lsout` ; do
        debug "Copying profile data from $CUR_FILER: $file"
        eval "$FILER_RSH \"$PRIV_SET rdfile /$file $PRIV_UNSET\" > ${prof_tmp}/${CUR_FILER}_${CUR_ITERATION}_$file"
        debug "Removing profile data on $CUR_FILER: $file"
        do_log "$FILER_RSH \"$PRIV_SET rm /$file $PRIV_UNSET\"" "filer"
    done
    # Rename profile_info.txt for uniqueness
    cp $TMPDIR/$CUR_FILER/profile_info.txt ${prof_tmp}/${CUR_FILER}_${CUR_ITERATION}_profile_info.txt
    #add profile data to archive
    if [ -f ${CUR_FILER}_${prof_id}_gmon.tar ] ; then
        tarflag="uf"
    else
        tarflag="cf"
    fi
    tar $tarflag ./${CUR_FILER}_${prof_id}_gmon.tar -C ${prof_tmp} . > /dev/null 2>&1
    debug "Deleting contents in $prof_tmp..."
    rm -rR -f ${prof_tmp}
}
#
# Builds a script 'on-the-fly' to capture sktrace data. The script will be in (one for each filer) TMPDIR/cur_filer/sktrace.script. 
# Before leaving this proc the script will get backgrounded and it's pid will get saved.
# NOTE: There is logic in here to work around the race condition documented in burt 139610
#
do_sktrace_prestat()
{
    [ $PRETEND = TRUE -o $SKTRACE = FALSE -o $histogram = FALSE -o $sktrace_nok = TRUE ] && return
    
    rm -f $TMPDIR/$CUR_FILER/sktrace_info.txt > /dev/null  2>&1
    rm -f $TMPDIR/$CUR_FILER/sktrace.script > /dev/null  2>&1
    #
    # Calculate a reasonable sleep time for sktrace (no more than 60 seconds)
    # If our sleep time between PRESTATS->POSTSTATS is around 60 seconds, then shave off
    # 15 seconds so our backgrounded sktrace process stops in time and doesn't get killed
    #
    sktrace_time=0
    if [ $histo_totalsecs -le 60 ] ; then 
        sktrace_time=45
    else
        sktrace_time=60
    fi
    # Start timestamp in info file
    sktrace_script="echo \`date -u '+%a %b %d %T GMT %Y'\`: Begin sktrace on $CUR_FILER >> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
    # Set the buffer size and turn on tracing
    sktrace_script="${sktrace_script} $FILER_RSH '$PRIV_SET trace start -b $SKTRACE_BUF_SIZE ;"
    # Add cmd for enabling trace points
    sktrace_script="${sktrace_script} trace enable $SKTRACE_POINTS ; $PRIV_UNSET' 2>> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
    # Sleep time between trace start and trace stop
    sktrace_script="${sktrace_script} sleep $sktrace_time ;"     
    # Next add cmds for disabling the trace points
    # For disabling, we need to only specify the trace point, not the level
    sktrace_script="${sktrace_script} $FILER_RSH '$PRIV_SET"
    count=0
    for trace_point in $SKTRACE_POINTS ; do
        if [ `expr $count % 2` = 0 ] ; then
            sktrace_script="${sktrace_script} trace disable $trace_point ;"
        fi
        count=`expr $count + 1`
    done
    # Now do the trace dump
    sktrace_script="${sktrace_script} trace dump /etc/log/sktrace_perfstat ; $PRIV_UNSET' 2>> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
    # Sleep for 5 seconds before doing trace stop to avoid race condition outlined in burt 139610
    sktrace_script="${sktrace_script} sleep 5 ; $FILER_RSH '$PRIV_SET trace stop ; $PRIV_UNSET' 2>> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
    # If we've specified trace on the DISK point we need to collect 'sysconfig -r' and 'disk_list' to do proper disk -> msg mappings
    if [ $GET_DISK_MAPPINGS = TRUE ] ; then
        sktrace_script="${sktrace_script} echo \`date -u '+%a %b %d %T GMT %Y'\`: Capture sysconfig -r on $CUR_FILER >> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
        sktrace_script="${sktrace_script}  $FILER_RSH '$PRIV_SET sysconfig -r ; $PRIV_UNSET' > $TMPDIR/$CUR_FILER/sktrace_sysconfig.txt 2>> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
        sktrace_script="${sktrace_script} echo \`date -u '+%a %b %d %T GMT %Y'\`: Capture disk_list on $CUR_FILER >> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
        sktrace_script="${sktrace_script}  $FILER_RSH '$PRIV_SET disk_list ; $PRIV_UNSET' > $TMPDIR/$CUR_FILER/sktrace_disk_list.txt 2>> $TMPDIR/$CUR_FILER/sktrace_info.txt ;"
    fi
    sktrace_script="${sktrace_script} echo \`date -u '+%a %b %d %T GMT %Y'\`: End sktrace on $CUR_FILER >> $TMPDIR/$CUR_FILER/sktrace_info.txt"
    
    debug "Backgrounding sktrace script: $sktrace_script"
    echo $sktrace_script >> $TMPDIR/$CUR_FILER/sktrace.script
    chmod +x $TMPDIR/$CUR_FILER/sktrace.script
    $TMPDIR/$CUR_FILER/sktrace.script 2> /dev/null &
    echo $! >> $TMPDIR/bg_pidlist  #store process id
}
#
# Copies the trace data off of the filer and into an archive file in the current directory where perfstat was invoked from.
# The final sktrace archive files be './cur_filer_timestamp_sktrace.tar'
#
do_sktrace_poststat()
{
    [ $PRETEND = TRUE -o $SKTRACE = FALSE -o $histogram = FALSE -o $sktrace_nok = TRUE ] && return
    
    sktrace_id=`date +"%Y%m%d%H%M%S"`
    # Directory to store all sktrace data for this iteration
    outdir="./${CUR_FILER}_ITR_${CUR_ITERATION}_${sktrace_id}_sktrace"
    mkdir -p $outdir 2>/dev/null
    echo "`datestamp`: Copying sktrace from $CUR_FILER to $outdir" >> $TMPDIR/$CUR_FILER/sktrace_info.txt
    echo "Saving sktrace data files as ${outdir}.tar" >> $TMPDIR/$CUR_FILER/sktrace_info.txt
    
    # Now get an ls output of all sktraces available in /etc/log/sktrace* on the filer
    $FILER_RSH "$PRIV_SET ls /etc/log $PRIV_UNSET" 2>&1 | grep sktrace_perfstat > $TMPDIR/lsout 
    cat $TMPDIR/lsout  >> $TMPDIR/$CUR_FILER/sktrace_info.txt
    #mkdir -p $TMPDIR/$CUR_FILER/sktrace
    for file in `cat $TMPDIR/lsout` ; do
        debug "Copying /etc/log/${file} to ${outdir}/${CUR_FILER}_${CUR_ITERATION}_$file"
        echo "`datestamp`: Copying /etc/log/${file} to ${outdir}/${CUR_FILER}_${CUR_ITERATION}_$file" >> $TMPDIR/error.log
        eval "$FILER_RSH \"$PRIV_SET rdfile /etc/log/$file $PRIV_UNSET\" > ${outdir}/${CUR_FILER}_${CUR_ITERATION}_${file} 2>> $TMPDIR/error.log" 
        echo "`datestamp`: Removing /etc/log/${file} from ${CUR_FILER}" >> $TMPDIR/error.log
        echo "`datestamp`: Removing /etc/log/${file} from ${CUR_FILER}" >> $TMPDIR/$CUR_FILER/sktrace_info.txt
        eval "$FILER_RSH \"$PRIV_SET rm /etc/log/$file $PRIV_UNSET\" 2>> $TMPDIR/error.log"
    done
    
    # Put info file in archive
    cp $TMPDIR/$CUR_FILER/sktrace_info.txt $outdir/sktrace_info.txt
    # Also include sysconfig and disk list info in archive if DISK module was specified
    if [ $GET_DISK_MAPPINGS = TRUE ] ; then
        cp $TMPDIR/$CUR_FILER/sktrace_sysconfig.txt $outdir/sktrace_sysconfig.txt
        cp $TMPDIR/$CUR_FILER/sktrace_disk_list.txt $outdir/sktrace_disk_list.txt
    fi
    
    #create the archive
    tar cf ./${outdir}.tar ${outdir} > /dev/null 2>&1
    # cleanup tmpdir
    rm -rR -f ${outdir} > /dev/null 2>&1
}

################################## #BEGIN CORE FUNCTIONS
#prestat_filer
prestat_filer(){
	CONFCMDS=$TMPDIR/CONFCMDS
	CONFCMDS_VFILER=$TMPDIR/CONFCMDS_VFILER
	rm -f $CONFCMDS
	touch $CONFCMDS

	rm -f $CONFCMDS_VFILER
	touch $CONFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "exportfs" >> $CONFCMDS
		echo "fcstat device_map" >> $CONFCMDS
		echo "snap sched" >> $CONFCMDS
		echo "df" >> $CONFCMDS
		echo "storage show disk -p" >> $CONFCMDS
		echo "sysconfig -av" >> $CONFCMDS
		echo "dns info" >> $CONFCMDS
		echo "uptime" >> $CONFCMDS
		echo "rdfile /etc/nsswitch.conf" >> $CONFCMDS
		echo "rdfile /etc/dgateways" >> $CONFCMDS
		echo "rdfile /etc/hosts.equiv" >> $CONFCMDS
		echo "netdiag -v -b " >> $CONFCMDS
		echo "timezone" >> $CONFCMDS
		echo "storage alias" >> $CONFCMDS
		echo "printflag" >> $CONFCMDS
		echo "snap reserve" >> $CONFCMDS
		echo "qtree status" >> $CONFCMDS
		echo "fcstat link_stats" >> $CONFCMDS
		echo "vif status" >> $CONFCMDS
		echo "vlan stat" >> $CONFCMDS
		echo "df -h" >> $CONFCMDS
		echo "options" >> $CONFCMDS
		echo "environment status" >> $CONFCMDS
		echo "ifconfig -a" >> $CONFCMDS
		echo "storage show tape" >> $CONFCMDS
		echo "vfiler status -a" >> $CONFCMDS
		echo "date -u" >> $CONFCMDS
		echo "fcstat fcal_stats" >> $CONFCMDS
		echo "rdfile /etc/exports" >> $CONFCMDS
		echo "df -i" >> $CONFCMDS
		echo "storage show" >> $CONFCMDS
		echo "sysconfig -r" >> $CONFCMDS
		echo "storage show mc" >> $CONFCMDS
		echo "rdfile /etc/rc" >> $CONFCMDS
		echo "rdfile /etc/hosts" >> $CONFCMDS
		echo "license" >> $CONFCMDS
		echo "snmp" >> $CONFCMDS
		echo "df -r" >> $CONFCMDS
		echo "nis info " >> $CONFCMDS
		echo "rdfile /etc/serialnum" >> $CONFCMDS
		echo "routed status" >> $CONFCMDS
	fi

	if [ $SNAPMIRROR = TRUE ] ; then
		echo "rdfile /etc/snapmirror.conf" >> $CONFCMDS
		echo "snapmirror status " >> $CONFCMDS
		echo "snapmirror status -l" >> $CONFCMDS
		echo "snapmirror destinations -s" >> $CONFCMDS
	fi


	if [ $SNAPVAULT = TRUE ] ; then
		echo "snapvault status -c" >> $CONFCMDS
		echo "snapvault destinations -s" >> $CONFCMDS
		echo "snapvault status -s" >> $CONFCMDS
		echo "snapvault status " >> $CONFCMDS
		echo "snapvault status -l" >> $CONFCMDS
		echo "snapvault snap sched" >> $CONFCMDS
	fi


	if [ $VFILER = TRUE ] ; then
		echo "rdfile VFPATH/etc/exports" >> $CONFCMDS_VFILER
		echo "rdfile VFPATH/etc/nsswitch.conf" >> $CONFCMDS_VFILER
		echo "rdfile VFPATH/etc/hosts.equiv" >> $CONFCMDS_VFILER
		echo "vfiler run VFNAME qtree status" >> $CONFCMDS_VFILER
		echo "rdfile VFPATH/etc/cifsconfig.cfg" >> $CONFCMDS_VFILER
		echo "rdfile VFPATH/etc/hosts" >> $CONFCMDS_VFILER
		echo "rdfile VFPATH/etc/dgateways" >> $CONFCMDS_VFILER
	fi


	if [ $CIFS = TRUE ] ; then
		echo "rdfile /etc/usermap.cfg" >> $CONFCMDS
		echo "rdfile /etc/lclgroups.cfg" >> $CONFCMDS
		echo "rdfile /etc/cifsconfig.cfg" >> $CONFCMDS
		echo "cifs shares" >> $CONFCMDS
	fi


	if [ $FLEX_CACHE = TRUE ] ; then
		echo "df -L" >> $CONFCMDS
		echo "df -i -L" >> $CONFCMDS
		echo "df -h -L" >> $CONFCMDS
		echo "df -r -L" >> $CONFCMDS
	fi


	if [ $VFILER = TRUE -a $CIFS = TRUE ] ; then
		echo "vfiler run VFNAME cifs shares" >> $CONFCMDS_VFILER
	fi


	if [ $VFILER = TRUE -a $FCP = TRUE -o $VFILER = TRUE -a $ISCSI = TRUE ] ; then
		echo "vfiler run VFNAME lun show -v all" >> $CONFCMDS_VFILER
		echo "vfiler run VFNAME options" >> $CONFCMDS_VFILER
		echo "vfiler run VFNAME igroup show" >> $CONFCMDS_VFILER
		echo "vfiler run VFNAME lun show -m" >> $CONFCMDS_VFILER
	fi


	if [ $FCP = TRUE -o $ISCSI = TRUE ] ; then
		echo "lun config_check -v" >> $CONFCMDS
		echo "lun show -v all" >> $CONFCMDS
		echo "lun show -m" >> $CONFCMDS
		echo "igroup show" >> $CONFCMDS
		echo "options lun" >> $CONFCMDS
	fi


	if [ $ISCSI = TRUE ] ; then
		echo "iscsi nodename" >> $CONFCMDS
		echo "iscsi isns show" >> $CONFCMDS
		echo "iscsi status" >> $CONFCMDS
		echo "iscsi security show" >> $CONFCMDS
		echo "options iscsi" >> $CONFCMDS
	fi


	if [ $NETCACHE = TRUE ] ; then
		echo "show config.*" >> $CONFCMDS
		echo "netstat -p tcp" >> $CONFCMDS
	fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
		echo "vfiler run VFNAME iscsi nodename" >> $CONFCMDS_VFILER
		echo "vfiler run VFNAME iscsi status" >> $CONFCMDS_VFILER
	fi


	if [ "$fileros" = ONTAP8.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$fileros" = ONTAP7.3.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "igroup show -v" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.7 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.4 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "igroup show -v" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP10.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -r" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "igroup show -v" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER != TRUE ] ; then
			echo "rdfile /etc/registry" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "igroup show -v" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.1.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP6.5.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi show initiator" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi config" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi show adapter" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER != TRUE ] ; then
			echo "rdfile /etc/registry" >> $CONFCMDS_VFILER
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iscsi show adapter" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
			echo "iswt interface show" >> $CONFCMDS
			echo "iscsi config" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iscsi show initiator" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP8.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP8.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "sasadmin adapter_state" >> $CONFCMDS
			echo "snap list -n" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "vol status -v" >> $CONFCMDS
			echo "aggr status -v" >> $CONFCMDS
			echo "snap list -n -A" >> $CONFCMDS
			echo "rdfile /etc/registry" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "snap status" >> $CONFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "rdfile VFPATH/etc/cifsconfig_setup.cfg" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/registry" >> $CONFCMDS_VFILER
			echo "rdfile VFPATH/etc/cifsconfig_share.cfg" >> $CONFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "rdfile /etc/cifsconfig_share.cfg" >> $CONFCMDS
			echo "rdfile /etc/cifsconfig_setup.cfg" >> $CONFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "df -A -h -L" >> $CONFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp show cfmode" >> $CONFCMDS
			echo "fcp show initiator -v" >> $CONFCMDS
			echo "fcp nodename" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "options fcp" >> $CONFCMDS
			echo "fcp show adapter -v" >> $CONFCMDS
			echo "fcp config " >> $CONFCMDS
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi portal show" >> $CONFCMDS
			echo "igroup show -v" >> $CONFCMDS
			echo "iscsi initiator show" >> $CONFCMDS
			echo "iscsi tpgroup show" >> $CONFCMDS
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
			echo "iscsi alias" >> $CONFCMDS
		fi


	if [ $VFILER = TRUE -a $ISCSI = TRUE ] ; then
			echo "vfiler run VFNAME iscsi initiator show" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi alias" >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME iscsi connection show " >> $CONFCMDS_VFILER
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi


	if [ $VFILER = TRUE -a $FCP = TRUE ] ; then
			echo "vfiler run VFNAME igroup show -v" >> $CONFCMDS_VFILER
		fi

	fi

	if [ $PERF_ONLY = FALSE ] ; then
		do_filer "CONFIG" < $CONFCMDS
	fi

	PERFCMDS=$TMPDIR/PERFCMDS
	PERFCMDS_VFILER=$TMPDIR/PERFCMDS_VFILER
	rm -f $PERFCMDS
	touch $PERFCMDS

	rm -f $PERFCMDS_VFILER
	touch $PERFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "netstat -x" >> $PERFCMDS
		echo "netstat -i" >> $PERFCMDS
		echo "hostname" >> $PERFCMDS
		echo "netstat -m" >> $PERFCMDS
		echo "raid_config -xz" >> $PERFCMDS
		echo "version" >> $PERFCMDS
		echo "ifstat -a -v" >> $PERFCMDS
		echo "httpstat" >> $PERFCMDS
		echo "backup status" >> $PERFCMDS
		echo "storage stats tape zero" >> $PERFCMDS
		echo "mbstat" >> $PERFCMDS
		echo "netstat -rn" >> $PERFCMDS
		echo "ifstat -a" >> $PERFCMDS
		echo "storage stats tape" >> $PERFCMDS
		echo "vol scrub status -v" >> $PERFCMDS
		echo "netstat -s" >> $PERFCMDS
		echo "ifstat -z -a   " >> $PERFCMDS
		echo "wafl_susp -z" >> $PERFCMDS
		echo "ps -z" >> $PERFCMDS
		echo "httpstat -z" >> $PERFCMDS
	fi

	if [ $CIFS = TRUE ] ; then
		echo "cifs sessions" >> $PERFCMDS
		echo "vscan" >> $PERFCMDS
		echo "cifs stat" >> $PERFCMDS
		echo "nfs_hist -t queue" >> $PERFCMDS
		echo "cifs sessions -t -c" >> $PERFCMDS
		echo "smb_hist" >> $PERFCMDS
		echo "smb_hist -z" >> $PERFCMDS
		echo "cifs stat -z" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $CIFS = TRUE ] ; then
		echo "vfiler run VFNAME cifs sessions -t -c" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME nfs_hist -t queue" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs sessions" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME vscan" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs stat" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs sessions -z" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs stat -z" >> $PERFCMDS_VFILER
	fi


	if [ $NFS_MONITOR = TRUE ] ; then
		echo "ifstat -z -a   " >> $PERFCMDS
		echo "nfsstat -z " >> $PERFCMDS
		echo "wafl_susp -z" >> $PERFCMDS
		echo "nfs_hist -z" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $FCP = TRUE -o $VFILER = TRUE -a $ISCSI = TRUE ] ; then
		echo "vfiler run VFNAME lun stats -o" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME lun stats -z" >> $PERFCMDS_VFILER
	fi


	if [ $FCP = TRUE -o $ISCSI = TRUE ] ; then
		echo "lun stats -o" >> $PERFCMDS
		echo "lun hist" >> $PERFCMDS
		echo "lun stats -z" >> $PERFCMDS
		echo "lun hist -z" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $NFS = TRUE ] ; then
		echo "vfiler run VFNAME nfsstat -l" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME nfsstat -d" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME nfsstat -z" >> $PERFCMDS_VFILER
	fi


	if [ $ISCSI = TRUE ] ; then
		echo "iscsi stats" >> $PERFCMDS
		echo "iscsi stats -z" >> $PERFCMDS
	fi


	if [ $NETCACHE = TRUE ] ; then
		echo "nfsstat -h" >> $PERFCMDS
		echo "show status.*" >> $PERFCMDS
	fi


	if [ $NFS = TRUE ] ; then
		echo "nfsstat -d" >> $PERFCMDS
		echo "nfs_hist" >> $PERFCMDS
		echo "nfsstat -z " >> $PERFCMDS
		echo "nfs_hist -z" >> $PERFCMDS
	fi


	if [ $CLUSTER = TRUE ] ; then
		echo "cf monitor all" >> $PERFCMDS
		echo "ic stats performance" >> $PERFCMDS
		echo "cf status" >> $PERFCMDS
		echo "ic stats error -v" >> $PERFCMDS
		echo "cf partner" >> $PERFCMDS
	fi


	if [ "$fileros" = ONTAP8.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -BM" >> $PERFCMDS
		fi
	fi


	if [ "$fileros" = ONTAP7.3.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.7 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.4 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP10.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP6.5.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP8.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "netstat -BM" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP8.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "priority show" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "priority show volume -v" >> $PERFCMDS
			echo "priority show default -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "flexcache stats -z" >> $PERFCMDS
			echo "waffinity_stats -z" >> $PERFCMDS
		fi

	if [ $VFILER = TRUE ] ; then
			echo "vfiler run VFNAME qtree status" >> $PERFCMDS_VFILER
		fi


	if [ $CIFS = TRUE ] ; then
			echo "cifs sessions -s" >> $PERFCMDS
		fi


	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
			echo "qtree stats -z" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache hist -z" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
			echo "fcp stats -z" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats -z" >> $PERFCMDS_VFILER
		fi

	fi

	[ $SNAPMIRROR = TRUE -a $BUILD_SAFE_VOL_LIST = TRUE ] && add_vsm_safe_prestats
	if [ $CONF_ONLY = FALSE ] ; then
		do_filer "PERF" < $PERFCMDS
	fi

}

#poststat_filer
poststat_filer(){
	CONFCMDS=$TMPDIR/CONFCMDS
	CONFCMDS_VFILER=$TMPDIR/CONFCMDS_VFILER
	rm -f $CONFCMDS
	touch $CONFCMDS

	rm -f $CONFCMDS_VFILER
	touch $CONFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "df -r" >> $CONFCMDS
		echo "storage show disk -a" >> $CONFCMDS
		echo "df" >> $CONFCMDS
		echo "df -i" >> $CONFCMDS
	fi

	if [ $SNAPMIRROR = TRUE ] ; then
		echo "rdfile /etc/log/snapmirror" >> $CONFCMDS
		echo "snapmirror status -l" >> $CONFCMDS
	fi


	if [ $SNAPVAULT = TRUE ] ; then
		echo "snapvault status " >> $CONFCMDS
	fi


	if [ "$fileros" = ONTAP8.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.3.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$fileros" = ONTAP7.3.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.7 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.4 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.3.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.1.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP10.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.1.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP6.5.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iswt connection show -v iswtb" >> $CONFCMDS
			echo "iswt connection show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswta" >> $CONFCMDS
			echo "iswt session show -v iswtb" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP8.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP8.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.3.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.1.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi


	if [ "$fileros" = ONTAP7.2.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "snap list -n -A" >> $CONFCMDS
			echo "snap status -A" >> $CONFCMDS
			echo "df -A -h" >> $CONFCMDS
			echo "quota status" >> $CONFCMDS
			echo "aggr show_space" >> $CONFCMDS
		fi

	if [ $FCP = TRUE ] ; then
			echo "fcp status" >> $CONFCMDS
		fi


	if [ $ISCSI = TRUE ] ; then
			echo "iscsi session show -v" >> $CONFCMDS
			echo "iscsi connection show -v" >> $CONFCMDS
		fi

	fi

	if [ $PERF_ONLY = FALSE ] ; then
		do_filer "CONFIG" < $CONFCMDS
	fi

	PERFCMDS=$TMPDIR/PERFCMDS
	PERFCMDS_VFILER=$TMPDIR/PERFCMDS_VFILER
	rm -f $PERFCMDS
	touch $PERFCMDS

	rm -f $PERFCMDS_VFILER
	touch $PERFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "raid_config -r" >> $PERFCMDS
		echo "mbstat" >> $PERFCMDS
		echo "backup status" >> $PERFCMDS
		echo "netstat -s" >> $PERFCMDS
		echo "wafl_susp -r" >> $PERFCMDS
		echo "netstat -i" >> $PERFCMDS
		echo "snapmirror status -l" >> $PERFCMDS
		echo "ps -s" >> $PERFCMDS
		echo "httpstat -t" >> $PERFCMDS
		echo "wafl_susp -w" >> $PERFCMDS
		echo "vol scrub status -v" >> $PERFCMDS
		echo "ps" >> $PERFCMDS
		echo "raid_config -x" >> $PERFCMDS
		echo "ifstat -a -v" >> $PERFCMDS
		echo "storage stats tape" >> $PERFCMDS
	fi

	if [ $CIFS = TRUE ] ; then
		echo "vscan" >> $PERFCMDS
		echo "nfs_hist -t queue" >> $PERFCMDS
		echo "cifs sessions -t -c" >> $PERFCMDS
		echo "cifs stat -c" >> $PERFCMDS
		echo "cifs top" >> $PERFCMDS
		echo "smb_hist" >> $PERFCMDS
		echo "cifs sessions" >> $PERFCMDS
	fi


	if [ $LIGHT_RUN != TRUE ] ; then
		echo "mem_stats -e" >> $PERFCMDS
		echo "rdfile /etc/log/backup" >> $PERFCMDS
		echo "rdfile /etc/messages" >> $PERFCMDS
		echo "rdfile /etc/log/ems" >> $PERFCMDS
		echo "mem_stats" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $CIFS = TRUE ] ; then
		echo "vfiler run VFNAME cifs sessions -t -c" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs top" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs stat -c" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME vscan" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME cifs sessions" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME nfs_hist -t queue" >> $PERFCMDS_VFILER
	fi


	if [ $NFS_MONITOR = TRUE ] ; then
		echo "nfsstat -d" >> $PERFCMDS
		echo "wafl_susp -w" >> $PERFCMDS
		echo "ifstat -a -v   " >> $PERFCMDS
		echo "nfs_hist" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $FCP = TRUE -o $VFILER = TRUE -a $ISCSI = TRUE ] ; then
		echo "vfiler run VFNAME lun stats -o" >> $PERFCMDS_VFILER
	fi


	if [ $FCP = TRUE -o $ISCSI = TRUE ] ; then
		echo "lun stats -o" >> $PERFCMDS
		echo "lun hist" >> $PERFCMDS
	fi


	if [ $VFILER = TRUE -a $NFS = TRUE ] ; then
		echo "vfiler run VFNAME nfsstat -l" >> $PERFCMDS_VFILER
		echo "vfiler run VFNAME nfsstat -d" >> $PERFCMDS_VFILER
	fi


	if [ $ISCSI = TRUE ] ; then
		echo "iscsi stats" >> $PERFCMDS
	fi


	if [ $NETCACHE = TRUE ] ; then
		echo "nfsstat -h" >> $PERFCMDS
		echo "nclog -ta -2000 http" >> $PERFCMDS
		echo "show status.*" >> $PERFCMDS
		echo "nclog -v messages" >> $PERFCMDS
	fi


	if [ $NFS = TRUE ] ; then
		echo "nfsstat -d" >> $PERFCMDS
		echo "nfs_hist" >> $PERFCMDS
	fi


	if [ $CLUSTER = TRUE ] ; then
		echo "cf monitor all" >> $PERFCMDS
		echo "ic stats performance" >> $PERFCMDS
		echo "cf status" >> $PERFCMDS
		echo "ic stats error -v" >> $PERFCMDS
		echo "cf partner" >> $PERFCMDS
	fi


	if [ "$fileros" = ONTAP8.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -BM" >> $PERFCMDS
		fi
	fi


	if [ "$fileros" = ONTAP7.3.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "nfsstat -c" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.7 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.4 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "nfsstat -c" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "nfsstat -c" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP10.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "nfsstat -c" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "nfsstat -c" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP6.5.6 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP8.0.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "netstat -BM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP8.0.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "ifinfo -a" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.3.1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "toe status" >> $PERFCMDS
			echo "netstat -anM" >> $PERFCMDS
			echo "stats show hostadapter" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "ndmpd probe" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl scan status -A" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "ndmpd status" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $ISCSI = TRUE -o $FCP = TRUE ] ; then
			echo "lun stats -e" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.1.2 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi


	if [ "$fileros" = ONTAP7.2.3 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "wafl scan status -A" >> $PERFCMDS
			echo "netstat -na" >> $PERFCMDS
			echo "export_stats -p -q -a" >> $PERFCMDS
			echo "wafl scan status" >> $PERFCMDS
			echo "wafl bufstats" >> $PERFCMDS
			echo "wafl cpstats" >> $PERFCMDS
			echo "flexcache stats -S -c" >> $PERFCMDS
			echo "sasadmin dev_stats" >> $PERFCMDS
			echo "waffinity_stats" >> $PERFCMDS
			echo "vol media_scrub status -v" >> $PERFCMDS
			echo "rshstat -t" >> $PERFCMDS
			echo "reallocate status -v" >> $PERFCMDS
		fi

	if [ $SNAPMIRROR != TRUE ] ; then
			echo "qtree stats" >> $PERFCMDS
		fi


	if [ $FLEX_CACHE = TRUE ] ; then
			echo "flexcache hist -C -S" >> $PERFCMDS
			echo "flexcache stats -C" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi


	if [ $A_SIS = TRUE ] ; then
			echo "sis stat -g" >> $PERFCMDS
			echo "sis status -l" >> $PERFCMDS
			echo "sis stat -lv" >> $PERFCMDS
		fi


	if [ $FCP = TRUE ] ; then
			echo "fcp stats" >> $PERFCMDS
		fi


	if [ $VFILER = TRUE -a $SNAPMIRROR != TRUE ] ; then
			echo "vfiler run VFNAME qtree stats " >> $PERFCMDS_VFILER
		fi

	fi

	[ $SNAPMIRROR = TRUE -a $BUILD_SAFE_VOL_LIST = TRUE ] && add_vsm_safe_poststats
	if [ $CONF_ONLY = FALSE ] ; then
		do_filer "PERF" < $PERFCMDS
	fi

}

#prestat_host
prestat_host(){
	CONFCMDS=$TMPDIR/CONFCMDS
	CONFCMDS_VFILER=$TMPDIR/CONFCMDS_VFILER
	rm -f $CONFCMDS
	touch $CONFCMDS

	rm -f $CONFCMDS_VFILER
	touch $CONFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "netstat -s" >> $CONFCMDS
		echo "hostname" >> $CONFCMDS
	fi

	if [ "$machineos" = ESX ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "/sbin/ifconfig -a" >> $CONFCMDS
			echo "cat -s /proc/cpuinfo" >> $CONFCMDS
			echo "/sbin/lspci -v" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun fcp show adapter -v all 2>&1" >> $CONFCMDS
			echo "/usr/sbin/vmkiscsi-ls" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-mpath -a" >> $CONFCMDS
			echo "ls -l /dev/sd*" >> $CONFCMDS
			echo "cat -s /etc/fstab.iscsi" >> $CONFCMDS
			echo "cat -s /etc/sysctl.conf" >> $CONFCMDS
			echo "netstat -rn" >> $CONFCMDS
			echo "cat -s /etc/vmkiscsi.conf" >> $CONFCMDS
			echo "esxupdate --listrpms query" >> $CONFCMDS
			echo "cat -s /proc/vmware/vmkstor" >> $CONFCMDS
			echo "cat -s /etc/iscsid.conf" >> $CONFCMDS
			echo "fdisk -l" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-vswif -l" >> $CONFCMDS
			echo "/usr/sbin/vmkiscsi-util -m" >> $CONFCMDS
			echo "vmware -v" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-vswitch -l" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-mpath -l" >> $CONFCMDS
			echo "/usr/sbin/vmkchdev -L" >> $CONFCMDS
			echo "cat -s /etc/fstab" >> $CONFCMDS
			echo "cat -s /proc/version" >> $CONFCMDS
			echo "cat -s /etc/iscsi.conf" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-vmknic -l" >> $CONFCMDS
			echo "/sbin/sysctl -a" >> $CONFCMDS
			echo "/usr/sbin/vmkiscsi-iname" >> $CONFCMDS
			echo "tail -200 /var/log/messages.1" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-vmhbadevs" >> $CONFCMDS
			echo "/usr/sbin/vmkping -D -v" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-swiscsi -q" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-module -q" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun lun show -v all 2>&1" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-nas -l" >> $CONFCMDS
			echo "netstat -an" >> $CONFCMDS
			echo "tail -200 /var/log/messages" >> $CONFCMDS
			echo "cat -s /proc/mounts" >> $CONFCMDS
			echo "cat -s /proc/meminfo" >> $CONFCMDS
			echo "tail -200 /var/log/vmkernel.1" >> $CONFCMDS
			echo "${SANLUN_PATH}san_version -v" >> $CONFCMDS
			echo "/bin/rpm -qa" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "netstat -vepan" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-mpath -lv" >> $CONFCMDS
			echo "cat -s /var/iscsi/bindings" >> $CONFCMDS
			echo "cat -s /proc/partitions" >> $CONFCMDS
			echo "${SANLUN_PATH}config_mpath --query --verbose 2>&1" >> $CONFCMDS
			echo "cat -s /etc/yp.conf" >> $CONFCMDS
			echo "netstat -nn" >> $CONFCMDS
			echo "tail -200 /var/log/vmkernel" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-firewall -q" >> $CONFCMDS
			echo "${SANLUN_PATH}config_hba --query 2>&1" >> $CONFCMDS
			echo "cat -s /etc/modprobe.conf" >> $CONFCMDS
			echo "cat -s /etc/initiatorname.iscsi" >> $CONFCMDS
			echo "iscsi-ls -c" >> $CONFCMDS
			echo "raw -qa" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-module -l" >> $CONFCMDS
			echo "cat -s /proc/cmdline" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-nics -l" >> $CONFCMDS
			echo "cat -s /proc/scsi/iscsi" >> $CONFCMDS
			echo "/sbin/lsmod" >> $CONFCMDS
			echo "cat -s /etc/modules.conf" >> $CONFCMDS
			echo "iscsi-ls -l" >> $CONFCMDS
			echo "cat -s /etc/ypserv.conf" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun lun show all 2>&1" >> $CONFCMDS
			echo "/usr/sbin/esxcfg-vmhbadevs -m" >> $CONFCMDS
			echo "cat -s /proc/scsi/scsi" >> $CONFCMDS
			echo "/bin/dmesg | tail -200" >> $CONFCMDS
			echo "iscsi-ls" >> $CONFCMDS
			echo "cat -s /proc/devices" >> $CONFCMDS
			echo "cat -s /etc/vmware/firewall/netappEHU.xml" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = OpenBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "/sbin/dmesg | tail -200" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "/sbin/ifconfig -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "uname -r" >> $CONFCMDS
			echo "cat -s /etc/rc.conf" >> $CONFCMDS
			echo "cat -s /etc/fstab" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = OSF1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "mount -l" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = FreeBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "/sbin/dmesg | tail -200" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "/sbin/ifconfig -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "uname -r" >> $CONFCMDS
			echo "cat -s /etc/rc.conf" >> $CONFCMDS
			echo "cat -s /etc/fstab" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "kmtune -l" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "model" >> $CONFCMDS
			echo "swapinfo -mt" >> $CONFCMDS
			echo "cat -s /etc/checklist" >> $CONFCMDS
			echo "nfsstat -m" >> $CONFCMDS
			echo "/usr/bin/model" >> $CONFCMDS
			echo "lanscan -v" >> $CONFCMDS
			echo "bdf" >> $CONFCMDS
			echo "/opt/iscsi/bin/iscsiutil -p -D" >> $CONFCMDS
			echo "cat -s /etc/rc.config.d/hpgelanconf" >> $CONFCMDS
			echo "cat -s /etc/fstab" >> $CONFCMDS
			echo "swlist" >> $CONFCMDS
			echo "ioscan -kf" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "show_patches" >> $CONFCMDS
			echo "lspci -v" >> $CONFCMDS
			echo "/opt/iscsi/bin/iscsiutil -l" >> $CONFCMDS
			echo "netstat -rn" >> $CONFCMDS
			echo "cat -s /etc/rc.config.d/netconf" >> $CONFCMDS
			echo "cat -s /stand/system" >> $CONFCMDS
			echo "cat -s /etc/rc.config.d/nfsconf" >> $CONFCMDS
			echo "hinv -mv" >> $CONFCMDS
			echo "sysdef" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = SunOS ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "isainfo -kv" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "ifconfig -a" >> $CONFCMDS
			echo "cat -s /kernel/drv/lpfc.conf" >> $CONFCMDS
			echo "prtconf" >> $CONFCMDS
			echo "ndd /dev/ce \?" >> $CONFCMDS
			echo "/usr/bin/pkginfo -l lpfc" >> $CONFCMDS
			echo "nfsstat -m" >> $CONFCMDS
			echo "cat -s /etc/system" >> $CONFCMDS
			echo "${SANLUN_PATH}san_version -v" >> $CONFCMDS
			echo "ndd /dev/ge \?" >> $CONFCMDS
			echo "psrinfo -v" >> $CONFCMDS
			echo "cat -s /etc/vfstab" >> $CONFCMDS
			echo "ndd /dev/hme \?" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun fcp show adapter -v all 2>&1" >> $CONFCMDS
			echo "cat -s /kernel/drv/sd.conf" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "showrev -p" >> $CONFCMDS
			echo "ndd /dev/eri \?" >> $CONFCMDS
			echo "netstat -rn" >> $CONFCMDS
			echo "tail -100 /var/adm/messages" >> $CONFCMDS
			echo "isainfo" >> $CONFCMDS
			echo "/usr/platform/sun4u/sbin/prtdiag" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun lun show -v all 2>&1" >> $CONFCMDS
			echo "versions -M" >> $CONFCMDS
			echo "sysdef" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = Linux ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "tail -200 /var/log/messages" >> $CONFCMDS
			echo "cat -s /proc/mounts" >> $CONFCMDS
			echo "/sbin/ifconfig -a" >> $CONFCMDS
			echo "${ISCSI_PATH}iscsi-ls -l" >> $CONFCMDS
			echo "cat -s /proc/meminfo" >> $CONFCMDS
			echo "cat -s /sys/module/iscsi_sfnet/can_queue" >> $CONFCMDS
			echo "${SANLUN_PATH}san_version -v" >> $CONFCMDS
			echo "cat -s /proc/cpuinfo" >> $CONFCMDS
			echo "/bin/rpm -qa" >> $CONFCMDS
			echo "/sbin/lspci -v" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun fcp show adapter -v all 2>&1" >> $CONFCMDS
			echo "cat -s /etc/multipath.conf" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "cat -s /var/iscsi/bindings" >> $CONFCMDS
			echo "cat -s /proc/partitions" >> $CONFCMDS
			echo "cat -s /etc/fstab.iscsi" >> $CONFCMDS
			echo "ls -l /dev/sd*" >> $CONFCMDS
			echo "cat -s /etc/sysctl.conf" >> $CONFCMDS
			echo "netstat -rn" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun iscsi show adapter -v all 2>&1" >> $CONFCMDS
			echo "cat -s /etc/yp.conf" >> $CONFCMDS
			echo "cat -s /var/lib/multipath/bindings" >> $CONFCMDS
			echo "netstat -nn" >> $CONFCMDS
			echo "cat -s /sys/module/iscsi_sfnet/cmds_per_lun" >> $CONFCMDS
			echo "cat -s /etc/initiatorname.iscsi" >> $CONFCMDS
			echo "${ISCSI_PATH}iscsi-ls -c" >> $CONFCMDS
			echo "cat -s /etc/SuSE-release 2> /dev/null" >> $CONFCMDS
			echo "fdisk -l" >> $CONFCMDS
			echo "cat -s /etc/modprobe.conf" >> $CONFCMDS
			echo "${ISCSI_PATH}iscsi-ls " >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "raw -qa" >> $CONFCMDS
			echo "cat -s /proc/cmdline" >> $CONFCMDS
			echo "cat -s /proc/scsi/iscsi" >> $CONFCMDS
			echo "/usr/local/bin/qlremote -v" >> $CONFCMDS
			echo "/sbin/lsmod" >> $CONFCMDS
			echo "cat -s /proc/scsi/qla2300/*HbaApiNode*" >> $CONFCMDS
			echo "cat -s /etc/redhat-release 2> /dev/null" >> $CONFCMDS
			echo "/sbin/dmsetup status --verbose 99" >> $CONFCMDS
			echo "cat -s /etc/modules.conf" >> $CONFCMDS
			echo "/sbin/sysctl vm.max-readahead" >> $CONFCMDS
			echo "cat -s /etc/fstab" >> $CONFCMDS
			echo "cat -s /etc/iscsi.conf" >> $CONFCMDS
			echo "cat -s /proc/version" >> $CONFCMDS
			echo "cat -s /etc/ypserv.conf" >> $CONFCMDS
			echo "/sbin/sysctl -a" >> $CONFCMDS
			echo "tail -200 /var/log/messages.1" >> $CONFCMDS
			echo "cat -s /proc/sys/sunrpc/tcp_slot_table_entries" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun version 2>&1" >> $CONFCMDS
			echo "/bin/dmesg | tail -200" >> $CONFCMDS
			echo "cat -s /proc/scsi/scsi" >> $CONFCMDS
			echo "ls -lR /dev/mpath 2>&1" >> $CONFCMDS
			echo "cat -s /proc/devices" >> $CONFCMDS
			echo "/sbin/dmsetup table --verbose 99" >> $CONFCMDS
			echo "cat -s /sys/module/qla2xxx/ql2xmaxqdepth" >> $CONFCMDS
			echo "${SANLUN_PATH}sanlun lun show -v all 2>&1" >> $CONFCMDS
			echo "/sbin/modprobe -ndv qla2300" >> $CONFCMDS
			echo "/sbin/multipath -v3 -d" >> $CONFCMDS
			echo "netstat -an" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = AIX ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "svmon -G" >> $CONFCMDS
			echo "cat -s /etc/hosts" >> $CONFCMDS
			echo "lsdev -Cc processor" >> $CONFCMDS
			echo "nfso -a" >> $CONFCMDS
			echo "lsattr -E -l inet0" >> $CONFCMDS
			echo "ifconfig -a" >> $CONFCMDS
			echo "cat -s /etc/rc.nfs" >> $CONFCMDS
			echo "oslevel -r" >> $CONFCMDS
			echo "lsdev -l iscsi0" >> $CONFCMDS
			echo "oslevel -g" >> $CONFCMDS
			echo "/usr/bin/lslpp -L" >> $CONFCMDS
			echo "lsdev -C" >> $CONFCMDS
			echo "/usr/sbin/lsps -a" >> $CONFCMDS
			echo "cat -s /etc/iscsi/targets" >> $CONFCMDS
			echo "cat -s /etc/filesystems" >> $CONFCMDS
			echo "/usr/sbin/instfix -a" >> $CONFCMDS
			echo "svmon -P" >> $CONFCMDS
			echo "ioo -a" >> $CONFCMDS
			echo "uname -a" >> $CONFCMDS
			echo "mount" >> $CONFCMDS
			echo "cat -s /etc/netxvc.conf" >> $CONFCMDS
			echo "svmon -i" >> $CONFCMDS
			echo "no -a" >> $CONFCMDS
			echo "vmo -a" >> $CONFCMDS
			echo "netstat -rn" >> $CONFCMDS
			echo "/usr/sbin/lsps -s" >> $CONFCMDS
			echo "lsattr -E -l sys0" >> $CONFCMDS
			echo "bootinfo -r" >> $CONFCMDS
			echo "cat -s /etc/rc.net" >> $CONFCMDS
			echo "svmon -Ssu" >> $CONFCMDS
			echo "lsdev -cdisk" >> $CONFCMDS
		fi

	if [ $NFS = TRUE ] ; then
			echo "nfsstat -m" >> $CONFCMDS
		fi

	fi

	if [ $PERF_ONLY = FALSE ] ; then
		do_client "CONFIG" < $CONFCMDS
	fi

	PERFCMDS=$TMPDIR/PERFCMDS
	PERFCMDS_VFILER=$TMPDIR/PERFCMDS_VFILER
	rm -f $PERFCMDS
	touch $PERFCMDS

	rm -f $PERFCMDS_VFILER
	touch $PERFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "netstat -s" >> $PERFCMDS
	fi

	if [ "$machineos" = ESX ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = OpenBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -i" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = OSF1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "iostat" >> $PERFCMDS
		fi

	if [ $NFS = TRUE ] ; then
			echo "nfsstat -z" >> $PERFCMDS
		fi

	fi


	if [ "$machineos" = FreeBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -i" >> $PERFCMDS
			echo "bsdsar_gather" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "iostat" >> $PERFCMDS
			echo "nfsstat" >> $PERFCMDS
			echo "netstat -i" >> $PERFCMDS
			echo "/opt/iscsi/bin/iscsiutil -s" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = SunOS ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -k" >> $PERFCMDS
			echo "iostat -n -c" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
			echo "iostat -n" >> $PERFCMDS
			echo "mpstat" >> $PERFCMDS
			echo "iostat -n -x" >> $PERFCMDS
			echo "iostat -x -I -n" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = Linux ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "${NFSSTAT_PATH}nfsstat -c" >> $PERFCMDS
			echo "vmstat" >> $PERFCMDS
			echo "netstat -i" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = AIX ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -i" >> $PERFCMDS
			echo "netstat -c" >> $PERFCMDS
			echo "netstat -v" >> $PERFCMDS
		fi
	fi

	if [ $CONF_ONLY = FALSE ] ; then
		do_client "PERF" < $PERFCMDS
	fi

}

#poststat_host
poststat_host(){
	CONFCMDS=$TMPDIR/CONFCMDS
	CONFCMDS_VFILER=$TMPDIR/CONFCMDS_VFILER
	rm -f $CONFCMDS
	touch $CONFCMDS

	rm -f $CONFCMDS_VFILER
	touch $CONFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "netstat -s" >> $CONFCMDS
	fi

	if [ "$machineos" = ESX ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = OpenBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = OSF1 ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = FreeBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "nfsstat -m" >> $CONFCMDS
		fi
	fi


	if [ "$machineos" = SunOS ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = Linux ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = AIX ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi

	if [ $PERF_ONLY = FALSE ] ; then
		do_client "CONFIG" < $CONFCMDS
	fi

	PERFCMDS=$TMPDIR/PERFCMDS
	PERFCMDS_VFILER=$TMPDIR/PERFCMDS_VFILER
	rm -f $PERFCMDS
	touch $PERFCMDS

	rm -f $PERFCMDS_VFILER
	touch $PERFCMDS_VFILER

	if [ -z "$MONITOR" ] ; then
		echo "netstat -s" >> $PERFCMDS
	fi

	if [ "$machineos" = ESX ] ; then
		if [ -z "$MONITOR" ] ; then
			:
		fi
	fi


	if [ "$machineos" = OpenBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -i" >> $PERFCMDS
			echo "vmstat" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = OSF1 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "iostat" >> $PERFCMDS
			echo "nfsstat" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = FreeBSD ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "netstat -i" >> $PERFCMDS
			echo "vmstat" >> $PERFCMDS
			echo "bsdsar_gather" >> $PERFCMDS
			echo "bsdsar -a" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = ONTAP6.5 ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "iostat" >> $PERFCMDS
			echo "nfsstat" >> $PERFCMDS
			echo "netstat -i" >> $PERFCMDS
			echo "/opt/iscsi/bin/iscsiutil -s" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = SunOS ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "mpstat" >> $PERFCMDS
			echo "iostat -x -n" >> $PERFCMDS
			echo "nfsstat -c" >> $PERFCMDS
			echo "iostat -n" >> $PERFCMDS
			echo "iostat -c -n" >> $PERFCMDS
			echo "iostat -x -I -n" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = Linux ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "${NFSSTAT_PATH}nfsstat -c" >> $PERFCMDS
			echo "vmstat" >> $PERFCMDS
			echo "netstat -i" >> $PERFCMDS
		fi
	fi


	if [ "$machineos" = AIX ] ; then
		if [ -z "$MONITOR" ] ; then
			echo "iostat" >> $PERFCMDS
			echo "vmstat" >> $PERFCMDS
			echo "netstat -v" >> $PERFCMDS
			echo "netstat -i" >> $PERFCMDS
			echo "netstat -c" >> $PERFCMDS
		fi
	fi

	if [ $CONF_ONLY = FALSE ] ; then
		do_client "PERF" < $PERFCMDS
	fi

}

#do_stats_lists
do_stats_lists(){
	ONTAP_BLACKLIST="qtree nrv"
	ONTAP_WHITELIST=""
	ONTAP80_BLACKLIST=""
	ONTAP80_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP80_BLACKLIST="$ONTAP80_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP705_BLACKLIST=" qtree"
	ONTAP705_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP705_BLACKLIST="$ONTAP705_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP733_BLACKLIST=""
	ONTAP733_WHITELIST=""
	ONTAP735_BLACKLIST=""
	ONTAP735_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP735_BLACKLIST="$ONTAP735_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP706_BLACKLIST=""
	ONTAP706_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP706_BLACKLIST="$ONTAP706_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP701_BLACKLIST=" flexcache nrv qtree"
	ONTAP701_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST fcp"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP701_BLACKLIST="$ONTAP701_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP707_BLACKLIST=""
	ONTAP707_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP707_BLACKLIST="$ONTAP707_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP704_BLACKLIST=" flexcache qtree"
	ONTAP704_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST fcp"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP704_BLACKLIST="$ONTAP704_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP72_BLACKLIST=" qtree"
	ONTAP72_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP72_BLACKLIST="$ONTAP72_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP732_BLACKLIST=""
	ONTAP732_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP732_BLACKLIST="$ONTAP732_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP703_BLACKLIST=" flexcache qtree"
	ONTAP703_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST fcp"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP703_BLACKLIST="$ONTAP703_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP721_BLACKLIST=" qtree"
	ONTAP721_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP721_BLACKLIST="$ONTAP721_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP713_BLACKLIST=""
	ONTAP713_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP713_BLACKLIST="$ONTAP713_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP100_BLACKLIST=""
	ONTAP100_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP100_BLACKLIST="$ONTAP100_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP70_BLACKLIST=" flexcache nrv qtree"
	ONTAP70_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST fcp"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP70_BLACKLIST="$ONTAP70_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP65_BLACKLIST=" cifs_session flexcache lun nrv qtree"
	ONTAP65_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP65_BLACKLIST="$ONTAP65_BLACKLIST cifs cifs_ops cifs_stats cifsdomain"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP65_BLACKLIST="$ONTAP65_BLACKLIST nfsv3 nfsv4"
	fi

	ONTAP702_BLACKLIST=" flexcache nrv qtree"
	ONTAP702_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST fcp"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP702_BLACKLIST="$ONTAP702_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP711_BLACKLIST=" qtree"
	ONTAP711_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP711_BLACKLIST="$ONTAP711_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP656_BLACKLIST=" cifs_session flexcache lun nrv qtree"
	ONTAP656_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP656_BLACKLIST="$ONTAP656_BLACKLIST cifs cifs_ops cifs_stats cifsdomain"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP656_BLACKLIST="$ONTAP656_BLACKLIST nfsv3 nfsv4"
	fi

	ONTAP801_BLACKLIST=""
	ONTAP801_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP801_BLACKLIST="$ONTAP801_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP71_BLACKLIST=" nrv qtree"
	ONTAP71_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP71_BLACKLIST="$ONTAP71_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP802_BLACKLIST=""
	ONTAP802_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP802_BLACKLIST="$ONTAP802_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP73_BLACKLIST=""
	ONTAP73_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP73_BLACKLIST="$ONTAP73_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP722_BLACKLIST=""
	ONTAP722_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP722_BLACKLIST="$ONTAP722_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP731_BLACKLIST=""
	ONTAP731_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP731_BLACKLIST="$ONTAP731_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP712_BLACKLIST=""
	ONTAP712_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP712_BLACKLIST="$ONTAP712_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

	ONTAP723_BLACKLIST=""
	ONTAP723_WHITELIST=""

	if [ $CIFS != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST cifs cifs_ops cifs_session cifs_stats cifsdomain"
	fi


	if [ $FCP != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST fcp"
	fi


	if [ $FLEX_CACHE != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST flexcache"
	fi


	if [ $ISCSI != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST iscsi"
	fi


	if [ $ISCSI != TRUE -a $FCP != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST lun target"
	fi


	if [ $NFS != TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST nfsv3 nfsv4"
	fi


	if [ $LIGHT_RUN = TRUE ] ; then
		ONTAP723_BLACKLIST="$ONTAP723_BLACKLIST disk ifnet nfsv3 nvram wafl"
	fi

}

################################## #END CORE FUNCTIONS

#============================================================
# These are the two main routines called from the main function
#
# define subroutines:
#  do_pre_iterations()
#  do_prestats()
#  do_poststats()
#
# do_prestats and do_poststats call the above functions
# note, this is where we deal with multiple filers
#============================================================

#
#  Commands here are executed one-time, before the loop of PRE and POST stat commands
#
do_pre_iterations()
{
    # Mini disclaimer to avoid confusion by the stats stop output...  
    echo "** NOTE **
    \"stats stop -I perfstat_* \" commands on $CUR_FILER were not actually executed. 
    These commands appear in the output of perfstat$VERSION in order to support 
    backward compatibility with existing parsing tools that depend the output to 
    remain in a specific format. Stats was either called from a preset file or single 
    \"stats start\" invocation string.
** END NOTE**">> $TMPDIR/error.log

    for CUR_FILER in $FILERS ; do
        set_filer_context
        # Set up lists for stats data collection
        if [ $LEGACY_STATS = TRUE ] ; then 
            do_log "$FILER_RSH \"priv set -q diag ; stats list objects\" > $TMPDIR/$CUR_FILER/all_stats.list" "config_filer"
            check_stats_lists
        fi
        
        if [ $PRETEND = TRUE ] ; then
            echo 
            echo "=-=-=-=-=-=-= Runnable Stats Objects for: $CUR_FILER =-=-=-=-=-=-="
            cat $RUN_STATS
            echo
            echo "=-=-=-=-=-=-= Blacklisted Stats Objects for: $CUR_FILER =-=-=-=-=-=-="
            for obj in `eval "echo \$"${STATS_BLACKLIST}""` ; do
                echo $obj
            done
            echo
            print_label "PRE-ITERATION COMMANDS"
            cat $TMPDIR/pretend.config
        fi
        # We only want to try writing the preset file if we're in legacy mode for a particular filer and we're not in CONF only mode
        [ $CONF_ONLY = FALSE -a $LEGACY_STATS = TRUE ] && write_stats_preset
        [ $CONF_ONLY = FALSE -a $LIGHT_RUN = FALSE ] && do_log "$FILER_RSH \"priv set -q diag ; mem_stats -b\" > /dev/null" "filer"
    done
    # Host-side pre itr stuff
    for CUR_HOST in $HOSTS ; do
        check_os
        if [ "$machineos" = ESX ] ; then
            get_vm_support $CUR_HOST
        fi
    done
    # Reset cur host
    CUR_HOST=$PERFHOST
}
#
do_prestats()
{
    STATS_TAGLIST=""
    debug "Begin do_prestats"

    if [ $DO_FILER = TRUE ] ; then
        for CUR_FILER in $FILERS ; do
            debug "Prestat on $CUR_FILER"
            build_filer_rshcmd
            set_priv_command
            check_license
            echo; print_label "BEGIN" "$CUR_FILER"
            console "Prestats on $CUR_FILER; OS: $fileros"
            toggle_timestamping "on"
            # prestat_filer and prestat_filer_background haven't been updated
            # to support C-mode data collection
            if [ $CMODE = FALSE -a $GXMODE = FALSE ] ; then
                prestat_filer
                prestat_filer_background
            fi
            
            # Just before we leave, start our stats call
            do_stats "START"
            toggle_timestamping "off"
            print_label "END" "$CUR_FILER"
            [ -f $TMPDIR/$CUR_FILER/vfiler.list ] && do_vfiler < $TMPDIR/$CUR_FILER/vfiler.list
        done 
    fi 

    if [ $DO_HOST = TRUE ] ; then
        for CUR_HOST in $HOSTS ; do
            debug "Prestat on $CUR_HOST"
            check_os
            set_host_specific_paths
            echo; print_label "BEGIN" "$CUR_HOST"
            console "Prestats on $CUR_HOST; OS: $machineos"
            toggle_timestamping "on"
            prestat_host
            prestat_host_app
            prestat_host_background
            toggle_timestamping "off"
            print_label "END" "$CUR_HOST"
        done # foreach HOST
        debug "End prestat_specificOS"
    fi 

    debug "End do_prestats"

} # end do_prestats
#
do_poststats()
{
    debug "Begin do_poststats"
    #echo "Begin poststats" >> $TMPDIR/error.log
    
    # This stuff only pertains to 7mode data collection
    if [ $CMODE = FALSE -a $GXMODE = FALSE ] ; then
        #terminate background commands
        if [ $PRETEND = FALSE -a -f $TMPDIR/bg_pidlist ] ; then 
            console "Killing background processes..."
            echo "`datestamp` Killing background processes..." >> $TMPDIR/error.log 
            kill_procs < $TMPDIR/bg_pidlist >> $TMPDIR/error.log 2>&1
            # remove the pidlist file
            rm $TMPDIR/bg_pidlist > /dev/null 2>& 1
        fi

        if [ $END_ONLY = TRUE ] ; then
            if [ -f $TMPDIR/stats_id_list ] ; then
                stats_id_list=`cat $TMPDIR/stats_id_list`
                console "Stats IDS: $stats_id_list"
            else
                console "Didn't find stats_id_list!"
            fi
        fi
    fi
    
    if [ $DO_FILER = TRUE ] ; then
        for CUR_FILER in $FILERS ; do
            build_filer_rshcmd
            set_priv_command
            check_license
            echo; print_label "BEGIN" "$CUR_FILER"
            console "Poststats on $CUR_FILER; OS: $fileros"
            toggle_timestamping "on"
            # Just before we start stop our stats call
            do_stats "STOP"

            # poststat_filer and poststat_filer_background haven't yet been
            # updated to support C-mode data collection
            if [ $CMODE = FALSE -a $GXMODE = FALSE ] ; then
                poststat_filer
                poststat_filer_background
            fi
            collect_filer_tmp_data
            toggle_timestamping "off"
            print_label "END" "$CUR_FILER"
            [ -f $TMPDIR/$CUR_FILER/vfiler.list ] && do_vfiler < $TMPDIR/$CUR_FILER/vfiler.list
        done # foreach filer
    fi 

    if [ $DO_HOST = TRUE ] ; then
        for CUR_HOST in $HOSTS ; do
            check_os
            set_host_specific_paths
            echo; print_label "BEGIN" "$CUR_HOST"
            console "Poststats on $CUR_HOST; OS: $machineos"
            toggle_timestamping "on"
            poststat_host
            poststat_host_app
            poststat_host_background
            toggle_timestamping "off"
            print_label "END" "$CUR_HOST"
        done
    fi 

    debug "End do_poststats"
} # end do_poststats

#
#  Commands here are executed one-time, after the loop of PRE and POST stat commands
#
do_post_iterations()
{
    #display error log on last iteration of last run
    LABEL=POSTSTATS
    if [ $BEGIN_ONLY = FALSE ] ; then
        print_command_report
        append_error_log
        #compress profile data
        if [ $PROFILES = TRUE ] ; then
            for file in `ls *_gmon.tar*` ; do
                gzip $file
            done
        fi
        rm -rf $TMPDIR
    fi
}

# iteration prolog
begin_iteration()
{
    LABEL=""
    stats_id_list="$STATS_ID"
    # Newline before each the start of each itr
    echo
    if [ $ITERATIONS -gt 1 ] ; then
        console "Begin Iteration $CUR_ITERATION"
        print_label "BEGIN Iteration $CUR_ITERATION" "`datestamp`"
        perfstat_epoch
        
        #display config info every ITERATION/10 iterations
        [ $CUR_ITERATION -gt 1 ] && PERF_ONLY=TRUE
        CONF_FREQUENCY=`expr $CONF_FREQUENCY - 1`
        if [ $CUR_ITERATION -eq $ITERATIONS -o $CONF_FREQUENCY -lt 0 ] ; then
            PERF_ONLY=$ORIG_PERF_ONLY
            CONF_FREQUENCY=`expr $ITERATIONS / 10` #reset loop counter
        fi
    fi
}

#iteration epilogue
end_iteration()
{
    LABEL=""
    if [ $ITERATIONS -gt 1 ] ; then
        console "End Iteration $CUR_ITERATION"
        print_label "END Iteration $CUR_ITERATION" "`datestamp`"
        perfstat_epoch
    fi

    #if not last iteration, sleep
    if [ $CUR_ITERATION -lt $ITERATIONS -a $ABORTED = FALSE ] ; then
        sleep_time=`expr $ITER_INTERVAL \* 60`

        #give some time for background proccesses to finish
        [ $sleep_time -lt 10 ] && sleep_time=10
        console "Sleeping $sleep_time seconds"
        sleep $sleep_time
    fi
}

# kill background commands
# list comes from stdin
# added logic to make sure the main perfstat process still owns the child pid 
# before killing it
# NOTE: stdout is already redirected to TMPDIR/error.log
kill_procs()
{
    while read pid ; do
        process_info=""
        parent_pid=""
        process_name=""    

        # Some versions of HP-UX don't like the -o option for ps, so we need
        # to extract the PPID and process name via other means
        if [ "$machineos" = HP-UX ] ; then
            process_info=`ps -p ${pid} -f`
            parent_pid=`echo $process_info |  awk '{print $3}' | sed '1d'`
            process_name=`echo $process_info | awk '{print $8}' | sed '1d'`
        else
            process_info=`ps -p ${pid} -o ppid= -o comm=`
            parent_pid=`echo $process_info | awk '{print $1}'`
            process_name=`echo $process_info | awk '{print $2}'`
        fi
        
        
        if [ "${parent_pid}" = "${PERFSTAT_PID}" ] ; then
            (echo "`datestamp` Killing process: ${process_name} pid: ${pid} ppid: ${parent_pid}")
            (kill -9 $pid)
        elif [ -z "$process_info" ] ; then
            (echo "`datestamp` Not killing process with pid: ${pid} because it successfully terminated")
        else
            (echo "`datestamp` Not killing process: ${process_name} pid: ${pid} because ppid: ${parent_pid} no longer matches perfstat_pid :${PERFSTAT_PID}")
        fi
    done
}

# 2nd trap of ctrl-c
sigint_urgent()
{
  echo "Perfstat caught 2nd signal; exitting now!" >> $TMPDIR/error.log
  exit 1
}
# 1st trap of ctrl-c
sigint()
{
    ABORTED=TRUE
    console "Caught signal... attempting clean exit (ctrl-c again will exit immediately)"
    echo "Perfstat caught signal...attempting clean exit (ctrl-c again will exit immediately)" >> $TMPDIR/error.log
    
    trap sigint_urgent 2
    trap sigint_urgent 30
    trap sigint_urgent 31

    if [ $PRETEND = TRUE -o $CONF_ONLY = TRUE ] ; then
        print_command_report
        append_error_log
        rm -rf $TMPDIR
        console "Done!"
        exit 1
    fi
    LABEL=POSTSTATS
    console "Killing background processes..."

    echo "`datestamp` Killing background processes..." >> $TMPDIR/error.log
    [ -f $TMPDIR/bg_pidlist ] && kill_procs < $TMPDIR/bg_pidlist >> $TMPDIR/error.log 2>&1

    if [ $SLEEPING = TRUE ] ; then
        console "Woke between prestats and poststats- attempting poststats"
        do_poststats
        do_date
        end_iteration
    fi

    console "Dumping error log..."
    # The extra label is needed here so the error log gets appended to the correct section
    LABEL=POSTSTATS
    print_command_report
    append_error_log
    [ $BEGIN_ONLY = FALSE ] && rm -rf $TMPDIR

    #compress profile data
    if [ $PROFILES = TRUE ] ; then
        for file in `ls *_gmon.tar*` ; do
            gzip $file
        done
    fi

    console "Done!"
    exit 1
}
#
# Function to help track long-running (slow) commands
# PARAMS are:
#   $1 = cmd to log
#   $2 = host cmd was to be executed on
#   $3 = iteration the slow command was reported on
#   $4 = total execution time for the command
#
log_command()
{
    cmd=`echo $1 | sed 's/"//g' | sed 's/[ ]$//g'`
    host=$2
    itr=$3
    exe_time=$4
    
    if [ $slow_cmd_entries -eq $MAX_CMD_LOG ] ; then
        # Log message to error log
        echo "WARNING: Internal command log full of commands that took > $CMD_EXE_THRESHOLD seconds to execute!" >> $TMPDIR/error.log
        debug "WARNING: Internal command log full of commands that took > $CMD_EXE_THRESHOLD seconds to execute!"
        debug "Please check error log for more details"
        return
    else
        if [ -z "$SLOW_CMDS" ] ; then
            SLOW_CMDS="${host}:${itr}:${exe_time}:${cmd}"
        else
            SLOW_CMDS="${SLOW_CMDS}~${host}:${itr}:${exe_time}:${cmd}"
        fi
        slow_cmd_entries=`expr $slow_cmd_entries + 1`
    fi
}
#
#   Generates a report of all the long-running commands that is appended to the error log
#
print_command_report()
{
    echo "=== Report of Commands that took longer than $CMD_EXE_THRESHOLD seconds to execute ===" >> $TMPDIR/error.log
    echo "Host Iteration Total_Time Command" | awk '{ printf "%s\t\t%s\t\t%s\t\t%s\n", $1, $2, $3, $4}' >> $TMPDIR/error.log
    old_ifs=$IFS
    IFS="~"
    for entry in $SLOW_CMDS ; do
        echo $entry | awk '{ FS=":"; printf "%s\t\t%d\t\t%ds\t\t%s\n",$1,$2,$3,$4; }' >> $TMPDIR/error.log
    done
    IFS=$old_ifs
    echo "=== End Command Report ===" >> $TMPDIR/error.log
}
#
# Small helper to parse the values passed into the -T (sktrace) option. If no valid trace points are specified,
# then we will use the default of 'SK 7 WAFL 4'.
# PARAM: argument list to -T parameter
#
get_sktrace_params()
{
    TRACE_ARGS=$1
    old_ifs=$IFS
    IFS=","
    
    for trace_spec in $TRACE_ARGS ; do
        if [ -n "`echo $trace_spec | sed 's/[0-9]//g'`" ] ; then
            # spec is a trace module
            SKTRACE_POINTS="$SKTRACE_POINTS $trace_spec"
            
            # If this is the 'DISK' trace point, then we need to collect sysconfig -r in order to 
            # get the disk mappings
            if [ $trace_spec = DISK ] ; then
                console "Toggling disk mapping data collection"
                GET_DISK_MAPPINGS=TRUE
            fi
        else
            # Append the trace level
            SKTRACE_POINTS="$SKTRACE_POINTS $trace_spec"
        fi
    done
    IFS=$old_ifs

    # No trace points were specified, use defaults
    if [ -z "$SKTRACE_POINTS" ] ; then
        console "Using default trace points: $DEFAULT_TRACE_POINTS"
        SKTRACE_POINTS="$DEFAULT_TRACE_POINTS"
    else
        console "Using trace points: $SKTRACE_POINTS"
    fi
}
#============================================================
#
# MAIN
#
#============================================================

#flag defaults
D_APP_NAME=""
D_BEGIN_ONLY=FALSE
D_CONF_ONLY=FALSE
D_DEBUG=FALSE
D_END=FALSE
D_FILER_TARGETS=""
D_DO_HOST=TRUE
D_HOST_TARGETS=""
D_ITERATIONS=1
D_ITER_INTERVAL=0
D_FILER_LOGIN="root"
D_SSH=FALSE
D_RAMRUN=FALSE
D_APP_PARAM=""
D_PERF_ONLY=FALSE
D_QUIET=FALSE
D_ROOT_CMD=""
D_TIME=2
D_PRETEND=FALSE
D_LOGS=FALSE
D_PROFILES=FALSE
D_EXCLUDE=FALSE
D_STUTTER_STATIT=TRUE
D_FULL_STUTTER_STATIT=FALSE
D_MULTI_RSH=FALSE
D_MONITOR=""
D_LIGHT_RUN=FALSE
D_LOG_TIMESTAMPS=FALSE
D_FORCE_ITERATIONS=FALSE
D_STATSPACK_INSTALLED=TRUE
D_NEED_STOPOBJ=TRUE
D_DO_VFILER=TRUE
D_BUILD_SAFE_VOL_LIST=TRUE
D_SKTRACE=FALSE
D_LEGACY_STATS=TRUE
D_CMODE=FALSE
D_GXMODE=FALSE
D_DOMAIN_STATS=TRUE

#set flags to defaults
APP_NAME=$D_APP_NAME
BEGIN_ONLY=$D_BEGIN_ONLY
DEBUG=$D_DEBUG
END_ONLY=$D_END
FILER_TARGETS=$D_FILER_TARGETS
HOST_TARGETS=$D_HOST_TARGETS
ITERATIONS=$D_ITERATIONS
ITER_INTERVAL=$D_ITER_INTERVAL
FILER_LOGIN=$D_FILER_LOGIN
SSH=$D_SSH
RAMRUN=$D_RAMRUN
APP_PARAM=$D_APP_PARAM
PERF_ONLY=$D_PERF_ONLY
CONF_ONLY=$D_CONF_ONLY
QUIET=$D_QUIET
ROOT_CMD=$D_ROOT_CMD
TIME=$D_TIME
PRETEND=$D_PRETEND
LOGS=$D_LOGS
PROFILES=$D_PROFILES
EXCLUDE=$D_EXCLUDE
DO_HOST=$D_DO_HOST
STUTTER_STATIT=$D_STUTTER_STATIT
FULL_STUTTER_STATIT=$D_FULL_STUTTER_STATIT
MULTI_RSH=$D_MULTI_RSH
MONITOR=$D_MONITOR
LIGHT_RUN=$D_LIGHT_RUN
LOG_TIMESTAMPS=$D_LOG_TIMESTAMPS
FORCE_ITERATIONS=$D_FORCE_ITERATIONS
STATSPACK_INSTALLED=$D_STATSPACK_INSTALLED
NEED_STOPOBJ=$D_NEED_STOPOBJ #By-product from burt200533 and burt214298
DO_VFILER=$D_DO_VFILER
BUILD_SAFE_VOL_LIST=$D_BUILD_SAFE_VOL_LIST
SKTRACE=$D_SKTRACE
LEGACY_STATS=$D_LEGACY_STATS
CMODE=$D_CMODE
GXMODE=$D_GXMODE
DOMAIN_STATS=$D_DOMAIN_STATS

## Other Global Variables ##
PERFSTAT_PID=$$
# Sktrace related variables
GET_DISK_MAPPINGS=FALSE
SKTRACE_POINTS=""
DEFAULT_TRACE_POINTS="SK 7 WAFL 4"
SKTRACE_BUF_SIZE="40m"
TMPDIR=""
ONESHOT=TRUE  # do both -b and -e with sleep inbetween
# Stats ID is: perfstat_<PID>
STATS_ID="perfstat$$"
DO_FILER=FALSE
RSHCMD=rsh   # default works for all but HP-UX and Support Console
SEND_ARGS="" # Holds a list of optional arguments to pass  to rsh / ssh invocation string
# Modified default ssh parameters due to a "openssh.invalid.channel.req" error in ONTAP 7.2
SSHCMD="ssh -o BatchMode=yes -2 -ax "
MULTI_HOST=FALSE
ABORTED=FALSE
CUR_VFILER=""
PRESET_NAME="perfstat_preset" # Name given to the stats presets file used by perfstat
#rsh time out
TIMEOUT=20
#number of rsh calls issued simultaneously
BATCH_SIZE=12
histogram=TRUE
histo_time=2
# Vars for logging slow commands
SLOW_CMDS=""
# max number of commands to be logged
MAX_CMD_LOG=1024
# If any command executed exceeds this threshold (in seconds), it will be logged and reported at the end of the error log
CMD_EXE_THRESHOLD=60
# current number of slow command entries
slow_cmd_entries=0
# Used to test version mapping
TEST_VERSION=""

# setup the delay time in seconds for RAM (support console)
# use histo_time + 2 minutes to process everything
RAM_delay_time_secs=240
APP_ON=FALSE
ORACLE_ON=FALSE
VERITAS_ON=FALSE
RHEL5=FALSE
MII_TOOL=TRUE
FORCE_OS=""
SLEEPING=FALSE
# If a new license is introduced, it must be added to the following var
LICENSES="MULTI_CPU_FILER NFS DAFS FCP ISCSI CIFS CLUSTER SNAPMIRROR SNAPVAULT NETCACHE VFILER FLEX_CACHE A_SIS"
# This is the order in which the timestamp functions will be checked
TIMESTAMP_FUNCTIONS="gawk_timestamp date_timestamp dc_timestamp perl_timestamp"
# The default timestamp function
TIMESTAMP_FUN="none"
#Burt384517: Maximum RunTime for the perfstat RUN, 300 sec.
MAX_RUN_TIME=300

for LICENSE in $LICENSES ; do
    eval "$LICENSE"=TRUE
    eval "$LICENSE"_MONITOR=FALSE
done

#trap sigint for cleanup
trap sigint 2
#trap sigusr1 || sigusr2 for cleanup if perfstat was executed from within a wrapper script
#Non-interactive shells default behavior is to ignore SIGINT...(i.e., kill -2)
trap sigint 30
trap sigint 31

# Check to see if user requested the help menu
if [ $1 = help ] ; then
    usage
fi

# parse and output the options
while getopts qza:bM:mel:pcH:Ss::ILxkKi:nE:dO:o:P:FT:B:f:r:vVh:t:w:N::-: name
do              
    case $name in
        -)  # This internal case statements acts like "long opts"
            case $OPTARG in
                help)
                    usage
                ;;
                cluster)
                    console "Toggling cluster mode data collection over ssh"
                    CMODE=TRUE
                    SSH=TRUE
                    FORCE_OS=ONTAP8.0
                ;;
                gx)
                    console "Toggling GX cluster data collection over ssh"
                    GXMODE=TRUE
                    SSH=TRUE
                    FORCE_OS=ONTAP10.0
                ;;
                *)
                    console "ERROR: Uknown option: --${OPTARG}"
                    exit 1
                ;;
            esac
        ;;
        v)
            echo "Perfstat v$VERSION ($DATE)"
            exit 0 
        ;;
        V)  
            DO_VFILER=FALSE
        ;;
        f)
            FILER_TARGETS="$OPTARG"
            # assume we have either -f fname or -f fname1,fname2,fname3
            DO_FILER=TRUE
            FILERS=`echo $FILER_TARGETS | sed "s/,/ /g"`
        ;;
        b)
            BEGIN_ONLY=TRUE
            ONESHOT=FALSE
        ;;
        e)
            END_ONLY=TRUE
            ONESHOT=FALSE
        ;;
        r)  
            ROOT_CMD="$OPTARG"
        ;;
        t)  
            histo_time="$OPTARG"
            TIME=$histo_time
        ;;
        i)   
            # check for format n[,m]
            if echo $OPTARG | egrep -e '^[0-9]+,[0-9]+$' > /dev/null ; then
                ITERATIONS=`echo $OPTARG | sed "s/,.*//g"` 
                ITER_INTERVAL=`echo $OPTARG | sed "s/.*,//g"`
            elif echo $OPTARG | egrep -e '^[0-9]+$' > /dev/null ; then
                ITERATIONS=$OPTARG
            else
                echo "Error: -i $OPTARG"
                exit 1
            fi
        ;;
        I)  
            FORCE_ITERATIONS=TRUE
        ;;
        F)  
            DO_HOST=FALSE ; console "Filer only mode"
        ;;
        q)  
            QUIET=TRUE # Quiet Mode
        ;;
        p)  
            PERF_ONLY=TRUE # Performance stats only mode
        ;;
        c)  
            CONF_ONLY=TRUE # Configuration data only mode
        ;;
        d)  
            DEBUG=TRUE # Debug mode
        ;; 
        z)  
            LIGHT_RUN=TRUE 
            PERF_ONLY=TRUE
            console "Perfstat-light mode requested"
        ;;
        l)  
            FILER_LOGIN="$OPTARG"
            if echo $FILER_LOGIN | grep ':' > /dev/null ; then
                PASSWORD=`echo $FILER_LOGIN | sed 's/.*://'`
            fi
        ;;
        L)  
            LOGS=TRUE
        ;;
        h)  
            HOST_TARGETS="$OPTARG"
            # assume we have either -h hname or -h hname1,hname2,hname3
            MULTI_HOST=TRUE
            #note that we need to break this list up into separate lines
            HOSTS=`echo $HOST_TARGETS | sed "s/,/ /g"`
        ;;
        n)  
            RAMRUN=TRUE
        ;;
        a)  
            APP_ON=TRUE
            APP_NAME="$OPTARG"
        ;;
        o)  
            APP_PARAM="$OPTARG"
        ;;
        O)  
            #hidden flag
            FORCE_OS="$OPTARG"
        ;;
        P)  
            PROFILES=TRUE
            PROFILE_DOMAINS="$OPTARG"
            DOMAINS=`echo $PROFILE_DOMAINS | sed "s/,/ /g"`
        ;;
        E)  
            EXCLUDE=TRUE
            EXCLUDED="$OPTARG"
        ;;
        x)  
            PRETEND=TRUE
            QUIET=TRUE
            FILER_CMD_COUNT=0
            RSH_COUNT=0
            CMD_COUNT=0
            RSH_PER_ITR=0
        ;;
        k)
            STUTTER_STATIT=FALSE
        ;;
        K)
            FULL_STUTTER_STATIT=TRUE
        ;;
        H)  
            histo_interval="$OPTARG"
            histo_interval_set=true
            STUTTER_STATIT=FALSE
        ;;
        S)
            SSH=TRUE
        ;;
        s)
            # Optional arguments to supply to SSH / RSH invocations
            old_ifs=$IFS
            IFS=":"
            for ssh_args in $OPTARG ; do
                name="`echo $ssh_args | cut -d\",\" -f1`"
                SEND_ARGS="$SEND_ARGS -$name"
                # Check to see if a value was supplied
                if [ -n "`echo $ssh_args | grep \",\"`" ] ; then
                    val="`echo $ssh_args | cut -d\",\" -f2`"
                    SEND_ARGS="$SEND_ARGS $val"
                fi
            done
            IFS=$old_ifs
        ;;
        m) 
            MULTI_RSH=TRUE
        ;;
        M)  
            MONITOR="$OPTARG"
        ;;
        T)
            SKTRACE=TRUE
            if [ -n "`echo $OPTARG | grep \-`" ] ; then
                console "WARNING: Invalid arg to -T: $OPTARG"
                # Reset the option index 
                OPTIND=`expr $OPTIND - 1`
            else
                get_sktrace_params "$OPTARG"
            fi
        ;;
        B)
            SKTRACE_BUF_SIZE=$OPTARG
        ;;
        w)
            MAX_RUN_TIME=`expr $OPTARG \* 60`
        ;;
        N)
            TEST_VERSION=$OPTARG
            console "using test version string $TEST_VERSION"
        ;;
        \?) 
            console "Please review the help menu using: 'perfstat.sh help'"
            exit 1
         ;;
    esac
done

# Begin execution banner
console "Perfstat v$VERSION ($DATE)"

# burt 361081 - make sure getopts parses all options successfully
if [ `expr $OPTIND - 1` != $# ] ; then
    console "Invalid perfstat invocation: '$0 $*' Please consult $0 -help."
fi

ORIG_PERF_ONLY=$PERF_ONLY

# Sanity check options
if [ $BEGIN_ONLY = TRUE -a $END_ONLY = TRUE ] ; then
    console "Error: -b and -e are mutually exclusive options"
    exit 1
fi
# Issue a warning here because stopping sktrace no becomes the responsiblity of the user
if [ $BEGIN_ONLY = TRUE -a $SKTRACE = TRUE ] ; then
    console "WARNING: Because -b was used with -T, sktrace will have to stopped manually by invoking perfstat with -e option and the same values to -T"
fi
if [ $FULL_STUTTER_STATIT = TRUE -a $STUTTER_STATIT = FALSE ] ; then
    console "Error: -k and -K are mutually exclusive options"
    exit 1
fi
if [ $PERF_ONLY = TRUE -a $CONF_ONLY = TRUE ] ; then
    console "Error: -p and -c are mutually exclusive options"
    exit 1
fi
if [ $LIGHT_RUN = TRUE -a $CONF_ONLY = TRUE ] ; then
    console "Error: -z and -c are mutually exclusive options"
    exit 1
fi

if [ $GXMODE = TRUE -a "${FILER_TARGETS}" = "${D_FILER_TARGETS}" ] ; then
    console "Error: --gx requires at least one filer target"
    exit 1
fi

if [ $CMODE = TRUE -a "${FILER_TARGETS}" = "${D_FILER_TARGETS}" ] ; then
    console "Error: --cluster requires at least one filer target"
    exit 1
fi

#verify that monitor option is legal. currently only NFS is legal
if [ -n "$MONITOR" ] ; then
    [ $MONITOR = nfs ] && MONITOR=NFS
    if [ $MONITOR != NFS ] ; then
        console "Error: Invalid argument to -M: $MONITOR"
        exit 1
    fi
fi

# Verify the OS platform
os=`uname -s`
case $os in 
    SunOS) ;;
    OSF1) ;;
    HP-UX) ;;
    Linux) ;;
    AIX) ;;
    FreeBSD) ;;
    OpenBSD) ;;
    Interix)
      console "Windows SUA detected."
    ;;
    *)
        echo "Error: Unsupported client OS: $os"
        exit 1
    ;;
esac

# Create temp directory
create_tmp_dir
# Helper to test version mapping mechanisms
if [ -n "$TEST_VERSION" ] ; then
    version_tester
    exit 0
fi

# HP-UX uses nonstandard rsh
[ $os = HP-UX ] && RSHCMD=remsh
# Setup our vars for SSH connectivity and perform some rudimentary checks
if [ $SSH = TRUE ] ; then 
    RSHCMD=$SSHCMD
    if echo $FILER_LOGIN | grep ':' > /dev/null ; then
        debug "WARNING: password authentication not supported over SSH!"
        echo "WARNING: password authentication not supported over SSH!" >> $TMPDIR/error.log
        # Strip password from FILER_LOGIN string since password authentication is not supported
        FILER_LOGIN=`echo $FILER_LOGIN | sed 's/:.*//g'`
    fi
fi

# Append optional send args if they were specified with -s option
if [ -n "$SEND_ARGS" ] ; then 
    RSHCMD="$RSHCMD $SEND_ARGS"
fi

histo_totalsecs=`expr $histo_time \* 60`

#if histo interval was already specified, use it
if [ -n "$histo_interval_set" ] ; then
    histo_count=`expr $histo_totalsecs / $histo_interval - 1`
else
    # setup the histo variables
    if [ $histo_time = 0 ] ; then # debug mode only
        histogram=FALSE
    elif [ $histo_time = 1 ] ; then
        histo_interval=1
    elif [ $histo_time -le 5 ] ; then
        histo_interval=10
    elif [ $histo_time -le 10 ] ; then
        histo_interval=30
    else
        histo_interval=60
    fi
fi

histo_count=`expr $histo_totalsecs / $histo_interval - 1`

# setup the time in seconds for RAM who needs it
# delay + 2 minutes to process everything
RAM_delay_time_secs=`expr $histo_time \* 60 + 120`

# verify that a app name also has an app param
# and setup the app stuff
if [ $APP_ON = TRUE ] ; then
    case $APP_NAME in
        oracle) 
            ORACLE_ON=TRUE
            parse_oracle_options
        ;;
        veritas) 
            VERITAS_ON=TRUE
        ;;
        *)
            console "Error: -a $APP_NAME.  Unsupported application."
            exit 1
        ;;
    esac
fi

# also, setup PERFHOST to this host
PERFHOST=`hostname`
CUR_HOST=$PERFHOST
# Check to see if we're running from an ESX server (only if perfstat detected a Linux based host OS)
if [ $os = Linux ] ; then
    if [ `check_vmware $CUR_HOST` = 0 ] ; then
        os=ESX
    fi
fi

# time file for epoch calculations done by timestamp() routine
TIME_FILE=$TMPDIR/perfstat.time

#if -F and -h were specified, do not include local host in host list
if [ $DO_HOST = FALSE -a $MULTI_HOST = TRUE ] ; then
    DO_HOST=TRUE
    console "Excluding localhost from hostlist"
else
    HOSTS="$PERFHOST $HOSTS"
fi

#gather config data on 1/10th of iterations w
CONF_FREQUENCY=`expr $ITERATIONS / 10`

# Set the timestamping procedure...varies on what's installed on perfhost and whether or not we're running in a Support Console
# NOTE -- timestamp mechanism should be set first before checking unix dependencies!!
set_timestamp
# Make sure we satisfy all dependencies that perfstat has on external UNIX tools before we begin execution
check_unix_dependencies

# verify rsh/ssh access to all hosts and filers
check_rsh_host
if [ $GXMODE = FALSE ] ; then
    check_rsh_filer
else
    debug "WARNING: Skipping rsh/ssh connectivity test to GX cluster"
    echo "WARNING: Skipping rsh/ssh connectivity test to GX cluster" >> $TMPDIR/error.log
    set_filer_context
fi

# Regular Perfstat header banner
header
echo "SOURCE_HOST_NAME, " `hostname`
echo "SOURCE_HOST_OS,   " "$os"
if [ -n "$PASSWORD" ] ; then
    echo "COMMAND_LINE,      \"$@\"" | sed "s/$PASSWORD/\*/g"
else
    echo "COMMAND_LINE,      \"$@\""
fi
echo
echo "SAMPLES,          " $histo_count
echo "SAMPLE_INTERVAL,  " $histo_interval
echo ""

# Calculate an upper bound based on expected running time...This prevents 
# perfstats from running "way" longer than expected
TIME_PER_ITR=`expr $histo_totalsecs + $ITER_INTERVAL \* 60`
RUN_TIME=`expr $TIME_PER_ITR \* $ITERATIONS \* 2`
sleep_time=`expr $ITER_INTERVAL \* 60`

# Burt384517:Check if the calculated RUN_TIME is less than the default 
# MAX_RUN_TIME and the -w option is not provided at command line, we replace 
# RUN_TIME value with MAX_RUN_TIME
if [ `expr $RUN_TIME` -lt `expr $MAX_RUN_TIME` ]; then
    RUN_TIME=$MAX_RUN_TIME
fi
console "Allowing perfstat to run for a max $RUN_TIME seconds "

# Source the stats black and whitelists
do_stats_lists

for CUR_FILER in $FILERS ; do
    set_filer_context
    # Build stats object black and white lists if we're in legacy mode
    # if [ $LEGACY_STATS = TRUE ] ; then 
        # check_stats_lists
    # fi
    echo "FILEROS,	$CUR_FILER,	$fileros"

    #if running for >60000 seconds (1000 minutes) and susceptible to 171830, disable statit permantly for this run
    if [ $fileros = ONTAP7.0 -o $fileros = ONTAP7.0.2 -o $fileros = ONTAP ] ; then
        if [ $RUN_TIME -gt 60000 ] ; then
            # console "Warning: $CUR_FILER may be susceptible to bug #171830.  Disabling stutter statit."
            console "Long perfstat requested and $CUR_FILER may be susceptible to bug #171830; Disabling statit."
            echo "Long perfstat requested and $CUR_FILER may be susceptible to bug #171830; Disabling statit." >> $TMPDIR/error.log
            touch $TMPDIR/$CUR_FILER/statit_disable
        fi
    fi
done

debug "Begin Main"

#============================================================
#
# Finally, do the actual prestat, sleep, poststat
#
#============================================================

# Pretend run...
if [ $PRETEND = TRUE ] ; then
    pretend_header
    # Get the config commands that were already executed at this point in the game:
    CUR_ITERATION=$ITERATIONS
    # Grab the config commands issues previously...
    do_pre_iterations
    LABEL=PRESTATS 
    do_prestats
    LABEL=POSTSTATS
    do_poststats
    [ -s $TMPDIR/pretend.stutter ] && cat $TMPDIR/pretend.stutter
    print_command_report
    # Grab the error log if any config commands errored
    [ -s $TMPDIR/error.log ] && append_error_log
    rm -rR -f $TMPDIR
    pretend_footer
    exit 0
fi # Else, No more pretending...

# Do any pre_iteration commands before entering the loop
if [ $CMODE = FALSE -a $GXMODE = FALSE ] ; then
    do_pre_iterations
fi

START_TIME=`timestamp`
STOP_TIME=`expr $START_TIME + $RUN_TIME`

# If force iterations was specified, define current time as start time so that it never gets checked
if [ $FORCE_ITERATIONS = TRUE ] ; then 
    CUR_TIME=$START_TIME
    debug "Forcing Perfstat to execute all iterations (-I option)"
fi
# Begin Main Iterations Loop #
while [ ${CUR_TIME:-`timestamp`} -lt $STOP_TIME -a ${CUR_ITERATION:=0} -lt $ITERATIONS ] ; do
    CUR_ITERATION=`expr $CUR_ITERATION + 1`
    CUR_HOST=$PERFHOST
    begin_iteration

    LABEL=PRESTATS 
    do_date

    if [ $BEGIN_ONLY = TRUE -o $ONESHOT = TRUE ] ; then
        console "Collect Prestats"
        echo "=== BEGIN PRESTATS FOR ITERATION $CUR_ITERATION AT `datestamp` ===" >> $TMPDIR/error.log
        do_prestats
        echo "=== END PRESTATS FOR ITERATION $CUR_ITERATION AT `datestamp` ===" >> $TMPDIR/error.log
    fi

    if [ $ONESHOT = TRUE -a $CONF_ONLY = FALSE ] ; then
        console "Sleep $histo_totalsecs"
        if [ $PRETEND = FALSE -a $CMODE = FALSE -a $GXMODE = FALSE ] ; then
            SLEEPING=TRUE
            sleep $histo_totalsecs
            SLEEPING=FALSE
        else
            echo "Sleep: $histo_totalsecs"
        fi
    fi

    # poststats
    LABEL=POSTSTATS
    if [ $END_ONLY = TRUE -o $ONESHOT = TRUE ] ; then
        console "Collect Poststats"
        echo "=== BEGIN POSTSTATS FOR ITERATION $CUR_ITERATION AT `datestamp` ===" >> $TMPDIR/error.log
        do_poststats
        echo "=== END POSTSTATS FOR ITERATION $CUR_ITERATION AT `datestamp` ===" >> $TMPDIR/error.log
    fi

    do_date
    end_iteration 
done
# End Iterations Loop #
#Calculate actual stopping time
DONE=`timestamp`

# Do any post iteration work
do_post_iterations

#### Some stats for the total running time ########################
TOTAL_TIME=`expr $DONE - $START_TIME`
debug "Total running time:  $TOTAL_TIME seconds"
echo ""
echo "=-=-= Perfstat Execution Statistics -=-=-=-="
echo "  Total Running Time: $TOTAL_TIME seconds"
exit 0
