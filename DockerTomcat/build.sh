#!/bin/bash
set -euo pipefail
cat my_password.txt | docker login --username wadewilkins --password-stdin
# Pull the wade_wilkins_tomcat version of the image, in order to
# populate the build cache:
docker pull wadewilkins/wade_wilkins_tomcat:tomcat-image || true
docker pull wadewilkins/wade_wilkins_tomcat:latest || true

# Build the os stage:
docker build --target tomcat-image \
       --cache-from=wadewilkins/wade_wilkins_tomcat:tomcat-stage \
       --tag wadewilkins/wade_wilkins_tomcat:tomcat-image .
docker push wadewilkins/wade_wilkins_tomcat:tomcat-image

# Build the runtime stage, using cached os stage:
cat my_password.txt | docker login --username wadewilkins --password-stdin
docker build --target runtime-image \
       --cache-from=wadewilkins/wade_wilkins_tomcat:tomcat-image \
       --cache-from=wadewilkins/wade_wilkins_tomcat:latest \
       --tag wadewilkins/wade_wilkins_tomcat:latest .

# Push the new versions:
docker push wadewilkins/wade_wilkins_tomcat:latest
