# Show Oracle Grid Infrastructure informations

srvctl config nodeapps 2>/dev/null
RET=$?

echo '--><pre>'
if [ $RET -eq 0 ]
then
  echo '<b>Oracle Clusterware</b>'
  echo
  echo 'Cluster Name:'
  cemutlo -n
  echo 'Cluster Nodes:'
  olsnodes -n
  echo
  srvctl config nodeapps 2>/dev/null
  srvctl status nodeapps 2>/dev/null
  echo
  srvctl config asm
  srvctl status asm
  echo
  srvctl status listener
  srvctl status scan_listener
  echo 'Databases:'
  srvctl config database
  for i in `srvctl config database` ; do echo $i; srvctl status database -d $i; srvctl getenv database -d $i;echo ; done
else
  echo '<b>Oracle Restart</b>'
  echo
  srvctl config asm
  srvctl status asm
  echo
  srvctl status listener
  echo 'Databases:'
  srvctl config database
  echo
  for i in `srvctl config database` ; do echo $i; srvctl status database -d $i; srvctl getenv database -d $i;echo ; done
fi

# crs_stat -t
crsctl status resource -t

echo '-->'
echo '</pre>'
