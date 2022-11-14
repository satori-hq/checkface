# Checkface (Facely Core)

This is the image processing server used by Facely.

## Setup

- Follow the other `README.md`. Note the sections about MongoDB and Image Encoding.
- Satori runs an instance of this repo on `g3s.xlarge` on AWS EC2 (username: momo@satori.art)
- https://aws.amazon.com/getting-started/hands-on/train-deep-learning-model-aws-ec2-containers/

## Connect to EC2 instance

```
ssh -i "checkface.pem" ubuntu@ec2-3-88-182-25.compute-1.amazonaws.com
```

## Run app using Docker

Refer to the `docker-compose.yml` (This is a reference file only since docker-compose does not work with nvidia GPUs).

Services run in separate containers so that checkface crashing doesn't boink the DB.

1. `checkfaceapi`
2. `db`

```
// LIST PROCESSES
docker ps -a

// LOGS
docker logs -f --tail 1000 checkfaceapi
docker logs -f --tail 1000 flask_mongodb_dockerized_app_app_1

// UTILS
docker stop checkfaceapi
docker rm checkfaceapi
docker build -t checkfaceapi .
docker run -d -p 8080:8080 -p 8000:8000 --gpus all --network=bridge --links db --name checkfaceapi checkfaceapi

// RUN SHELL IN RUNNING CONTAINER
docker exec -it checkfaceapi /bin/bash

// MONGODB
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl stop mongod
sudo systemctl restart mongod

ps aux | grep -i mongodb

// DOCKER NETWORK
docker network ls
docker network inspect bridge
docker network disconnect bridge flasktest_app_1
docker network connect --link flask_mongodb_dockerized_app_db_1 bridge flasktest_app_1


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

### Architecture

```
CONTAINER ID   IMAGE                              COMMAND                  CREATED          STATUS          PORTS                                                   NAMES
=======================================================================================================================================================================================================
f6cecce9520e   checkfaceapi                       "python checkface.py"    19 minutes ago   Up 19 minutes   0.0.0.0:8000->8000/tcp, :::8000->8000/tcp,
                                                                                                            0.0.0.0:8080->8080/tcp, :::8080->8080/tcp               checkfaceapi
====================================================================================================================================================================================================

@app.route('/api/encodeimage/', methods=['POST'])

    # Takes {image file, tryAlign}

    # Cache encoding requests by a hash of the image file and value of tryAlign
        requestKey =        encodeRequestKey(imgFile, tryAlign)
        existingRecord =    getEncodedImagesRecord(requestKey)
                            return db.encodedimages.find_one({'_id': requestKey})

        # IF existing record return it

    # Send encoding request to encoder4editing API
        resp =              requests.post("http://encoderapi:8080/api/encodeimage/", files={ 'usrimg': imgFile }, data={ 'tryalign': tryAlign })
        latentArray =       respData['dlatent']
        didAlign =          respData['did_align']

    # Register latent
        (didSucceed, msg) = registerLatent(latentArray)
                                latent_data =   np.array(latentArray).astype('float32', casting='same_kind')
                                latent_type =   latent_data.shape == (512,)     ? 'qlatent'
                                                latent_data.shape == (18, 512)  ? 'dlatent'
                                guid =          uuid.uuid4()

                                db.latents.insert_one({
                                                        '_id':      str(guid),
                                                        'type':     latent_type,
                                                        'latent':   latent_data.tolist()
                                                    })
                                return (True, str(guid))

        if didSucceed:
            guid =          msg
            setEncodedImagesRecord(requestKey, guid, didAlign)
                db.encodedimages.insert_one({
                                                '_id':          requestKey,
                                                'guid':         guid,
                                                'did_align':    didAlign
                                            })
            return flask.jsonify({ 'guid': guid, 'did_align': didAlign })
        else:
            return flask.Response(msg, status=400)


=======================================================================================================================================================================================================
6b779907d432   flask_mongodb_dockerized_app_app   "python -u app.py"       39 minutes ago   Up 11 seconds   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp               flask_mongodb_dockerized_app_app_1
=======================================================================================================================================================================================================

@app.route('/api/encodeimage/', methods=['POST'])
    // LOOK AT



=======================================================================================================================================================================================================
9362ea1211f6   mongo:latest                       "docker-entrypoint.s…"   39 minutes ago   Up 11 seconds   0.0.0.0:27017->27017/tcp, :::27017->27017/tcp           flask_mongodb_dockerized_app_db_1
=======================================================================================================================================================================================================

encodedimages
    {
        _id: requestKey,
        guid: guid,
        did_align: didAlign,
    }

latents
    {
        '_id': guid,
        'type': latent_type,
        'latent':latent_data.tolist()
    }
```

```
[
    {
        "Name": "bridge",
        "Id": "007db86ae83e77cecc664f0891fc22f7eab2abf55245d44321fc57ea15992972",
        "Created": "2022-11-10T15:02:20.387366478Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "00a045009b54fbc4e641d4677e0d9d5cbcc7ae9303a1eed958ec3388ee396bc6": {
                "Name": "flask_mongodb_dockerized_app_db_1",
                "EndpointID": "f6e5299e6d1e08ce58b0b42f98539f2b5ecfac0a5e351c0166390815be64911a",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            },
            "1997550db6428c25a9954e85728a04799bb8b69e2a4b65f69fc219149c11eb63": {
                "Name": "flask_mongodb_dockerized_app_app_1",
                "EndpointID": "cd338736c7de84b3c998a3804c19865379f77ef91624831aae060cee226b0ace",
                "MacAddress": "02:42:ac:11:00:03",
                "IPv4Address": "172.17.0.3/16",
                "IPv6Address": ""
            },
            "3507ba33adab5b4d5a4df809f6c6329e0ec010caf688d02f5dec8618f5bde6da": {
                "Name": "checkfaceapi",
                "EndpointID": "2ddd7cd67d47cc6d3ecffa49b553b699293e2723f697cf757a60afe77a93a04e",
                "MacAddress": "02:42:ac:11:00:04",
                "IPv4Address": "172.17.0.4/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```
