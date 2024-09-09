# ux2p-XXX-OracleDetails
# by mail@meo.bogliolo.name (c)
#
# HTML Oracle Plugin
# Reports Oracle configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:
# 	The only requirement is that the user executing oracle (the pmon process) has
#	the right setup on login to connect to Oracle RDBMS
#	OracleDetails uses the terrific Meo's ora2html Oracle reporting script 

# History:
#   1 Apr 08 1.0.0       meo     First release based on Oracle.010 plugin
#   1 Apr 09 1.0.1       meo     opatch
#   1 Apr 09 1.0.2       meo     standalone version, better security, bug fixing
#  25 Apr 09 1.0.3       meo     AIX, csh dirty trick, HP-UX trick
#  31 Jun 09 1.0.4       meo     Listeners' list
#  31 Jun 09 1.0.5       meo     LOGs; (a) Exadata patch; (b) Oracle XE Patch; (c,d) bug fixing;
#                                (e) APX, multiple ORACLE_HOME (f) multiple oratab (g) rac/grid fixes
#   3 Sep 22 1.0.6       meo     No more egrep (deprecated since 2007 and with a warning in grep 3.8)

PL_VERSION=1.0.6
PL_DESCR="Oracle RDBMS Details"

OERRLEN=100
ORA_ASM=asm2html.sql
ORA_CMD=ora2html.sql

#ORA_CMD=ora2fast.sql
#ORA_CMD=dg2html.sql
# Common Oracle Grid usernames are grid, oragrid, ...
GRID_USER=grid

OPATCH_PARAM='-invPtrLoc $ORACLE_HOME/oraInst.loc'
OPATCH_CMD='$ORACLE_HOME/OPatch/opatch'
SYSTYPE=`uname -s`
EGREP=grep
if [ $SYSTYPE = HPUX -o $SYSTYPE = HP-UX ]
then
   export UNIX95=
   EGREP="grep -E"
fi
PSCMD='ps -e -o user=VeryLongUserNames -o args'
if [ $SYSTYPE = Cygwin ]
then
   PSCMD='ps -lW '
fi
OHOME='cd $ORACLE_HOME'
export OHOME
if [ -z "$INST_DIR" ]
then
   INST_DIR=/usr/local/amm
   export INST_DIR
fi

USR1=none
FIRSTTIME=yes
echo '<P><A NAME="oradet"></A><H2>' $PL_DESCR '</h2>' 
echo 'Plug-in version:' $PL_VERSION
echo '<p>Contents: <a href="#ora_tab">oratab</a>, <a href="#ora_ins">Instances</a>, <a href="#ora_lis">Listeners</a>,'
echo ' <a href="#ora_grid">Grid</a>, <a href="#ora_pat">Patches</a>,'
echo ' <a href="#ora_log">Logs</a>, <a href="#ora_asm">ASMlib</a>'
echo '<p><p><a id="ora_tab"></a>oratab:<pre>'
grep -v ^$ /etc/oratab 2>/dev/null | grep -v ^# 2>/dev/null
echo
grep -v ^$ /var/opt/oracle/oratab 2>/dev/null | grep -v ^# 2>/dev/null
echo '</pre><p><a id="ora_ins"></a>Oracle Instances (SID):<ul><li>'

chmod o+xr $INST_DIR

for INST in `$PSCMD | grep pmon | grep -v grep | grep -v exadata_mon | grep -v awk | grep -v FNDLIBR | \
    awk ' { printf("%s:%s\n", $1, substr($2,index($2,"pmon")+5) ) }' | sort `
do
 USR=`echo $INST | awk -F: ' { print $1 }' `
 SID=`echo $INST | awk -F: ' { print $2 }' `
 # ORH=`grep ^$SID: /etc/oratab | awk -F: ' { print $2 }' | head -1`
 SIDR=`echo $INST | awk -F: ' { print $2 }' | tr -d '12'`
 ORH=`grep ^$SIDR /etc/oratab | awk -F: ' { print $2 }' | head -1`

if [ $USR != root ]
  then
 echo "<a href="`uname -n`.$SID.htm">" $SID "</a> ; " "<!--"
 touch `uname -n`.$SID.htm
 chmod 777 `uname -n`.$SID.htm
 touch ora2html.htm
 chmod 777 ora2html.htm
 if [ "$(echo "$SID" | cut -c1-4)" = "+ASM" ]
  then
    ORA_CMM=$ORA_ASM
  else
    ORA_CMM=$ORA_CMD
 fi
 if [ "$(echo "$SID" | cut -c1-4)" = "+APX" ]
  then
    ORA_CMM=$ORA_ASM
 fi

# Use "su ..." if "su - ..." hangs. 
 su - $USR <<EOF
cd $INST_DIR
# Setting SID and Oracle Home
ORACLE_SID=$SID
export ORACLE_SID
setenv ORACLE_SID $SID
### Uncomment the following line to use /etc/oratab
### ORACLE_HOME=$ORH
##### Uncomment the following lines if You want to use a custom ORACLE_HOME
#####   ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1
#####   PATH=$PATH:/u01/app/oracle/product/12.1.0.2/dbhome_1/bin
export ORACLE_HOME
setenv ORACLE_HOME $OHOME

