# ux2p-XXX-PostgreSQL
# by mail@meo.bogliolo.name (c)
#
# HTML PostgreSQL Plugin
# Reports PostgreSQL configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:

# History:
#  1 Apr 08 1.0.0       meo     First release
# 31 Apr 11 1.0.1       meo     Collect statistics for all Databases
# 31 Jun 11 1.0.2	meo	-w option fix for old PostgreSQL version
# 31 Sep 11 1.0.3	meo	Most intresting info on the top
#  1 Jan 12 1.0.4	meo	Port number parameter
#  1 Jan 14 1.0.5	meo	Show Port number in output files, PostGIS
# 14 Feb 18 1.0.6	meo	Postgres 10 uses different process names and directories (a) Debian/Ubuntu use title
#  3 Sep 22 1.0.7       meo     No more egrep (deprecated since 2007 and with a warning in grep 3.8)

PL_VERSION=1.0.7
PL_DESCR="PostgreSQL"

echo '<P><A NAME="postgres"></A><H2>' $PL_DESCR '</h2>' 
if [ $SUMMARY -eq 0 ] ; then
 echo 'Plug-in version:' $PL_VERSION
fi

## Plug-in code
POST_USR=postgres
POST_PORT=5432
PG_CMD=pg2html.sql
PGIS_CMD=pgis2html.sql
SYSTYPE=`uname -s`
EGREP=grep
DBNAME=postgres
LOGMSG=30
NOPASS=-w
PGHOME='cd $PGDATA'
export PGHOME

echo | psql -w 2> /dev/null
RES=$?
	if [ ! $RES -eq 0 ]
 	then
	    NOPASS=
	fi
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
if [ -z "$INST_DIR" ]
then
   INST_DIR=/usr/local/amm
   export INST_DIR
fi

	
## Report
USR1=none
FIRSTTIME=yes
chmod o+xwr $INST_DIR

echo '<h3>Owner</h3>'

for INST in `$PSCMD | grep "postgres:" | grep  "checkpointer" | grep -v grep | \
    awk ' { printf("%s:%s\n", $1, substr($2,10,20) ) }' | sort | uniq`
do
 USR=`echo $INST | awk -F: ' { print $1 }' `

 echo "Database Cluster Owner: " $USR "<p> " "<!"
 touch `uname -n`.$USR.$POST_PORT.postgres.htm
 chmod 777 `uname -n`.$USR.$POST_PORT.postgres.htm
 touch pg.htm
 chmod 777 pg.htm
 cat /dev/null > pg.htm
 touch pg.dbs
 chmod 777 pg.dbs


 su - $USR <<EOF
  cd $INST_DIR
  psql $NOPASS $DBNAME -p $POST_PORT < $PG_CMD > /dev/null
  cp pg.htm `uname -n`.$USR.$POST_PORT.postgres.htm
  touch pg.htm

  psql --quiet --no-align --tuples-only $NOPASS $DBNAME -p $POST_PORT --command="SELECT datname FROM pg_database WHERE datistemplate IS FALSE AND datallowconn IS TRUE AND datname!='postgres';" > pg.dbs

  echo ">"
EOF
touch pg.dbs
chmod 777 pg.dbs

echo "<h4>Database Statistics</h4>"
echo "<a href="`uname -n`.$USR.$POST_PORT.postgres.htm">" postgres "</a> "
while read myline
  do
     echo "<br><a href="`uname -n`.$USR.$POST_PORT.$myline.htm">" $myline "</a> "
     touch `uname -n`.$USR.$POST_PORT.$myline.htm
     chmod 777 `uname -n`.$USR.$POST_PORT.$myline.htm
     touch pg.htm
     chmod 777 pg.htm
     cat /dev/null > pg.htm
     touch pgis.htm
     chmod 777 pgis.htm
     cat /dev/null > pgis.htm

     su - $USR <<EOF
         cd $INST_DIR
         psql $NOPASS $myline -p $POST_PORT < $PG_CMD > /dev/null
         cp pg.htm `uname -n`.$USR.$POST_PORT.$myline.htm
         grep 'PostGIS installed' pg.htm>/dev/null && psql $NOPASS $myline -p $POST_PORT < $PGIS_CMD > /dev/null && cp pgis.htm `uname -n`.$USR.$POST_PORT.$myline.PostGIS.htm && echo " (<a href=`uname -n`.$USR.$POST_PORT.$myline.PostGIS.htm>PostGIS</a>) "
EOF
  done < pg.dbs

 su - $USR <<EOF
  cd
  eval $PGHOME
  echo "<h4>Configuration files</h4>"
  pwd > $INST_DIR/pg.home
  echo "PGHOME= " 
  cat $INST_DIR/pg.home
  echo "<p>"
  find . -name 'postgresql.conf' -exec echo "<br><b>" {} "</b><pre>" \; -exec sh -c 'grep ^[a-z] {} | tr "<>" "--"' \; -exec echo "</pre>" \; 
  find . -name 'pg_hba.conf' -exec echo "<br><b>" {} "</b><pre>" \; -exec grep ^[a-z] {} \; -exec echo "</pre>" \;
  find . -name 'recovery.conf' -exec echo "<br><b>" {} "</b><pre>" \; -exec grep ^[a-z] {} \; -exec echo "</pre>" \;
# find . -name '*.log' -exec echo "<li><b>" {} "</b><pre>" \; -exec tail -$LOGMSG {} \; -exec echo "</pre>" \;
  echo "<br><b>WAL</b><pre>"
  ls -l pg_xlog pg_wal 2>/dev/null
  echo "</pre>"
EOF

done

echo "<h4>Summary</h4>"
echo '<PRE>'
echo '<b>Users</b>'
grep -i $POST_USR /etc/passwd

echo '<br>'
echo '<b>Processes</b>'
$PSCMD | grep $POST_USR | grep -v grep

echo '<br>'
echo '<b>Active sessions</b>'
$PSCMD | grep $POST_USR | grep -E 'SEL|UPD|INS|DEL|CAL|BLO|DO|in transaction' | grep -v grep

echo '<br>'
echo '<b>Shared memory</b>'
ipcs -a | grep $POST_USR 

echo '<br>'
echo '<b>Software packages</b>'
eval $PKG | grep -i postgres 2> /dev/null
eval $PKG | grep -i edb 2> /dev/null
eval $PKG | grep -i postgis 2> /dev/null

UX2PG=`cat pg.home`
echo '<br>'
echo '<b>DB Server Logs</b>'
ls -ltr $UX2PG/pg_log $UX2PG/log | tail -$LOGMSG

echo '<br>'
echo '<b>Last Log excerpt</b>'
tail -$LOGMSG $UX2PG/log/`ls -tr $UX2PG/log | tail -1`

echo '<br>'
echo '<b>Last Errors</b>'
grep -E 'ERROR|FATAL' $UX2PG/log/`ls -tr $UX2PG/log | tail -1`

echo '<br>'
echo '<b>Write-Ahead Logs</b>'
ls -ltr $UX2PG/pg_xlog $UX2PG/pg_wal | tail -$LOGMSG

echo '</PRE>'

rm pg.dbs pg.htm pgis.htm pg.home 2> /dev/null
chmod o-xwr $INST_DIR
