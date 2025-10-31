#! /bin/sh
# ux2html
#
# Unix Systems Configuration HTML Report
#
# ux2html collect information from almost all Unix boxes:
# Linux/GNU, SunOS/Solaris, AIX, HP-UX, Darwin/OSX, Cygwin, System V, Android, Tru64, NonStop-UX, ...
# The script is very flexible with customizable parameters and plug-in support
#
# Usage:
#  Install the script under /usr/local/amm directory then execute it as root user:
#   sh ux2html.sh  > outputfile.html 2>/dev/null
#
# Author:	Bartolomeo Bogliolo mail@meo.bogliolo.name
#               
# Notes:
#  Running the script requires root privileges for best results
#
#  Customization can be performed setting parameters in (in order of precedence):
#      ux2c-`hostname`.sh	(suggested)
#      ux2c.sh			(suggested only when pre-configuring installations)
#      ux2html.sh 		(not suggested)
#   or adding custom plug-ins (ux2p* files are plug-ins)
#
# Change history:
# 23 May 95 1.0.0	meo	First release (dethtml.cmd)
#  1 May 96 1.1.0	meo	More info: Security, Oracle, ...
#  1 May 98 1.2.0	meo	First HTML release
#  ...                  meo     Additional Unix OS support (almost all Unix flavours)
# 25 Dec 05 1.2.33      meo     Last dethtml.cmd release; Cygwin support
#  1 Apr 06 1.3.0       meo     First ux2html.sh release; self contained pure Bourne shell, HTML 4.01, plug-ins, ...
#  1 May 06 1.3.1       meo     Minor graphical changes and bug fixing; more OS specific infos
#  1 Apr 09 1.3.2       meo     More plugins
#  1 Jan 10 1.3.3	meo	MAC OS X info
#  1 Apr 12 1.3.4	meo	HTML5, generated file list
#  1 Sep 12 1.3.5	meo	Plug-in updates
#  1 Jan 13 1.3.6	meo	System Security Files
#  1 Jan 15 1.3.7	meo	Several plug-in updates (eg default DB plugin: Oracle 11g+, MySQL 5.6+, Postgres 9.2+, ...)
#  1 Jan 17 1.3.8	meo	Plug-in updates, XMP tag, new CSS
#  1 Jan 18 1.3.9	meo	Plug-in updates
#  1 Feb 18 1.3.10	meo	Multiple execution paths
#  1 Jan 19 1.3.11      meo     Variable setting for standalone execution
#  1 Apr 19 1.3.12      meo     Plugin updates
#  1 Aug 19 1.3.13      meo     Plugin updates. (a) More security file checked
#  1 Jan 20 1.3.14      meo     Plugin updates
#  3 Sep 22 1.3.15      meo     Several plugin updates, some due to egrep/fgrep explicit deprecation in GNU egrep 3.8; Corosync-Pacemaker
#  1 Jan 23 1.3.16      meo     lstopo-no-graphics; plugin updates (a) ss (b) plugin updates (c) 2025-10-31 new CSS
# 31 Oct 25 1.3.17      meo     Plugin updates, new CSS

VERSION=1.3.17

# Copyright 1995-2025 mail@meo.bogliolo.name 
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

## Custom configuration  NB can be superseeded by other configuration files
SUMMARY=0
SUMMARY_MENU=0
ENABLE_CUSTOM=1
ENABLE_PLUGIN=1
TMP_FILE=.tmp_file

INST_DIR=/usr/local/amm
HTML_DIR=/usr/local/amm
LOC_DIR=/usr/local/amm
export INST_DIR HTML_DIR LOC_DIR

## Utility functions
break_lines()
{
while true
do
   read a
   if [ $? -ne 0 ]
   then
      break
   fi
   echo "<br>" "$a"
done
}

table_row()
{
awk '{ print "<tr><td> ", $1, "  <td>", $2, "  <td>", $3, "  <td>", $4, "  <td>", $5, "  <td>", $6, "  <td>", $7, "  <td>", $8, "  <td>", $9, "  <td>", $10 }'
}

table_build()
{
echo '<table class="bordered" summary="Easy reading table">'
awk '{ print "<tr><td> ", $1, "  <td>", $2, "  <td>", $3, "  <td>", $4, "  <td>", $5, "  <td>", $6, "  <td>", $7, "  <td>", $8, "  <td>", $9, "  <td>", $10 }'
echo "</table>"
}

table_buildn()
{
echo '<table class="bordered" summary="Easy reading numeric table">'
awk '{ print "<tr><td> ", $1, "  <td align=right>", $2, "  <td align=right>", $3, "  <td align=right>", $4, "  <td align=right>", $5, "  <td align=right>", $6, "  <td align=right>", $7 }'
echo "</table>"
}

HP_lan_scan()
{
for interface in `lanscan -p`
  do ifconfig lan$interface 2> /dev/null
done
}

AIX_fc_scan()
{
for i in `lsdev -F name | grep fcs`
 do
  echo
  lscfg -vpl $i
 done
}

vx_tot()
{
  DG=`$VXDG -q list | awk '{ print $1 }' `
  printf "%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n"  Disk_Group "Total_MB" "Used_MB" "Visible_MB" "Avail_MB" "Used%" > $TMP_FILE
  printf "%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n"  ---------- ---------- ---------- ---------- ---------- ---------- >> $TMP_FILE
  for i in $DG
  do
    S1=`$VXPRINT -q -d -g $i | awk 'BEGIN { sum = 0 } { sum += $5 } END { printf("%10.0f", sum/2048) }'`
    U1=`$VXPRINT -q -p -f -g $i | awk 'BEGIN { sum = 0 } { sum += $5 } END { printf("%10.0f", sum/2048) }'`
    V1=`$VXPRINT -q -v -f -g $i | awk 'BEGIN { sum = 0 } { sum += $5 } END { printf("%10.0f", sum/2048) }'`
    F1=`$VXDG -q -g $i free | awk 'BEGIN { sum = 0 } { sum += $5 } END { printf("%10.0f", sum/2048) }'`
    PC=`echo $S1 $U1 | awk '{ printf("%3.2f%%",($2*100)/$1) }'`
    printf "%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n"  $i $S1 $U1 $V1 $F1 "$PC" >> $TMP_FILE
  done

  cat $TMP_FILE

  printf "%10s\t%10s\t%10s\t%10s\t%10s\n"  ---------- ---------- ---------- ---------- ----------

  S1=`cat $TMP_FILE | awk 'BEGIN { sum = 0 } { sum += $2 } END { printf("%10.0f", sum) }'`
  U1=`cat $TMP_FILE | awk 'BEGIN { sum = 0 } { sum += $3 } END { printf("%10.0f", sum) }'`
  V1=`cat $TMP_FILE | awk 'BEGIN { sum = 0 } { sum += $4 } END { printf("%10.0f", sum) }'`
  F1=`cat $TMP_FILE | awk 'BEGIN { sum = 0 } { sum += $5 } END { printf("%10.0f", sum) }'`

  printf "%10s\t%10s\t%10s\t%10s\t%10s\t\n"  Total $S1 $U1 $V1 $F1

  rm -f $TMP_FILE

  echo
  $VXPRINT | awk 'BEGIN { g=0;d=0;v=0;p=0 } { if ($1=="dg") g++; if ($1=="dm") d++; \
    if ($1=="v") v++; if ($1=="pl") p++; } END \
    { print "Physical_Disks: " d "\nDisk_Groups: " g  "\nVolumes: " v "\nPlexes: " p }'
}

