
ID=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_tomcat'`
echo $ID
docker container stop $ID
docker container rm $ID

TEST=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_tomcat' | wc -l`
echo
echo $TEST
if [ "$TEST" -ne "0" ]; then
  echo "Shutdown failed.  Please clean up manually"
  echo "docker container stop {ID}"
  echo "docker container rm {ID"
  exit 1
fi

echo "Clean stop"
exit 0
