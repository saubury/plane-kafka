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

### Prepare Database Files
You will need a database of _icao-to-aircraft_ mappings (in _icao-to-aircraft.json_) and a database of callsigns (_callsign-details.json_).  A sood source of data is https://openflights.org/data.html where you can find aircraft data suitable for your region

If you are ion a hutty, _icao-to-aircraft.json.sample_ and _callsign-details.json.sample_ provide you basic records to experiment


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