# Non OS Specific Info and default
ERRLEN=100
DATLEN=40
TMP_FILE=.tmp_file
MACHINE=`uname -n`
MAC_DET='uname -a'
SYSTYPE=`uname -s`
MAC_TYPE='Unknown'
IP='grep `uname -n` /etc/hosts'
ROUTE='netstat -rn; echo; echo ARP table; arp -a'
NFS='cat /etc/exports; echo ; showmount -a'
NTP='ntpq -p; timedatectl'
SERVS='lsof | grep LISTEN | grep -v loopback | sort | uniq'
SERVS2='netstat -an | grep LISTEN | grep -v STREAM; ss -plants'
USERS='cat /etc/passwd'
WHO='who /var/adm/wtmp | tail -$ERRLEN'
LASTB='lastb | tail -$ERRLEN'
AUREP='aureport --summary; aureport -au -i --failed| tail -$ERRLEN'
GRPS='cat /etc/group'
SECF="/etc/passwd /etc/group /etc/shadow /etc/hosts.equiv /root/.rhosts /.rhosts /etc/hosts.allow /etc/securetty /etc/ssh/sshd_config"
BOOT='cat /etc/inittab;echo;echo RC2;ls -lL /etc/rc2.d;echo;echo RC3;ls -lL /etc/rc3.d'
KBOOT='cat /etc/grub.conf | grep -v "^#"'
LBOOT='who -b'
HW_PROC='echo HW Processor    	Configuration NOT FOUND'
HW_MEM='echo HW Memory    	Configuration NOT FOUND'
HW_DISK='echo HW Disk    	Configuration NOT FOUND'
which vxdisk > /dev/null 2> /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   HW_DISK2='vxdmpadm listctlr all; echo; vxdmpadm listenclosure all; echo; vxdisk -o alldgs list'
   # vxdmpadm getsubpaths ctlr=
else
   HW_DISK2=''
fi
# Power Path ... to be added
FC_DISK='echo Fiber      	Configuration NOT FOUND'
HW_DEVICE='echo HW Device    	Configuration NOT FOUND'
HW_NET='echo HW Network    	Configuration NOT FOUND'
HW_DIAG='echo HW Diagnostic    	NOT FOUND'
SW_DIAG='tail -$ERRLEN /var/adm/messages'
SWAP='echo SWAP Configuration NOT FOUND'
APPL_FSS="/usr /var /var/lib"
TAILFROM=
DF=df
MOUNT_OPT=/etc/fstab
MOUNT_CURR='mount'
LP='lpstat -s'
PKG=pkginfo
REPO='echo'
PATCH='echo Patch Information    	NOT FOUND'
LICENSE='echo License Information    	NOT FOUND'
SHOW_FDMN='echo Domains Information     NOT FOUND'
KERNEL='echo Kernel Information     NOT FOUND'
IPC='ipcs -a'
PS='ps -efa'
DU='du -skx'
# VMSTAT='vmstat 5 5; echo;echo; iostat 5 5; echo;echo; sar'
VMSTAT='vmstat 5 5; echo;echo; sar'
PSL='ps -elfa'
NETA='netstat -an'
CRON_DIR=/var/spool/cron/crontabs
CRON_INFO="ls -l $CRON_DIR; echo ; echo '<b>Crontab</b>'; echo ; find $CRON_DIR -type f -print -exec cat {} \;"
ETC_CLU='echo Cluster Information     NOT FOUND'
DET_CLU='echo Cluster Detailed Information     NOT FOUND'
LOG_CLU='echo Cluster Logs     NOT FOUND'
ETC_PAR='echo Partitioning Information     NOT FOUND'

VOL_TOT=''
VOL=''
VXDG=vxdg
VXPRINT=vxprint
# VXVVR='vradmin printvol; vradmin printrvg' 	# too much info...
# vradmin printrvg | grep RvgName | sort | uniq | awk '{ print $2 ; }'
# vradmin -g XXX_dg repstatus XXX_rvg
which vradmin > /dev/null 2> /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   VXVVR='vradmin printrvg 2> /dev/null'
else
   VXVVR=''
fi

HOSTS='cat /etc/hosts'
if [ -f /etc/resolv.conf ]
then
	DNSC='cat /etc/resolv.conf | grep -v "^;" '
else
	DNSC='echo "DNS resolver not configured"'
fi
if [ -f /etc/named.boot ]
then
	DNSS='cat /etc/named.boot'
else
	DNSS='echo "The system is not a DNS Server"'
fi


## System specific info

## SV \pub\ux2html\ux2html.sh 4
if [ $SYSTYPE = SVR4 ]
then
	MAC_TYPE='System V'
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" | grep -v /proc '
	HW_DEVICE=hwconf
	SWAP='swap -l; swap -s'

