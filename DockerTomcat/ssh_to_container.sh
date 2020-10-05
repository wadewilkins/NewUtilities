
ID=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_tomcat'`
echo $ID
docker exec -it $ID  /bin/bash


