#!/bin/bash
set -euo pipefail
cat my_password.txt | docker login --username wadewilkins --password-stdin
# Pull the wade_wilkins_donk version of the image, in order to
# populate the build cache:
docker pull wadewilkins/wade_wilkins_donk:os-image || true
docker pull wadewilkins/wade_wilkins_donk:latest || true

# Build the os stage:
#docker build --target os-image \
#       --cache-from=wadewilkins/wade_wilkins_donk:os-stage \
#       --tag wadewilkins/wade_wilkins_donk:os-image .
#docker push wadewilkins/wade_wilkins_donk:os-image

# Build the runtime stage, using cached os stage:
cat my_password.txt | docker login --username wadewilkins --password-stdin
docker build --target runtime-image \
       --cache-from=wadewilkins/wade_wilkins_donk:os-image \
       --cache-from=wadewilkins/wade_wilkins_donk:latest \
       --tag wadewilkins/wade_wilkins_donk:latest .

# Push the new versions:
docker push wadewilkins/wade_wilkins_donk:latest
