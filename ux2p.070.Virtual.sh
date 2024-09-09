# ux2p-XXX-Virtual
# by mail@meo.bogliolo.name (c)
#
# HTML Virtual Plugin
# Reports Virtual (host/guest) configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Apr 09 1.0.0       meo     First release
#  1 Jan 10 1.0.1       meo     A bit more infos
#  1 Apr 10 1.0.2       meo     Yet a bit more infos; (1.0.2b) bug fixing on Summary; (1.0.2c) Memory info; 
#				(1.0.2d) Xen guests, standalone execution; (1.0.2e) MS Hyper-V
#  1 Apr 11 1.0.3       meo     VMware 5; (1.0.3a) Xen vCPU assignments
#  1 Apr 14 1.0.4       meo     dmesg analisys
# 14 Feb 15 1.0.5       meo     Fixes
#  3 Sep 22 1.0.6       meo     No more egrep (deprecated since 2007 and with a warning in grep 3.8)

PL_VERSION=1.0.6
PL_DESCR="Virtual"

if [ ! -n "$SYSTYPE" ]
then
SYSTYPE=Linux
fi

if [ ! -n "$PS" ]
then
PS='ps -efa'
fi

echo '<P><A NAME="virtual"></A><H2>' $PL_DESCR '</h2>' 
 echo 'Plug-in version:' $PL_VERSION

if [ $SYSTYPE = Linux ]
then
### Plug-in code
V_KEY="vmware|kvm|xen|hyper|vmtool"
V_VMWGUEST="vmware-guestd|vmtoolsd"
V_VMWHOST="vmkload_app"
V_XENGUEST="xenwatch"
V_XENHOST="xend"
V_CITHOST="bin/xapi"
V_KVMHOST="vdsm"
V_KVMGUEST="QEMU|KVM"
V_KVMGUEST2="qemu-ga"
V_HVGUEST="hv_vmbus"
VMWH=n
XEWH=n
XEWG=n
BAREMETAL=y

## Report
echo '<PRE>'
echo '<b>Summary</b>'

eval $PS | grep -v grep | grep -E $V_VMWGUEST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo 'System seems to be a <b>VMware Guest</b>'
   BAREMETAL=n
fi

eval $PS | grep -v grep | grep -E $V_VMWHOST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo 'System seems to be a <b>VMware ESX Server</b> with guests: '
   ps -efaww | grep vmkload_app | grep vmx | wc -l
   echo '<br> Guests running:'
   ps -efaww | grep vmkload_app | grep vmx | awk ' { print $(NF) } '
   VMWH=y
   BAREMETAL=n
fi

eval $PS | grep -v grep | grep -E $V_XENGUEST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   BAREMETAL=n
   eval $PS | grep -v grep | grep -E $V_XENHOST > /dev/null
   RES2=$?
   if [ $RES2 -eq 0 ]
   then
      echo 'System seems to be a <b>Xen HOST</b> with guests: '
      ps -efaww | grep qemu-dm | grep -v grep | wc -l
      echo '<br> Guests running:'
      ps -efaww | grep qemu-dm | grep -v grep | awk ' { print $12 " " $14 } '
      XEWH=y
   else
      eval $PS | grep -v grep | grep -E $V_CITHOST > /dev/null
      RES2=$?
      if [ $RES2 -eq 0 ]
      then
         echo 'System seems to be a <b>Citrix XenServer HOST</b>'
         XEWH=y
      else   
         echo 'System seems to be a <b>Xen Guest</b>'
	 XEWG=y
      fi
   fi
fi

cat /proc/cpuinfo| grep 'model name'  | grep -E $V_KVMGUEST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo -n 'System seems to be a <b>KVM GUEST</b>'
   BAREMETAL=n
fi

eval $PS | grep -v grep | grep -E $V_KVMGUEST2 > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo -n 'System seems to be a <b>KVM GUEST</b>'
   BAREMETAL=n
fi

eval $PS | grep -v grep | grep -E $V_KVMHOST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo -n 'System seems to be a <b>KVM HOST</b> with guests: '
   eval $PS | grep qemu- | grep -v grep | grep -v tunctl | wc -l
   BAREMETAL=n
fi

eval $PS | grep -v grep | grep -E $V_HVGUEST > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo 'System seems to be a <b>Hyper-V Guest</b>'
   BAREMETAL=n
fi

dmesg | grep -i 'VBOX' > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
   echo 'System seems to be a <b>VirtualBox Guest</b>'
   BAREMETAL=n
fi

if [ $BAREMETAL = "y" ]
then
   echo -n 'System seems to be a <b>BARE METAL</b> host with no Virtualization '
fi

echo
echo '<br>'
echo '<b>OS Release</b>'
rpm -qa | grep release | grep -v notes 2> /dev/null

echo '<br>'
echo '<b>Processor</b>'
cat /proc/cpuinfo| grep -E 'model name|flags' | sort -r | uniq -c
echo 
cat /proc/cpuinfo| grep flags | grep -E 'vmx|svm' > /dev/null && echo 'Processor has Virtual Technology extentions'

