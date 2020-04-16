#!/bin/bash
set -euo pipefail
cat my_password.txt | docker login --username wadewilkins --password-stdin
# Pull the wade_wilkins_concur version of the image, in order to
# populate the build cache:
docker pull wadewilkins/wade_wilkins_concur:os-image || true
docker pull wadewilkins/wade_wilkins_concur:latest || true

# Build the os stage:
#docker build --target os-image \
#       --cache-from=wadewilkins/wade_wilkins_concur:os-stage \
#       --tag wadewilkins/wade_wilkins_concur:os-image .
#docker push wadewilkins/wade_wilkins_concur:os-image

# Build the runtime stage, using cached os stage:
cat my_password.txt | docker login --username wadewilkins --password-stdin
docker build --target runtime-image \
       --cache-from=wadewilkins/wade_wilkins_concur:os-image \
       --cache-from=wadewilkins/wade_wilkins_concur:latest \
       --tag wadewilkins/wade_wilkins_concur:latest .

# Push the new versions:
docker push wadewilkins/wade_wilkins_concur:latest
