
ID=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_concur'`
echo $ID
docker container stop $ID
docker container rm $ID


