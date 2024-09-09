# ux2p-XXX-SAR1d
# by mail@meo.bogliolo.name (c)
#
# HTML sar 1 day
# Reports sar one day full statistics
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Apr 15 1.0.0       meo     First release

PL_VERSION=1.0.0
PL_DESCR="SAR1d - 1 Day System Activity Report"

echo '<P><A NAME="pl_sar1d"></A><H2>' $PL_DESCR '</h2>' 
 echo 'Plug-in version:' $PL_VERSION

## Plug-in code
SA_PARAM="-A"


## Report
  which sar >/dev/null 2>/dev/null
  RES=$?
  if [ $RES -eq 0 ]
  then
    echo '<P><a id="pl_sar1dA"></a><H3>Sar Report</H3><pre>'
    sar $SA_PARAM
    echo '</pre><p>'
  else
    echo '<p>sar command not available.<p>'
  fi
