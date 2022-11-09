# Checkface (Facemash Core)

This is the image processing server used by Facely.

## Setup

- Follow the other `README.md`.
- Satori runs an instance of this repo on `g3s.xlarge` on AWS EC2 (username: momo@satori.art)
- https://aws.amazon.com/getting-started/hands-on/train-deep-learning-model-aws-ec2-containers/

## Local Development

```
ssh -i "checkface.pem" ubuntu@ec2-3-88-182-25.compute-1.amazonaws.com

// LIST PROCESSES
docker ps -a

// LOGS
docker logs -f --tail 1000 checkfaceapi

// UTILS
docker stop checkfaceapi
docker rm checkfaceapi
docker build -t checkfaceapi .
docker run -d -p 8080:8080 -p 8000:8000 --gpus all --name checkfaceapi checkfaceapi

// RUN SHELL IN RUNNING CONTAINER
docker exec -it checkfaceapi /bin/bash

// MONGODB
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl stop mongod
sudo systemctl restart mongod

ps aux | grep -i mongodb

curl -i --request GET 'http://localhost:8080/api/status'
curl --request GET 'http://localhost:8080/api/hashdata/?value=example' | python3 -m json.tool
curl --output /dev/null --request GET 'localhost:8080/api/morphframe/?from_value=unchi&to_value=unko&frame_num=25&linear=true'
```

### Compiling

Run `save.sh` when updating source. This will restart and rebuild Docker container with changes.

```
TESTS
    [] fails if NO pre-existing GUID in database

```