echo '<br>'
echo '<b>Memory</b>'
free

# echo '<br>'
# echo '<b>Devices</b>'
# eval $HW_DEVICE | grep -i -E $V_KEY 2> /dev/null
# eval $HW_DISK | grep -i -E $V_KEY 2> /dev/null

echo '<br>'
echo '<b>Active processes</b>'
eval $PS | grep -E $V_KEY | grep -v grep | grep -v xenia

echo '<br>'
echo '<b>Packages</b>'
eval $PKG 2> /dev/null | grep -E $V_KEY

echo '</PRE>'

if [ $VMWH = "y" ]
then
	echo '<h2>VMware HOST Details</h2><br>'
	vmware -v
        echo '<p><b>Virtual Datafile</b><pre>'
        vdf -h
        echo '</pre><b>Datastores</b><pre>'
        ls -l /vmfs/volumes
        echo
        ls -l /vmfs/volumes/*
        echo
        du -sk /vmfs/volumes/*Data*/*
        echo '</pre><a href="$MACHINE.csv.htm">ESXTOP (performce data)</a><br>'
        esxtop -n 2 >  $MACHINE.csv.htm
        echo '<br><b>CPU and memory</b><pre>'
	cat /proc/vmware/cpuinfo
	echo 
	cat /proc/vmware/mem
        echo '</pre>'
        echo '<br><b>HW details</b><pre>'
        esxcfg-info -w
        echo '</pre>'
        echo '<br><b>Log</b><pre>'
	tail -100 /proc/vmware/log
        echo '</pre>'
	# For VMware support
	# vm-support
fi

if [ $XEWH = "y" ]
then
	echo '<h2>Dom0 Xen HOST Details</h2><pre>'
	xm info
	echo '</pre><p><b>Running Domains</b><pre>'
	xm list
	echo '</pre><p><b>CPU assignments</b><pre>'
        xm vcpu-list
	echo
	xenpm get-cpu-topology
	echo '</pre>'
	which virsh > /dev/null 2> /dev/null
	RES=$?
	if [ $RES -eq 0 ]
	then
		echo '<p><b>All Domains</b><pre>'
		virsh list --all
		echo '</pre><p><b>Dom0 infos</b><pre>'
		virsh dominfo Domain-0
		echo '</pre>'
	fi
	echo '<p><b>Mounts</b><pre>'
	du -sh /var/ovs/mount/* 2>/dev/null
	du -sh /OVS/*/* 2>/dev/null
	echo '</pre><p><b>Configuration Files</b><pre>'
        ls -l /etc/xen/*.cfg  2>/dev/null
        ls -l /etc/xen/*.conf 2>/dev/null
        ls -l /etc/xen/*.xml  2>/dev/null
	echo '</pre><p><b>Logs</b><pre>'
	xm dmesg
	echo; echo
	xm log | tail -100
	echo '</pre>'
fi

if [ $XEWG = "y" ]
then
	echo '<h2>DomU Xen Guest Details</h2><p>'
	echo '<p><b>Virtualization Mode: </b>'
        dmidecode | grep HVM >/dev/null 2>/dev/null
        RET=$?
        if [ $RET -eq 0 ]
          then
		echo 'Hardware Virtualized Guest'
		lsmod | grep xen  >/dev/null 2>/dev/null
	        RET2=$?
	        if [ $RET2 -eq 0 ]
	          then
			echo 'with Paravirtualized Drivers (HVMPV)'
		  else
			echo '(HVM)'
		fi
          else
		echo 'Paravirtualized Guest (PVM)'
        fi
	echo '<p><b>Kernel Modules</b><pre>'
	rpm -qa | grep kernel 2>/dev/null
	echo
	lsmod | grep xen
	echo '</pre><p><b>In Use Device Drivers</b><pre>'
	ls -l /sys/class/net/eth0/device/driver 2>/dev/null
        ethtool -i eth0
	echo
	ls -l /sys/block/hda/device/driver 2>/dev/null
	ls -l /sys/block/xvda/device/driver 2>/dev/null
        cat /proc/partitions
	echo '</pre><p><b>Boot Log</b><pre>'
	dmesg | grep -i 'xen|front'
	echo '</pre><p><b>Boot Configuration</b><pre>'
	grep -v ^# /boot/grub/grub.conf
	echo '</pre>'
fi

echo '<p><b>Kernel ring buffer messages related to virtualization</b><pre>'
dmesg | grep -i 'vmware|vmxnet' && echo "Found: VMware"
dmesg | grep -i 'qemu' && echo "Found: QEMU"
dmesg | grep -i 'kvm' && echo "Found: KVM"
dmesg | grep -i 'Virtual HD|Virtual CD' && echo "Found: VirtualPC"
dmesg | grep -i 'Xen virtual console' && echo "Found: Xen"
dmesg | grep -i 'VBOX' && echo "Found: VirtualBox"

dmesg | grep -i 'booting paravirtualized kernel on' && echo "Found: Paravirtualized Kernel"
echo '</pre>'

else
  echo "<br>Virtual Pluging available only on Linux<br>"
fi

