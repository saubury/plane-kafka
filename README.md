# Plane Kafka - Plane tracking with KSQL and a Raspberry Pi

![Arch](/docs/plane-kafka-01.png)

### Raspberry Pi Setup
- If you don't have a Raspberry Pi you can skip to _Docker Setup_ and use the sample data
- Clone this repo on the Raspberry Pi
- [Install dump1090](https://www.rtl-sdr.com/adsb-aircraft-radar-with-rtl-sdr)  
- Set the IP address below to the _docker host_ (and not the IP address of the Raspberry Pi).  This is where you'll transmit the messages to Kafka

```
# On the Raspberry Pi 
cd raspberry-pi
export HOST_IP=192.168.1.129 # Docker host
./plane-kafka.py
```

### Docker Setup
On your _host_ (probably your laptop or PC). Clone this repo
```
# Start the containers 
docker-compose up -d
```

### Prepare Database Files
You will need a database of _icao-to-aircraft_ mappings (in _icao-to-aircraft.json_) and a database of callsigns (_callsign-details.json_).  A good source of data is https://openflights.org/data.html where you can find aircraft data suitable for your region

If you are in a hurry, _icao-to-aircraft.json.sample_ and _callsign-details.json.sample_ provide you basic records to experiment


### Run the application

```
docker-compose exec confluent bash
```

And within the container
```
confluent start
cd /scripts
./01_setup_topics
```

If you do not have database files, copy the sample files
```
cp -i icao-to-aircraft.json.sample icao-to-aircraft.json
cp -i callsign-details.json.sample callsign-details.json
```

Now load the files.  This will load data into the `icao-to-aircraft` and `callsign-details` topics
```
./02_do_load
```


And then run ksql.  If you recieve parse errors, try running the KSQL statments one by one manually instead of the entire script as one.

```
ksql
-- paste the commands from file 03_ksql.sql
exit
```

Still within the container finish the remaining setup steps
```
./04_elastic_dynamic_template
./05_set_connect
```

## Setup kibana
- Navigate to http://localhost:5601
- Create indexes for `locationtable` and `callsigntable`.  Each should have a `EVENT_TS` field marked as a timestamp
- Use the Kibana managment page to import saved objects in `06_kibana_export.json`

