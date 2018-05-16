#!/usr/bin/env bash

unset http_proxy
unset https_proxy
export http_proxy
export https_proxy

HOST=elasticsearch

echo "Loading Elastic Dynamic Template to ensure _TS fields are used for TimeStamp"

curl -XDELETE "http://${HOST}:9200/_template/kafkaconnect/"

curl -XPUT "http://${HOST}:9200/_template/kafkaconnect/" -H 'Content-Type: application/json' -d'
{
  "template": "*",
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "_default_": {
      "dynamic_templates": [
        {
          "dates": {
            "match": "EVENT_TS",
            "mapping": {
              "type": "date"
            }
          }
        },
        {
          "locations": {
            "match": "LOCATION",
            "mapping": {
              "type": "geo_point"
            }
          }
        },
        {
          "non_analysed_string_template": {
            "match": "*",
            "match_mapping_type": "string",
            "mapping": {
              "type": "keyword",
              "index": "not_analyzed"
            }
          }
        }
      ]
    }
  }
}'

echo

