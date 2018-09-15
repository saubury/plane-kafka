SET 'auto.offset.reset' = 'earliest';
set 'ksql.sink.partitions' = '1';

-- 1. setup table icao_to_aircraft
-- drop stream icao_to_aircraft_stream;
CREATE STREAM icao_to_aircraft_stream WITH (KAFKA_TOPIC='icao-to-aircraft', VALUE_FORMAT='AVRO');

-- drop stream icao_to_aircraft_rekey;
CREATE STREAM icao_to_aircraft_rekey AS SELECT * FROM icao_to_aircraft_stream  PARTITION BY icao;

-- DROP TABLE icao_to_aircraft;
CREATE TABLE icao_to_aircraft WITH (KAFKA_TOPIC='ICAO_TO_AIRCRAFT_REKEY', VALUE_FORMAT='AVRO', KEY='ICAO');

-- 2. setup table callsign_details
-- drop stream callsign_details_stream;
CREATE STREAM callsign_details_stream WITH (KAFKA_TOPIC='callsign-details', VALUE_FORMAT='AVRO');

-- drop stream callsign_details_rekey;
CREATE STREAM callsign_details_rekey AS SELECT * FROM callsign_details_stream  PARTITION BY callsign;

-- DROP TABLE callsign_details;
CREATE TABLE callsign_details WITH (KAFKA_TOPIC='CALLSIGN_DETAILS_REKEY', VALUE_FORMAT='AVRO', KEY='CALLSIGN');

-- 3. setup stream location_stream
-- drop stream location_stream;
create stream location_stream with (kafka_topic='location-topic', value_format='AVRO');

-- 4. setup stream ident_stream
-- drop stream ident_stream;
create stream ident_stream with (kafka_topic='ident-topic', value_format='AVRO');

-- 5. combined result, location_stream join icao_to_aircraft
-- drop stream location_and_details_stream;
create stream location_and_details_stream as select l.ico, l.height, l.location, t.aircraft, t.registration, t.manufacturer from location_stream l left join icao_to_aircraft t on l.ico = t.icao;

-- drop table locationtable;
CREATE table locationtable with (value_format='JSON') AS \
select ico, height, location, aircraft, registration, manufacturer, count(*) as events \
from location_and_details_stream WINDOW TUMBLING (size 10 second) \
group by ico, height, location, aircraft, registration, manufacturer;

-- 6. combined result, ident_stream join callsign
-- drop stream ident_callsign_stream;
create stream ident_callsign_stream as select i.ICO, c.operatorname, c.callsign, c.fromairport, c.toairport from ident_stream i left join callsign_details c on i.INDENTIFICATION = c.callsign;

-- drop table callsigntable;
CREATE table callsigntable with (value_format='JSON') AS \
select ICO, callsign, operatorname, fromairport, toairport, count(*) as events \
from ident_callsign_stream WINDOW TUMBLING (size 10 second) \
group by ICO, callsign, operatorname, fromairport, toairport;