## Sun Solaris
elif [ $SYSTYPE = Solaris -o $SYSTYPE = SUN -o $SYSTYPE = SunOS ]
then
	MAC_TYPE='SUN Solaris'
       # psrinfo -v ;psrinfo -pv ;; prtdiag -v
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" | grep -v /proc '
	MOUNT_OPT=/etc/vfstab
	# psrinfo -v | grep MHz | sort | uniq -c | awk ' { print $1, $3, $7, "MHz" } '
	HW_PROC='echo "CPU# \c" ;psrinfo | wc -l; echo; psrinfo -v | grep -v Status'
       	HW_DEVICE='prtconf; echo; sysdef -d' 
	VOL='metastat -i'
        if [ -d /usr/lib/osa ]
        then
                HW_DEVICE=$HW_DEVICE';echo '
                HW_DEVICE=$HW_DEVICE';echo RAIDS'
                HW_DEVICE=$HW_DEVICE';echo '
                HW_DEVICE=$HW_DEVICE';/usr/lib/osa/bin/lad'
                HW_DEVICE=$HW_DEVICE';/usr/lib/osa/bin/drivutil -d `/lib/osa/bin/lad|cut -b1-8|head -1`'
                HW_DEVICE=$HW_DEVICE';/usr/lib/osa/bin/drivutil -l `/lib/osa/bin/lad|cut -b1-8|head -1`' 
        fi
        if [ -d /opt/SUNWvxvm ]
        then
		VXDG=vxdg
		VXPRINT=vxprint
        fi
        HW_DISK='echo | format | grep -v disk'
        FC_DISK='luxadm -e port; echo; fcinfo hba-port 2>/dev/null'
        # Old Solaris: FC_DISK= luxadm -e port + for cycle luxadm -e dump_map [PORT]
        NETA="netstat -i; echo '<p>'; dladm show-phys; echo '<p>'; netstat -an"
        HW_NET='ifconfig -a'
        if [ -x /usr/platform/`uname -m`/sbin/prtdiag ]
        then
                HW_DIAG='/usr/platform/`uname -m`/sbin/prtdiag -v'
                HW_MEM='/usr/platform/`uname -m`/sbin/prtdiag -v | grep Memory | grep -v ====='
        fi
        if [ -x /usr/kvm/prtdiag ]
        then
                HW_DIAG='/usr/kvm/prtdiag -v'
                HW_MEM='/usr/kvm/prtdiag -v | grep Memory | grep -v ====='
        fi
        SWAP='swap -l; swap -s'
	DU='du -sk'
	MAC_DET='uname -a ; showrev'
	PKG='pkginfo'
	PATCH='showrev -p'
	LICENSE='cat /etc/opt/licenses/licenses_combined'
	KERNEL='cat /etc/system; echo; sysdef -i'
	NFS='cat /etc/dfs/sharetab /etc/dfs/dfstab; echo; showmount -a'
	WHO='who /var/adm/wtmpx | tail -$ERRLEN; echo; tail -$ERRLEN /var/adm/sulog'
	zoneadm list > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
	    ETC_PAR='zoneadm list -cv'
	fi

## HP HP-UX
elif [ $SYSTYPE = HPUX -o $SYSTYPE = HP-UX ]
then
	MAC_TYPE='HP HP-UX'
	MAC_TYPE=`echo HP-UX; model`
	HW_PROC=' ioscan -kC processor; echo; /usr/sbin/icod_stat '
	HW_MEM=' head -l -n 200 /var/adm/syslog/syslog.log|grep Physical|grep avail|cut -c 35-'
        DF='bdf | sed -e "s/Mounted on/Mounted_on/g" '
       	VOL_TOT="vgdisplay | grep -E 'VG Name|PE Size|Total PE|Free PE'"
	VOL='vgdisplay -v'
	# On hpux 11.23 rad -> olrad
        HW_DEVICE='ioscan -fkn; rad -q' 
        HW_DISK='ioscan -kC disk'
        FC_DISK='fcmsutil /dev/fcd0 ; fcmsutil /dev/fcd1'
	HW_NET="lanscan; echo '<p>'; HP_lan_scan"
	PKG='swlist -l bundle'
	PATCH=swlist
	# On hpux 11.23 kmtune -> kctune
	KERNEL='kmsystem ; echo; kmtune; echo; echo Kernel Loadable Modules ; kmadmin -s; echo; crashconf -v'
	if [ `uname -r` = A.09.04 ]
	then
		SW_DIAG='tail -$ERRLEN /usr/adm/syslog; tail -$ERRLEN /var/adm/shutdownlog'
		PKG='ls /etc/filesets'
		WHO='who /etc/wtmp | tail -$ERRLEN'
	else
		SW_DIAG='tail -$ERRLEN /var/adm/syslog/syslog.log; tail -$ERRLEN /var/adm/shutdownlog'
		WHO='who /var/adm/wtmp | tail -$ERRLEN'
	fi
	SWAP='swapinfo'
	NETA="netstat -i; echo '<p>'; netstat -an"
	cmviewcl > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
 		ETC_CLU='echo "HP Cluster ServiceGuard";echo;cmviewcl'
 		DET_CLU='cmviewcl -v'
 		LOG_CLU='ls -l /etc/cmcluster/*/*.log /var/adm/syslog/syslog.log'
 	fi
	parstatus -s  > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
 		ETC_PAR='parstatus'
		vparstatus > /dev/null 2>&1
		RES=$?
		if [ $RES -eq 0 ]
 		then
		   if [ $SUMMARY -eq 0 ] ; then
 			ETC_PAR='echo Hardware Partitioning;parstatus;echo;echo Virtual Partitioning;vparstatus -v'
		   else
 			ETC_PAR='echo Hardware Partitioning;parstatus;echo;echo Virtual Partitioning;vparstatus'
		   fi
 		fi
	else
		vparstatus > /dev/null 2>&1
		RES=$?
		if [ $RES -eq 0 ]
 		then
		   if [ $SUMMARY -eq 0 ] ; then
 			ETC_PAR='echo Virtual Partitioning;vparstatus -v'
		   else
 			ETC_PAR='echo Virtual Partitioning;vparstatus'
		   fi
 		fi
 	fi
	BOOT='cat /etc/inittab;echo;echo RC2;ls -lL /sbin/rc2.d;echo;echo RC3;ls -lL /sbin/rc3.d'

## Tandem NON-STOP UX
elif [ $SYSTYPE = tandem -o $SYSTYPE = "NonStop-UX" ]
then
	MAC_TYPE='HP/Compaq/Tandem NON-STOP UX'
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" | grep -v /proc '
	VOL='volprint -th'
	HW_DEVICE=cfiolist
	HW_DIAG='cfstatus'
	SW_DIAG='lcat /var/adm/messages | tail -$ERRLEN'
	SWAP='swap -l'

## IBM AIX
elif [ $SYSTYPE = AIX ]
then
	MAC_TYPE='IBM AIX'
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" '
	IP='grep `uname -n` /etc/hosts ; lssrc -a'
	# cpu_state (Model: G, J, R)
	cpu_state -l > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
           HW_PROC='cpu_state -l; echo; lsdev -C -c processor'
	else
           HW_PROC='lsdev -C -c processor'
	fi
        HW_MEM='lsdev -C | grep mem; lsattr -El mem0'
        HW_DEVICE='lsdev -C -H'
	# lsattr -E -l
        HW_DISK='lsdev -C -c disk'
        FC_DISK='AIX_fc_scan'
	# FCA = ... fcstat fcs0 ...
        VOL_TOT='lsvg -o'
	# datapath query essmap ; lsvpcfg
        VOL='lsvg -o | lsvg -i -l | sed -e "s/LV /LV_/g" '
        SWAP='lsps -a'
        PKG='lslpp -l'
	LICENSE='lslicense'
        HW_NET='ifconfig -a; echo; netstat -i'
	SW_DIAG='errpt -a | head -$ERRLEN'
	ETC_CLU='lssrc -g cluster;echo;cllsgrp'
	DET_CLU='clshowres'
	ETC_PAR='lparstat; lparstat -i'
	KBOOT='echo BootList; bootlist -m normal -o'
	BOOT='cat /etc/inittab;echo;echo RC2;ls -lL /etc/rc.d/rc2.d'
	KERNEL='oslevel; echo;echo VirtualMemory_Options;vmo -a; echo Network_Options;no -a; echo NFS_Options;nfso -a; echo IO_Options;ioo -a; echo Reliability_Options;raso -a; echo Scheduling_Options;schedo -a '
