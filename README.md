
### Get started
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
