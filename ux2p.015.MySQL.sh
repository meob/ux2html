# ux2p-XXX-MySQL
# by mail@meo.bogliolo.name (c)
#
# HTML MySQL Plugin
# Reports MySQL configuration details
#
# Usage:
# called by ux2html.sh 
#
# Notes:
#  Uses SUMMARY, SYSTYPE, PS variables

# History:
#  1 Aug 06 1.0.0       meo     First release
#  1 Apr 10 1.0.1       meo     Detailed statistics too
#  1 Apr 11 1.0.2       meo     Configuration parameters too
#  1 Apr 18 1.0.3       meo     More info on mysqld process

PL_VERSION=1.0.3
PL_DESCR="MySQL DB"

echo '<P><A NAME="mysql"></A><H2>' $PL_DESCR '</h2>' 
 echo 'Plug-in version:' $PL_VERSION

## Plug-in code
PSS=
MY_VER="mysqladmin version --password=$PSS"

## Report
echo "<h4>Summary</h4>"
echo '<PRE>'
echo '<b>Version</b>'
eval $MY_VER  2> /dev/null

echo '<br>'
echo '<b>Databases</b>'
mysql --password=$PSS <<EOF  2> /dev/null | grep -v Database
show databases;
EOF

echo '<br>'
echo '<b>OS User</b>'
grep -i mysql /etc/passwd

echo '<br>'
echo '<b>Active processes</b>'
$PS | grep mysql | grep -v grep
ps -opid,vsz,rss,cmd -p $(pidof mysqld) 2>/dev/null

echo '<br>'
echo '<b>Software packages</b>'
eval $PKG | grep -i mysql 2> /dev/null
echo '</PRE>'

echo '<br>'
echo '<b>Database Statistics</b><br>'
$PS | grep -v grep | grep "mysqld" > /dev/null
RES=$?
if [ $RES -eq 0 ]
then
	sh my2html.sh 2> /dev/null
	echo '<ul>'
	for i in `ls *.33*.htm`
	do
    		echo ' <li> <a href="' $i '">' $i '</a>'
	done
	echo '</ul>'
	
	echo '<br>'
	echo '<b>Configuration Files</b>'	
	echo '<br><pre>'
	ls -l /etc/my.cnf /etc/mysql/my.cnf $HOME/mysql/my.cnf $HOME/mysql/.my.cnf /etc/my.cnf.d/custom.cnf 2> /dev/null
	echo '</pre><br>'

	echo '<br><b>Configuration Parameters</b><pre>'
	cat /etc/my.cnf  /etc/my.cnf.d/custom.cnf | grep -v ^# | grep -v ^$ 2>/dev/null

        echo '</pre><br><b>Log File</b><pre>'
        ls -l /var/lib/mysql/`hostname`.err /mydata*/mysql/`hostname`.err /var/log/mysqld.log /var/log/mariadb/mariadb.log 2>/dev/null
        echo '<br>'
        cat   /var/lib/mysql/`hostname`.err /mydata*/mysql/`hostname`.err /var/log/mysqld.log /var/log/mariadb/mariadb.log 2>/dev/null | tail -100
        echo '</pre>'
else
	echo "No MySQL service running"
fi

# echo '<br>'
# echo '<b>Recently accessed databases</b>'
# find /var/lib/mysql -amin -500 | grep MYD | awk -F / ' { print $5 } ' | sort -u 

echo '<p>'