#        PATCH='echo "ML/TL:"; oslevel -r;echo "<br>"; oslevel -s|grep 00; echo; instfix -ik'
        PATCH='echo "ML/TL:"; oslevel -r;echo "<br>"; oslevel -s|grep 00'
	MAC_DET='uname -a; uname -M'
	NFS='cat /etc/exports; echo ; showmount -a'
	WHO='who -m /var/adm/wtmp | tail -$ERRLEN'

## Digital Unix OSF1 - Compaq Tru64 - HP Tru64
elif [ $SYSTYPE = OSF1 ]
then
	MAC_TYPE='HP/Compaq/Digital Digital Unix/OSF1/Tru64'
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" | grep -v /proc '
        HW_PROC='psrinfo -v; consvar -v -d'
        HW_MEM='uerf -r 400 | grep -i mem'
        HW_DEVICE='scu scan edt > /dev/null; scu show edt'
        HW_DISK='echo "See <a href="#hw_device">Device Section</a>"'
        VOL_TOT=' ls /etc/fdmns | xargs showfdmn -k '
        VOL='volprint -Ath'
        VXDG='voldg'
        VXPRINT='volprint'
        SWAP='swapon -s'
        PKG='setld -i'
        PATCH='uname -v'
	LICENSE='lmf list'
        HW_NET='ifconfig -a'
	HW_DIAG='uerf -R | head -$ERRLEN'
	asemgr -d > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
 		ETC_CLU='echo "HP Cluster ASE Tru64";echo;asemgr -d'
 		DET_CLU='asemgr -d -C'
 	fi
	caa_stat > /dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
 		ETC_CLU='echo "HP Cluster CAA Tru64";echo;caa_stat -t'
 		DET_CLU='caa_stat -t -v; echo; echo; caa_stat -f'
 	fi
	if [ `uname -r` = V5.1 ]
	then
          HW_DEVICE='scu scan edt > /dev/null; scu show edt; dsfmgr -vV;hwmgr -show scsi -full'
	fi
	KERNEL='cat /etc/sysconfigtab'
	BOOT='cat /etc/inittab;echo;echo RC2;ls -lL /sbin/rc2.d;echo;echo RC3;ls -lL /sbin/rc3.d'
	MAC_DET='uname -a ; sizer -v'


## Sequent NUMA
elif [ $SYSTYPE = DYNIX/ptx ]
then
	MAC_TYPE='Numa Unix'
        DF='df -k | cat'
        HW_DISK='echo "See <a href="#hw_device">Device Section</a>"'
        SWAP='swap -l; swap -f'
        HW_NET='ifconfig -a'
	SW_DIAG='tail -$ERRLEN /usr/adm/messages'
	VXDG=vxdg
	VXPRINT=vxprint
        VOL='vxprint -Ath'

## Linux/GNU
elif [ $SYSTYPE = Linux ]
then
	MAC_TYPE='Linux / GNU'
	MAC_DET='uname -a ; dmidecode|grep Vendor|grep -v Syndrome;dmidecode|grep Manufacturer|head -1;dmidecode|grep Product|head -1'  # dmidecode -q -t system does not work with RH 4.x
        DF='df -kP | sed -e "s/Mounted on/Mounted_on/g" | sed -e "s/^   /./" | grep -v /proc; echo; df -h '
        SWAP='swapon -s'
	IPC='ipcs -a;echo;ls -al /dev/shm'
	PS='ps -efaww'
	TAILFROM='-n'
        PKG='rpm -aq --queryformat "%{NAME}-%{VERSION}-%{RELEASE} %{ARCH}\n"|sort'
	REPO='echo;yum repolist; echo; yum check-update'
	which dpkg >/dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
	    PKG="dpkg -l"
	fi
        PATCH='uname -v -r;echo "<br>"; cat /etc/*-release; cat /etc/debian_version; cat /etc/issue; echo "<br>"; rpm -q kernel 2>/dev/null; rpm -qa | grep release'
        # New network commands: ip ss
	NETA="ss -plants; echo '<p>'; netstat -i; echo '<p>'; netstat -an"
	HW_NET='ip link; echo; ip addr; echo; ifconfig -a; echo; ethtool eth0; echo; ethtool eth1; echo; mii-tool 2>/dev/null; echo; cat /proc/net/bonding/*; echo;  brctl show ; bridge vlan show 2>/dev/null'
	ROUTE='ip route; echo; ip -s neigh; echo; netstat -rn; echo; echo ARP table; arp -a; echo; echo IP table; iptables -L'
        if [ $SUMMARY -eq 0 ] ; then
	   HW_PROC="uname -p; echo;cat /proc/cpuinfo| grep -E 'model name|processor|bogo|cpu|cache'"
        else
	   HW_PROC="uname -p; echo;cat /proc/cpuinfo| grep -E 'model name'; lstopo-no-graphics --no-legend --of txt"
        fi

	HW_MEM='free -t; echo Meminfo; cat /proc/meminfo; echo;echo NUMA; numactl --hardware; echo; echo PS; ps aux --sort -rss | head -50'
	HW_DISK='(echo "<b>IDE</b>";echo "p"|fdisk /dev/hda;\
		echo;echo "<br><b>SCSI</b>";echo "p"|fdisk /dev/sda;\
		echo;echo "<br><b>ESDI</b>";echo "p"|fdisk /dev/eda;\
		echo;echo "<br><b>XT</b>";echo "p"|fdisk /dev/xda;\
		echo;echo "<br><b>Configuration</b>"; cat /proc/scsi/*/*) 2>/dev/null |grep -v "Command" | grep -v "EOF" | grep -v Unable'
	# Useful: cat /proc/partitions; dmsetup ls --tree; pvscan ;
	HW_DISK='fdisk -l; echo; cat /proc/scsi/*/*; echo; multipath -ll'
	HW_DEVICE='echo "<b>PCI</b>";lspci;echo "<br><b>USB</b>";lsusb;echo "<br><b>Plug&Play</b>";lspnp 2>/dev/null;echo "<br><b>BIOS</b>"; dmidecode'
	FC_DISK='lspci|grep Fibre; echo WWNs; cat /sys/class/fc_host/host*/node_name /sys/class/fc_host/host*/port_name 2>/dev/null'
	SW_DIAG='tail -$ERRLEN /var/log/messages'
	LICENSE='echo No Licenses, this is a Linux box!'
	HW_DIAG='dmesg'
	LP='lpstat -t'
	# VOL_TOT='lsraid -D -p '
	VOL='lsraid -R -p ; echo; vgdisplay -v; echo; lvm dumpconfig'
	CRON_DIR=/var/spool/cron
        ####### find $CRON_DIR -type f -print -exec cat {} \; -exec echo '<br>' \;"
	CRON_INFO="ls -l /etc/cron*; echo ;ls -l $CRON_DIR; echo; echo '<b>Crontabs</b>'; echo ; find $CRON_DIR -type f -print -exec cat {} \;"
	KERNEL='cat /etc/modprobe.conf;echo;sysctl -a'
        ETC_CLU='clustat; echo; mkqdisk -L'
        DET_CLU='clustat -l ; echo ;cman_tool nodes; echo ; cat /etc/cluster/cluster.conf'

	which pcs >/dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
            # Corosync/Pacemaker
            ETC_CLU='crm_mon -1 -V; crm_verify -L -V'
            DET_CLU='pcs config ; echo ; cat /etc/corosync/corosync.conf'
	fi

        # cman_tool status nodes services
	WHO='who /var/log/wtmp | tail -$ERRLEN; echo; tail -$ERRLEN /var/log/sulog'
	BOOT='cat /etc/inittab;echo;echo RC2;ls -lL /etc/rc2.d;echo;echo RC3;ls -lL /etc/rc3.d;echo;chkconfig --list'	
	LBOOT="who -b;echo;grep  'Booting processor' /var/log/messages* | awk -F : ' { print \$2 \":\" \$3 \":\" \$4 } ' | uniq ; last reboot"
 	# RHEL7/CentOS7/OEL7 or Fedora20 use systemctl, hostnamectl, ... Please install: net-tools lsof
	which systemctl >/dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
	    BOOT='systemctl list-dependencies; echo; systemctl list-units; echo; stat -fc %T /sys/fs/cgroup/; echo; systemd-cgls;'
	fi
	which hostnamectl >/dev/null 2>&1
	RES=$?
	if [ $RES -eq 0 ]
 	then
	    MAC_DET2='hostnamectl status; echo; localectl'
	fi

