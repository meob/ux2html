# ux2p-XXX-yum
# by mail@meobogliolo.name (c)
#
# syslog Plugin
# Reports syslog configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Jan 24 1.0.0       meo     First release

PL_VERSION=1.0.0
PL_DESCR="syslog configuration"

echo '<P><A NAME="syslog"></A><H2>' $PL_DESCR '</h2>' 
if [ $SUMMARY -eq 0 ] ; then
 echo 'Plug-in version:' $PL_VERSION
fi

SL_CONF=/etc/syslog.conf
ASL_CONF=/etc/asl.conf

# Plug-in code
if [ -f $SL_CONF ] ; then
    echo '<h3>Configuration file</h3><p>' 
    ls -l $SL_CONF
    echo '<pre>'
    grep -v "^#" $SL_CONF| grep -v "^$"
    echo '</pre>'

    if [ -f $ASL_CONF ] ; then
    echo '<h3>Additional Configuration file</h3><p>' 
    ls -l $ASL_CONF
    echo '<xmp>'
    grep -v "^#" $ASL_CONF| grep -v "^$"
    echo '</xmp>'
    fi

    echo '<h3>Related processes</h3>' 
    echo '<pre>'
    ps -efa | grep syslog | grep -v grep
    ps -efa | grep aslmanager | grep -v grep
    echo '</pre>'
else
    echo '<h3>sysconfig configuration not found</h3>' 
fi
