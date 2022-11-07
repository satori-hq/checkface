# Checkface (Facemash Core)

This is the image processing server used by Facely.

## Setup

- Follow the other README.md.
- Satori runs an instance of this repo on `g3s.xlarge` on AWS EC2 (username: momo@satori.art)
- https://aws.amazon.com/getting-started/hands-on/train-deep-learning-model-aws-ec2-containers/

## Development

- SSH into EC2 `ssh -i "checkface.pem" ubuntu@ec2-3-88-182-25.compute-1.amazonaws.com`
- Run `save.sh` when updating source

```
// HELPFUL COMMANDS
docker ps -a
docker logs -f --tail 100 checkfaceapi
docker exec -it checkfaceapi /bin/bash

docker stop checkfaceapi
docker rm checkfaceapi
docker build -t checkfaceapi .
docker run -d -p 8080:8080 -p 8000:8000 --gpus all --name checkfaceapi checkfaceapi

curl -i --request GET 'http://localhost:8080/api/status'
curl --request GET 'http://localhost:8080/api/hashdata/?value=example' | python3 -m json.tool
curl --output /dev/null --request GET 'localhost:8080/api/morphframe/?from_value=unchi&to_value=unko&frame_num=25&linear=true'

TESTS
    [] fails if NO pre-existing GUID in database

```
