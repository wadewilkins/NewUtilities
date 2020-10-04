# Dockerfile - this is a comment. Delete me if you want.
#FROM python:2.7
FROM ubuntu:latest AS os-image
#FROM alpine:3.7
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN apt-get update && apt-get install -y \
    python3-pip \
    openjdk-11-jdk \
    curl \
    vim
RUN pip3 install -r requirements.txt
COPY entrypoint /entrypoint
RUN chmod +x /entrypoint

FROM os-image AS runtime-image 
#COPY --from=os-image /root/.local /root/.local
COPY app.py /app/app.py
RUN chmod +x /app/app.py
ENTRYPOINT ["/entrypoint"]