## Darwin
elif [ $SYSTYPE = Darwin ]
then
	MAC_TYPE='Darwin / MAC OS X'
        DF='df -lh'
        SWAP='vm_stat'
	PS='ps -feww'
	TAILFROM='-n'
        PKG='ls /Applications; echo; pkgutil --pkgs'
	# lsbom
	PATCH='sw_vers'
	HW_NET='ifconfig -a; echo; netstat -a'
	HW_PROC="hostinfo | grep -i processor; system_profiler SPHardwareDataType | grep -i processor; lstopo-no-graphics --no-legend --of txt"
	HW_MEM='hostinfo | grep -i memory; echo; ls -l /var/vm'
	HW_DISK='diskutil list' ##  pdisk -l
        if [ $SUMMARY -eq 0 ] ; then
	   # HW_DEVICE='hostinfo; echo; ioreg -bls; echo; system_profiler; echo; nvram -p'
	   HW_DEVICE='hostinfo; echo; ioreg -bls -d 3; echo; nvram -p'
        else
	   HW_DEVICE='hostinfo'
        fi
	SW_DIAG='tail -$ERRLEN /var/log/system.log'
	LICENSE='echo "N.A."'
	HW_DIAG='dmesg'
	LP='lpstat -t'
	CRON_DIR=/var/spool/cron
	CRON_INFO="launchctl list; echo; crontab -l"
	KERNEL='launchctl limit; echo; sysctl -a'
	WHO='last'
	BOOT='ls -lL /System/Library/StartupItems;echo;ls -lL /Library/StartupItems; echo; ls -lL /etc/rc*'
	NFS='cat /etc/exports; echo ; showmount -a'
	APPL_FSS="/usr /var /Users/* /Users/*/Documents"

