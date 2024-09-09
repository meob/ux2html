# ux2p-XXX-ISCSI
# by mail@meo.bogliolo.name (c)
#
# HTML iSCSI Plugin
# Reports iSCSI configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Apr 20 1.0.0       meo     First release


PL_VERSION=1.0.0
PL_DESCR="iSCSI"

if [ ! -n "$SYSTYPE" ]
then
SYSTYPE=Linux
fi

if [ ! -n "$PS" ]
then
PS='ps -efa'
fi

echo '<P><A NAME="iscsi"></A><H2>' $PL_DESCR '</h2>' 
 echo 'Plug-in version:' $PL_VERSION

if [ $SYSTYPE = Linux ]
then
V_KEY=iscsi


## Report
echo '<pre>'
echo '<b>Configuration</b>'
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg /etc/netplan/50-cloud-init.yaml

ls -l /etc/iscsi/initiatorname.iscsi  /etc/iscsi/iscsid.conf
echo
cat /etc/iscsi/initiatorname.iscsi | grep -v "^#" | grep -v "^$"
echo
cat /etc/iscsi/iscsid.conf | grep -v "^#" | grep -v "^$"

echo '<b>iQN code</b>'
iscsi-iname

echo '<br>'
echo '<b>Sessions</b>'
iscsiadm -m session 

echo '<br>'
echo '<b>Processes</b>'
$PS | grep iscsi 

echo '<br>'
echo '<b>Packages</b>'
eval $PKG 2> /dev/null | grep -E $V_KEY

echo '<br>'
echo '<b>Sessions details</b>'
iscsiadm -m session -P3
# iscsiadm -m discovery -o show

echo '</pre>'

else
  echo "<br>iSCSI Pluging available only on Linux<br>"
fi