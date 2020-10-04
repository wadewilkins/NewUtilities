
docker build -t wade_wilkins_tomcat:latest .
ret_code=$?
if [ "$ret_code" -ne "0" ]; then
  echo "Docker build failed!"
  exit 1
fi

# By using a volume in the run command, we can save our crontab between runs.
# If we want to start over without manually (restful) deleting all tasks,
# we can remove the volume with "docker volume rm wade_wilkins_concur_volume"
#
docker run -d --mount source=wade_wilkins_concur_volume,target=/var/spool/cron/crontabs -p 5000:5000 wade_wilkins_tomcat:latest
docker ps

TEST=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_tomcat' | wc -l`
echo
echo $TEST
if [ "$TEST" -eq "0" ]; then
  echo "Failed to start"
  exit 1
fi

echo "Good startup"
exit 0