# echo DEBUG:  home $ORACLE_HOME instdir $INST_DIR usr $USR sid $SID

touch ora2html.htm
sqlplus -s '/ as sysdba' < $ORA_CMM > /dev/null
cp ora2html.htm `uname -n`.$SID.htm
touch ora2html.htm
EOF
echo "-->"
chmod 644 `uname -n`.$SID.htm
fi

done
echo '</ul>'
rm ora2html.htm

echo '<p><a id="ora_lis"></a>Oracle Listeners:<ul>'
for INST in `$PSCMD | grep tnslsnr | grep -v grep | \
    awk ' { printf("%s:%s\n", $1, $3 ) }' | sort `
do
 USR=`echo $INST | awk -F: ' { print $1 }' `
 SID=`echo $INST | awk -F: ' { print $2 }' `
 echo "<!--"
    su - $USR << EOF
echo "--><li>User:" $USR " Listener: " $SID "<pre>"
lsnrctl status $SID | $EGREP "DESCRIPTION|handler" | uniq
echo "</pre>"
eval $OHOME
echo "<b>"; ls -l network/admin/listener.ora ; echo "</b><pre>"
cat network/admin/listener.ora
echo "</pre>"
echo "<b>"; ls -l network/admin/tnsnames.ora ; echo "</b><pre>"
cat network/admin/tnsnames.ora
echo "</pre>"
echo "<b>"; ls -l network/admin/sqlnet.ora ; echo "</b><pre>"
cat network/admin/sqlnet.ora
echo "</pre>"
EOF
done

echo '</ul><p>'
$PSCMD|grep -v grep|grep grid|grep ohasd.bin >/dev/null
RET=$?
if [ $RET -eq 0 ]
 then
 echo '<a id="ora_grid"></a>Grid Infrastructure:<!--'
 su - $GRID_USER < $INST_DIR/grid.sh
fi

FIRSTTIME=yes
echo '<a id="ora_pat"></a>Oracle Patches:<ul>'

for INST in `$PSCMD | grep pmon | grep -v grep | grep -v exadata_mon | grep -v awk | grep -v FNDLIBR | \
    awk ' { printf("%s:%s\n", $1, substr($2,index($2,"pmon")+5) ) }' | sort `
do
 USR=`echo $INST | awk -F: ' { print $1 }' `
 SID=`echo $INST | awk -F: ' { print $2 }' `

 if [ $USR != $USR1 ]
  then
    if [ $FIRSTTIME = yes ]
      then
	FIRSTTIME=no
        echo "<li>" User: $USR  "<!--"
      else
        echo "</ul><p><li>" User: $USR  "<!--"
    fi
    su - $USR << EOF
echo '--><ul><PRE>'
eval $OPATCH_CMD lsinventory $OPATCH_PARAM  | grep -v '^$'
echo '</PRE>'
EOF
 USR1=$USR
 fi

 echo "<li>" SID: "<a href="`uname -n`.$SID.htm">" $SID "</a>"
done

USR1=none
echo '</ul><p><a id="ora_log"></a>Oracle Logs:<ul>'

for INST in `$PSCMD | grep pmon | grep -v grep | grep -v exadata_mon | grep -v awk | grep -v FNDLIBR | \
    awk ' { printf("%s:%s\n", $1, substr($2,index($2,"pmon")+5) ) }' | sort `
do
 USR=`echo $INST | awk -F: ' { print $1 }' `
 SID=`echo $INST | awk -F: ' { print $2 }' `

 if [ $USR != $USR1 ]
  then
        echo "<li>" User: $USR  "<!--"
    su - $USR << EOF
echo '--><ul>'
eval $OHOME
find . -name 'listener*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null
find . -name 'alert*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null
# OFA
find ../../admin -name 'alert*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null
# 11g
find ../../diag -name 'alert*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null
# ORA-600 
find ../../diag -name 'alert*.log' -exec echo "<pre>" \; -exec grep -B 3 -A 2 ORA-00600 {} \; -exec echo "</pre>" \; 2>/dev/null
# Other common locations for alert.log
find ../../../diag -name 'alert*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null
find ../../../grid/diag -name 'alert*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$OERRLEN {} \; -exec echo "</pre>" \; 2>/dev/null

EOF
echo '</ul>'
 fi
USR1=$USR
done

echo '</ul><p></ul><a id="ora_asm"></a>'
oracleasm -V > /dev/null 2>/dev/null
TEST=$?
if [ $TEST -eq 0 ]
then
  echo '<h2>Oracle ASMlib</h2>'
  echo "<pre>"
  oracleasm -V
  oracleasm status
  echo; echo "Devices (/dev/oracleasm/disks):"
  ls -l /dev/oracleasm/disks
  echo; echo "Disk list:"
  oracleasm listdisks
  echo; echo "Disk devices (paths):"
  oracleasm listdisks | xargs oracleasm querydisk -p
  echo; echo "Disk devices (devices):"
  oracleasm listdisks | xargs oracleasm querydisk -d
  echo "</pre>"
else
  echo '<h3>Oracle ASMlib not found</h3>'
fi

echo '<p>'
chmod o-xr $INST_DIR

