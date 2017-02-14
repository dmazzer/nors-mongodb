# NORS Project - MongoDB Server Container #

## Preparing Environment ##

Install Docker as instructed [here](https://docs.docker.com/engine/installation/linux/ubuntulinux/)

For Ubuntu 14.04:

```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates
$ sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```

Insert the above line in file `/etc/apt/sources.list.d/docker.list`:

```
deb https://apt.dockerproject.org/repo ubuntu-trusty main
```

Then:

```
$ sudo apt-get update
$ sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
$ sudo apt-get install docker-engine
$ sudo service docker start
```

### Building a Container ###

Clone the repository and build the container:

```
$ git clone https://github.com/dmazzer/nors-mongodb.git
$ cd nors-mongodb
$ docker build --rm -t nors-mongodb .
```

Create a directory to persist MongoDB storage files:

```
$ sudo mkdir -p /opt/nors/db
$ chown -R [user]:[user] /opt/nors/db
```

Run the container:

This command will start the mongodb server for the first time and will map the container port 27017 to host port 47017:

```
$ docker run --rm -ti --name=nors-mongodb -p 47017:27017 -v /opt/nors/db nors-mongodb
```

After the first time the container named as nors-mongodb was used, it can be started as a daemon with the command:

```
$ docker run -ti -d -p 47017:27017 -v /opt/nors/db:/data/db -v /opt/nors/configdb:/data/configdb nors-mongodb
```

If _-v_ flag is omitted the MongoDB database will be lost when the container is shutdown.

To test the container access mongodb-server from the host:

```
$ mongo localhost:47017
```

## References ##

[MongoDB Dockerfile for trusted automated Docker builds](https://github.com/dockerfile/mongodb)

[Creating a MongoDB Docker Container with an Attached Storage Volume](https://devops.profitbricks.com/tutorials/creating-a-mongodb-docker-container-with-an-attached-storage-volume/)

[Dockerizing MongoDB](https://docs.docker.com/engine/examples/mongodb/)

[Docker Official Image packaging for MongoDB](https://github.com/docker-library/mongo)

