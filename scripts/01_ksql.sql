SET 'auto.offset.reset' = 'earliest';

drop stream identstream;
create stream identstream with (kafka_topic='ident-topic', value_format='AVRO');

drop stream locationstream;
create stream locationstream with (kafka_topic='location-topic', value_format='AVRO');

drop table locationtable;
CREATE table locationtable with (value_format='JSON') AS 
SELECT ico, height, location, count(*) AS events 
FROM locationstream window  TUMBLING (size 10 second) 
where location != '0.0,0.0' 
GROUP BY ico, height, location;