## Cygwin
elif [ `echo $SYSTYPE | cut -b 1-6` = CYGWIN ]
then
	MAC_TYPE='Cygwin / Windows'
        DF='df -k | sed -e "s/Mounted on/Mounted_on/g" | grep -v /proc '
	PS='ps -lW'
        PKG='ls -l /proc/registry/HKEY_LOCAL_MACHINE/SOFTWARE'
        PATCH='uname -v -r'
        HW_DISK='cat /proc/partitions'
	HW_NET='ipconfig'
        VMSTAT='cat /proc/loadavg; echo; cat /proc/stat'
        if [ $# -eq 0 ] ; then
	   HW_PROC="cat /proc/cpuinfo| grep -E 'model name|processor|bogo|cpu|cache'"
        else
	   HW_PROC="cat /proc/cpuinfo| grep -E 'model name'"
        fi

	HW_MEM='cat /proc/meminfo'
	SW_DIAG='tail -$ERRLEN /cygdrive/c/windows/WindowsUpdate.log'
	HW_DIAG='tail -$ERRLEN /cygdrive/c/windows/setup*.log'
	LICENSE='echo GPL'
	BOOT='echo Boot information not found'
	IPC='echo IPC information not found'
	CRON_INFO="at"
	LP='prnmngr -l'

## VMWare ESX 4.1
elif [ $SYSTYPE = VMkernel ]
then
	MAC_TYPE='VMware VMkernel'
	MAC_DET='uname -a'
	DF='df -h; vdf; vdu'
	PS='ps'
	PATCH='uname -v -r'
fi

# VCS can be installed on all boxes!
if [ -f /etc/VRTSvcs/conf/config/main.cf ]
then
	PATH=$PATH:/opt/VRTSvcs/bin/:/opt/VRTS/bin/
	ETC_CLU='echo "Veritas Cluster VCS";echo;hastatus -sum; echo; lltstat -nvv | grep -v DOWN | grep -v WAIT | grep -v IDLE'
	#DET_CLU='hagrp -dep; echo; hares -display -attribute Group ; echo ; cat /etc/VRTSvcs/conf/config/main.cf | sed "s/</-/g" | sed "s/>/-/g"'
	DET_CLU='cat /etc/VRTSvcs/conf/config/main.cf;echo; hagrp -dep'
	LOG_CLU='halog -info'
fi

## Read external custom configuration
G_CONF=0
C_CONF=0
H_CONF=0
if [ $ENABLE_CUSTOM -eq 1 ] ; then
    if [ -f ux2c.sh ] ; then
         . ./ux2c.sh
         G_CONF=1
    fi
    if [ -f ux2cc.sh ] ; then
         . ./ux2d.sh
         C_CONF=1
    fi
    if [ -f ux2c.$MACHINE.sh ] ; then
         . ./ux2c.$MACHINE.sh
         H_CONF=1
    fi
fi

### Printout data collection
## MENU
echo '<!DOCTYPE html>'
echo '<html lang="en"> <head> <meta charset="UTF-8" /> <link rel="stylesheet" href="style.css" />'
echo '<title>' $MACHINE ' - ux2html Unix Statistics</title> </head>'
echo '<body>'

echo '<p><a id="top"></a>' 
echo '<h1 align=center>'
echo $MACHINE 
echo '</h1>'


echo '<table><tr><td><ul>' 
echo '<li><a href="#machine">System</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#machine">System name and Version</a></li>' 
  echo ' <li><a href="#mac_notes">System Description</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#user">Users</a></li>' 
    echo ' <li><a href="#group">Groups</a></li>' 
    echo ' <li><a href="#sec">System Security</a></li>' 
  fi
  echo ' </ul>'
fi

echo '<li><a href="#sdf">Space Configuration</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#df">File Systems</a></li>' 
  echo ' <li><a href="#vol_tot">Volume Summary</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#vol">Logical Volumes</a></li>' 
  fi
  echo ' </ul>'
fi

echo '<li><a href="#net">Network Configuration</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#net">IP Addresses</a></li>' 
  echo ' <li><a href="#hw_net">Network Adapters</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#hosts">Host file</a></li>' 
    echo ' <li><a href="#dnsc">DNS Client</a></li>' 
    echo ' <li><a href="#dnss">DNS Server</a></li>' 
    echo ' <li><a href="#route">Routing</a></li>' 
    echo ' <li><a href="#nfs">NFS</a></li>' 
    echo ' <li><a href="#ntp">NTP</a></li>' 
  fi
  echo ' </ul>'
fi
echo ' </ul>'

echo '<td><ul><li><a href="#conf">HW Configuration</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#hw_proc">Processors</a></li>' 
  echo ' <li><a href="#hw_mem">Memory</a></li>' 
  echo ' <li><a href="#hw_device">Devices</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#hw_disk">Disks</a> (<a href="#hw_disk2">Other infos</a>)</li>' 
    echo ' <li><a href="#fc_disk">Fiber Channel Adapters</a></li>' 
  fi
  echo ' <li><a href="#format">Disk User Info</a></li>' 
  echo ' <li><a href="#par">System Partitioning</a></li>' 
  echo ' </ul>'
fi

echo '<li><a href="#confs">SW Configuration</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#dist">OS Distribution</a></li>' 
  echo ' <li><a href="#swap">Swap Space</a></li>' 
  echo ' <li><a href="#dirs">Directories Usage</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#lp">Printers</a></li>' 
    echo ' <li><a href="#pkg">SW Packages</a></li>' 
    echo ' <li><a href="#license">Licenses</a></li>' 
    echo ' <li><a href="#kern">Kernel Parameters</a></li>' 
    echo ' <li><a href="#patch">Installed Patches/Distrib.</a></li>' 
    echo ' <li><a href="#boot">Boot scripts</a></li>' 
    echo ' <li><a href="#lboot">Last Boot</a></li>' 
    echo ' <li><a href="#cluc">Cluster configuration</a></li>' 
  fi
  echo ' </ul>'
fi
echo ' </ul><td><ul>'

echo '<li><a href="#stat">System Status</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  echo ' <li><a href="#ssum">Status Summary</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#procs">Processes</a></li>' 
    echo ' <li><a href="#vmstat">System Usage</a></li>' 
    echo ' <li><a href="#ipc">InterProcess Communication</a></li>' 
    echo ' <li><a href="#neta">Network Activity</a></li>' 
    echo ' <li><a href="#servs">Active Services</a></li>' 
    echo ' <li><a href="#cron">Cron</a></li>' 
  fi
  echo ' <li><a href="#clu">Cluster status</a></li>' 
  echo '<li><a href="#act">Activity log</a></li>' 
  if [ $SUMMARY -eq 0 ] ; then
    echo ' <li><a href="#sw_diag">Software Diagnostics</a></li>' 
    echo ' <li><a href="#hw_diag">Hardware Diagnostics</a></li>' 
  fi
  echo ' </ul>'
fi

echo '<li><a href="#optm">Plug-in</a>' 
if [ $SUMMARY_MENU -eq 0 ] ; then
  echo ' <ul>'
  X=0
  for i in `ls ux2p.*.*.sh`
  do
      XX=`echo $i | awk -F. ' { print $3 } ' `
      echo ' <li><a href="#Plugin'$X'">' $XX '</a></li>' 
      X=`expr $X + 1 `
  done
  echo ' </ul>'
fi
echo '<li><a href="#opt">HTML Files</a>' 
echo '</ul></table><p>' 

## Printing system info
echo '<hr><p>Statistics generated on: '
date
echo 'from: '
pwd
echo 'by: '
id
echo 'format: '
if [ $SUMMARY -eq 0 ] ; then
  echo '<i>detailed</i>'
else
  echo '<i>summary</i>'
fi


echo '<p><I>General Unix Schema: <b>ux2html.sh</b> v.' $VERSION
if [ $G_CONF -eq 1 ] ; then
	echo '+ Custom Configuration '
fi
if [ $H_CONF -eq 1 ] ; then
	echo '+ Local Host Custom Configuration'
fi
echo '<br>This software is released under the' 
echo '<a href="http://www.gnu.org/licenses/gpl.html">GNU General Pubblic License</a>.'
echo 'See <a href="#LIC">below</a> for more information</I><p>'
 
echo '<hr><p><a id="machine"></a><H2>System</h2>' 
echo '<b>'
echo $MACHINE | break_lines
echo '</b>'
echo '<p>'
echo "System evaluated as: <b>" $MAC_TYPE '</b>'
echo '<br>'
echo '<p>'
echo '<pre>'
eval $MAC_DET 
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><a id="mac_notes"></a><H3>System Description</h3>' 
cat /etc/.sys_descr.htm 2>/dev/null
echo '<pre>'
eval $MAC_DET2
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><a id="user"></a><H3>Users</h3>' 
  echo '<pre>'
  eval $USERS
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="group"></a><H3>Groups</h3>' 
  echo '<pre>'
  eval $GRPS
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="sec"></a><H3>System Security Files</h3><pre>' 
  ls -l $SECF 2> /dev/null
  echo '</pre><p>'
  openssl md5 $SECF 2> /dev/null | break_lines
  echo '<p><pre>'
  # The following line SHOULD BE SKIPPED...
  more $SECF 2> /dev/null
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
fi

echo '<hr><p><a id="sdf"></a><H1>Space Configuration</h1>' 
echo '<hr><p><a id="df"></a><H2>File Systems</h2>' 
eval $DF | table_build
echo '<p><H3>Mount Options</h3><pre>'
grep -v '^#' $MOUNT_OPT | grep -v '^$'
echo '</pre><p><H3>Current Mounts</h3>'
eval $MOUNT_CURR | table_build
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><p><a id="vol_tot"></a><H2>Volumes Summary</h2>' 
if [ "X$VOL_TOT" != "X" ] ;  then
        eval $VOL_TOT | table_build
fi
# Veritas VxVM
if [ "X$VXDG" != "X" ] ;  then
        echo '<p><b>VxVM Volume Summary</b><p>'
        vx_tot | table_buildn
fi

echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><p><a id="vol"></a><H2>Logical Volumes</h2>' 
  echo '<pre>'
  eval $VOL 2> /dev/null
  echo '</pre>'
  # Veritas VxVM
  if [ "X$VXPRINT" != "X" ]
      then
          echo '<p><b>VxVM Volume Details</b><p>'
          $VXPRINT | table_build
     if [ "X$VXVVR" != "X" ]
         then
             echo '<p><b>VxVM Performance statistics</b><p>'
	     echo '<pre>' 
             vxstat -o alldgs 2> /dev/null
	     echo '</pre>' 
             echo '<p><b>VVR Details</b><p>'
	     echo '<pre>' 
             eval $VXVVR
	     echo '</pre>' 
     fi
  fi
  echo '<p><a href="#top">Go to the top</a>' 
fi

echo '<hr><p><a id="net"></a><H2>Network Configuration</h2>' 
echo '<pre>'
eval $IP 
echo '</pre>'
echo '<hr><a id="hw_net"></a><H3>Network Adapters</h3>' 
echo '<pre>'
eval $HW_NET
echo '</pre>'

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><a id="hosts"></a><H3>Host file</h3>' 
  echo '<pre>'
  eval $HOSTS 
  echo '</pre>'
  echo '<hr><a id="dnsc"></a><H3>DNS Client</h3>' 
  eval $DNSC | break_lines
  echo '<hr><a id="dnss"></a><H3>DNS Server</h3>' 
  echo '<pre>'
  eval $DNSS 
  echo '</pre>'
  echo '<hr><a id="route"></a><H3>Routing</h3>' 
  echo '<pre>'
  eval $ROUTE 2>/dev/null
  echo '</pre>'
  echo '<hr><a id="nfs"></a><H3>NFS</h3>' 
  echo '<pre>'
  eval $NFS
  echo '</pre>'

  echo '<hr><a id="ntp"></a><H3>NTP</h3>' 
  echo '<pre>'
  eval $NTP
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="iftop"></a><H3>IFTOP</h3>' 
  echo '<pre>'
  iftop -t -s 60   2>/dev/null
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
fi

echo '<hr><p><a id="conf"></a><H2>HW Configuration</h2>' 
echo '<p><a id="hw_proc"></a><H3>Processors</h3>' 
echo '<pre>'
eval $HW_PROC 
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

echo '<p><a id="hw_mem"></a><H3>Memory</h3>' 
echo '<XMP>'
eval $HW_MEM 
echo '</XMP>'
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><a id="hw_device"></a><H3>Devices</h3>' 
echo '<pre>'
if [ $SUMMARY -eq 0 ] ; then
  eval $HW_DEVICE 
else
  eval $HW_DEVICE | head -$DATLEN
  echo '...'
fi
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><a id="hw_disk"></a><H3>Disks</h3>' 
  echo '<pre>'
  eval $HW_DISK 
  echo
  echo '<a id="hw_disk2"></a><H3>Storage Extended Infos</h3>' 
  eval $HW_DISK2
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
  echo '<hr><a id="fc_disk"></a><H3>Fiber Channel Adapters</h3>' 
  echo '<pre>'
  eval $FC_DISK 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

fi

echo '<hr><a id="format"></a><H3>Disks User Info</h3>' 
cat /etc/.sys_disk.htm 2>/dev/null
echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="par"></a><H2>System Partitioning</h2>' 
  echo '<pre>'
  eval $ETC_PAR  2>/dev/null
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
  

echo '<hr><p><a id="confs"></a><H2>SW Configuration</h2>' 

echo '<hr><p><a id="dist"></a><h3>OS Distribution</h3><p>' 
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$PRETTY_NAME"
elif [ -f /etc/lsb-release ]; then           # Old Ubuntu
    . /etc/lsb-release
    echo "$DISTRIB_DESCRIPTION"
elif [ -f /etc/redhat-release ]; then        # Red Hat, CentOS, Fedora, OL, 
    cat /etc/redhat-release
elif [ -f /etc/debian_version ]; then        # Debian
    echo "Debian $(cat /etc/debian_version)"
elif [ -f /etc/alpine-release ]; then        # Alpine
    echo "Alpine Linux $(cat /etc/alpine-release)"
elif [ -f /etc/SuSE-release ]; then          # SUSE
    cat /etc/SuSE-release
else 
    uname -s -r
fi
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><p><a id="swap"></a><h3>Swap Space</h3>' 
echo '<pre>'
eval $SWAP
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><p><a id="dirs"></a><h3>Directories Usage</h3>' 
echo '<pre>'
for i in $APPL_FSS
do
 eval $DU $i/* | sort -rn 2>/dev/null
done
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><p><a id="lp"></a><h3>Printers</h3>' 
  echo '<pre>'
  eval $LP
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="pkg"></a><h3>SW Packages</h3>' 
  echo '<pre>'
  eval $PKG 
  eval $REPO
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="license"></a><h3>Licenses</h3>' 
  echo '<pre>'
  eval $LICENSE 
  which vxlicrep > /dev/null 2> /dev/null
  RES=$?
  if [ $RES -eq 0 ]
  then
    echo '<p>'
    vxdctl license
    echo '<p>'
    # Very OLD (VxVM 3.2): 	/sbin/vxlicense -p
    vxlicrep
  fi
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="kern"></a><h3>Kernel Parameters</h3>' 
  echo '<pre>'
  eval $KERNEL 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="patch"></a><h3>Installed Patches</h3>' 
  echo '<pre>'
  eval $PATCH 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="boot"></a><H3>Boot scripts</h3>' 
  echo '<pre>'
  eval $KBOOT 
  echo '</pre><br><pre>'
  eval $BOOT 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="lboot"></a><H3>Last Boot</h3>' 
  eval $LBOOT | break_lines
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><p><a id="cluc"></a><H3>Cluster Configuration</h3>' 
  echo '<xmp>'
  eval $DET_CLU 
  echo '</xmp>'
  echo '<p><a href="#top">Go to the top</a>' 

fi

echo '<hr><p><a id="clu"></a><H3>Cluster Status</h3>' 
echo '<pre>'
eval $ETC_CLU 
echo '<br>'
eval $LOG_CLU 
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><a id="act"></a><H3>Activity Log</h3>' 
cat /etc/.sys_log.htm 2>/dev/null
echo '<p><a href="#top">Go to the top</a>' 

echo '<hr><a id="who"></a><H3>User Log</h3>' 
echo '<pre>'
eval $WHO 
echo '<br>'
eval $LASTB
echo '<br>'
eval $AUREP 
echo '</pre>'
echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><p><a id="sw_diag"></a><h3>SW Diagnostics</h3>' 
  echo '<pre>'
  eval $SW_DIAG 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
  
  echo '<hr><p><a id="hw_diag"></a><h3>HW Diagnostics</h3>' 
  echo '<pre>'
  eval $HW_DIAG
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
fi

  echo '<hr><a id="stat"></a><H2>System Status</h2>' 
  echo '<hr><p><a id="ssum"></a><h3>Status Summary</h3>' 
  echo '<H3>Process Count</H3>'
  if [ $SYSTYPE = Linux ] ; then
	  echo '<p>'
      # nlwp to check threads; jstack PID to check java threads
      ps -e -o user,vsz,rss,sz,size | tail $TAILFROM +2 | sort | \
    awk ' BEGIN {u=69;c=0;m=0;uu=0;mm=0;m2=0;m3=0;m4=0;mm2=0;mm3=0;mm4=0} { if ($1 != u) { if (u == 69) { print "User", "Count", "VirtualSize", "ResidentSize", "PhysicalSize", "WriteSize" } else { print u,c,m,m2,m3,m4; } u=$1;c=1;m=$2;m2=$3;m3=$4;m4=$5;mm=mm+$2;mm2=mm2+$3;mm3=mm3+$4;mm4=mm4+$5;uu=uu+1 } else { c=c+1; m=m+$2;mm=mm+$2;m2=m2+$3;mm2=mm2+$3;m3=m3+$4;m4=m4+$5;mm3=mm3+$4;mm4=mm4+$5;uu=uu+1 }  } END { print u,c,m,m2,m3,m4 ; printf "Total(MB) %.0f %.0f %.0f %.0f %.0f \n",uu,mm/1024,mm2/1024,mm3/1024,mm4/1024 }' | table_buildn
    else
     eval $PSL | tail $TAILFROM +2 | awk  ' { print $3 , $10  } '| sort | \
     awk ' BEGIN {u=69;c=0;m=0;uu=0;mm=0} { if ($1 != u) { if (u == 69) { print "User", "Count", "Memory" } else { print u,c,m; } u=$1; c=1; m=$2;mm=mm+$2;uu=uu+1 } else { c=c+1; m=m+$2;mm=mm+$2;uu=uu+1 }  } END { print u,c,m ; print "Total",uu,mm }' | table_buildn
  fi

  echo '<H3>Shared Memory Usage (Entries, Attach, Size)</H3>'
  if [ $SYSTYPE = Linux ] ; then
   ipcs -m |tail -n +4| grep -v "^$" | awk ' BEGIN {x=0; c=0; a=0; print "Count Attach Size Size(MB)" } {x=x+$5; a=a+$6; c=c+1} END {printf "%.0f %.0f %.0f %.0f\n", c, a, x, x/(1024*1024) } ' | table_buildn
  else
   ipcs -am | awk ' BEGIN {x=0; c=0; a=0} {x=x+$10; a=a+$9; c=c+1} END {print c, a, x } '
  fi
  echo '<H3>Semaphores Usage (Entries, Total)</H3>'
  if [ $SYSTYPE = Linux ] ; then
   ipcs -s |tail $TAILFROM +2| awk ' BEGIN {x=0; c=0} {x=x+$5; c=c+1} END {print c, x} '
  else
   ipcs -as | awk ' BEGIN {x=0; c=0} {x=x+$9; c=c+1} END {print c, x} '
  fi
  echo '<H3>TCP Activities</H3><pre>'
  if [ $SYSTYPE = HPUX -o $SYSTYPE = HP-UX ] ; then
   netstat -an | grep tcp | cut -b69-80 | sort | uniq -c
  elif [ $SYSTYPE = Solaris -o $SYSTYPE = SUN -o $SYSTYPE = SunOS ] ; then
   netstat -an -P tcp | awk ' { print $7 } ' | sort | uniq -c
  elif [ $SYSTYPE = Linux ] ; then
   netstat -an | grep tcp | awk ' { print $6 } ' | sort | uniq -c
  elif [ $SYSTYPE = AIX ] ; then
   netstat -an | grep tcp | cut -b68-80 | sort | uniq -c
  fi
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<hr><p><a id="procs"></a><H2>Processes</h2>' 
  echo '<XMP>'
  eval $PS | grep -v ux2htm
  echo '</XMP>'
  echo '<p><a href="#top">Go to the top</a>' 
  
  echo '<hr><p><a id="vmstat"></a><H2>System usage</h2>' 
  echo '<pre>'
  eval $VMSTAT 
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
  
  echo '<hr><p><a id="ipc"></a><H2>InterProcess Communication</h2>' 
  echo '<pre>'
  eval $IPC
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 
  
  echo '<hr><p><a id="neta"></a><H2>Network Activity</h2>' 
  echo '<pre>'
  eval $NETA
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

  echo '<hr><a id="servs"></a><H3>Services</h3>' 
  echo '<pre>'
  eval $SERVS | awk  ' { print $3 , $1 , $9 } ' | sort | uniq 2> /dev/null
  echo
  eval $SERVS2 
  echo '</pre>'

  echo '<hr><p><a id="cron"></a><H2>Cron</h2>' 
  echo '<pre>'
  eval $CRON_INFO
  echo '</pre>'
  echo '<p><a href="#top">Go to the top</a>' 

fi

echo '<hr><a id="optm"></a><H2>Optional modules</h2>' 

if [ $SUMMARY -eq 0 ] ; then
  echo '<br><H3>Active Plug-in</h3>' 
  for i in `ls ux2p.*.*.sh`
  do
      XX=`echo $i | awk -F. ' { print $3 } ' `
      echo $XX
  done
  echo '<p><a href="#top">Go to the top</a>' 
  echo '<p><hr>' 
fi

X=0
for i in `ls ux2p.*.*.sh`
do
    XX=`echo $i | awk -F. ' { print $3 } ' `
    echo ' <a id="Plugin'$X'"> </a>' 
    X=`expr $X + 1 `
    . ./$i
    echo '<p><a href="#top">Go to the top</a><p><hr>' 
done

echo '<hr><a id="opt"></a><H2>Generated Files</h2>' 
  for i in `ls -t *.htm | grep $MACHINE`
  do
      echo "<a href=" $i ">" $i "</a>, "
  done
  echo '<br>'
 
## END report
echo '<div><a href="#top" class="back-to-top">⬆ Back to index</a></div>'
echo '<hr><p><a id="LIC"><b>UX2HTML </b></a>- Unix Configuration Report in HTML format'
echo '<br>Copyright (C) 1995-2025 meob' 
echo '<br>Statistics generated on: '
date

echo '<p>'
echo '    This program is free software; you can redistribute it and/or modify'
echo '    it under the terms of the GNU General Public License as published by'
echo '    the Free Software Foundation; either version 3 of the License, or'
echo '    (at your option) any later version.'
echo '<br>'
echo '    This program is distributed in the hope that it will be useful,'
echo '    but WITHOUT ANY WARRANTY; without even the implied warranty of'
echo '    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'
echo '    <a href="http://www.gnu.org/licenses/gpl.txt">GNU General Pubblic License</a>'
echo '    for more details.'

echo '<p>'
echo 'Sources: <a href="https://github.com/meob/ux2html">GitHub</a>.' 

echo '<script src="util.js"></script>'
echo '</body>' 
echo '</html>' 

exit 0
