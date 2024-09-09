# ux2p-XXX-SAR
# by mail@meo.bogliolo.name (c)
#
# HTML sar 
# Reports sar statistics
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Apr 12 1.0.0       meo     First release
#  1 Oct 15 1.0.1       meo     Fixed a bug in the sar list: ls -r ==> ls -t
#  1 Jan 17 1.0.2       meo	Minor changes to avoid an empty PRE section

PL_VERSION=1.0.2
PL_DESCR="SAR - System Activity Report"

echo '<P><A NAME="pl_sar"></A><H2>' $PL_DESCR '</h2>' 
 echo 'Plug-in version:' $PL_VERSION

## Plug-in code
SA_DIR=/var/log/sa
if [ "X$SYSTYPE" = "XSunOS" ]
   then
	SA_DIR=/var/adm/sa
fi
SA_PARAM="-u"
SA_DAYS=7

## Report
if [ -d $SA_DIR ]
then
  which sar >/dev/null 2>/dev/null
  RES=$?
  if [ $RES -eq 0 ]
  then
    echo '<P><a id="pl_sarh"></a><H3>Sar daily Reports</H3>'
    ( cd $SA_DIR ; for i in `ls -t | grep -v sar | head -$SA_DAYS` ; do echo "<p>$i<pre>"; sar $SA_PARAM -f $i; echo "</pre>"; done )
    echo '<p>'
  else
    echo '<p>sar command not available.<p>'
  fi
else
  echo '<p>sar history not available.<p>'
fi
