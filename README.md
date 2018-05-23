# Plane Kafka - Plane tracking with KSQL and a Raspberry Pi

![Arch](/docs/plane-kafka-01.png)

### Raspberry Pi Setup
Install dump1090 (instructions here) and clone this repo.
```
cd raspberry-pi
export HOST_IP=192.168.1.129 # Docker host
./plane-kafka.py
```

### Docker Setup
```
docker-compose up -d
```

### Login

```
docker-compose exec confluent bash
```

And within the container
```
confluent start
cd /scripts
./01_setup_topics
./02_do_load
```

And then run ksql

```
ksql
run script '03_ksql.sql';
exit
```

Still within the container finish the remaining setup steps
```
./04_elastic_dynamic_template
./05_set_connect
```
