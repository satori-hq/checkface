#!/bin/sh

# run this after saving source code to rebuild and restart app
docker stop checkfaceapi
docker rm checkfaceapi
docker build -t checkfaceapi .
docker run -d -p 8080:8080 -p 8000:8000 --gpus all --name checkfaceapi checkfaceapi
docker ps -a