curl -XPUT 'http://localhost:9200/_watcher/watch/node_watch' -d '{
  "trigger" : {
    "schedule" : { "interval" : "60s" }
  },
  "input" : {
    "search" : {
      "request" : {
        "indices" : [
          ".marvel-*"
        ],
        "search_type": "query_then_fetch",
        "body": {
          "query": {
            "filtered": {
              "query": {
                "bool": {
                  "should": [
                    {
                      "match": {
                        "event": "node_left"
                      }
                    }
                  ]
                }
              },
              "filter": {
                "range": {
                  "@timestamp": {
                    "from": "{{ctx.trigger.scheduled_time}}||-60s",
                    "to": "{{ctx.trigger.triggered_time}}"
                  }
                }
              }
            }
          },
          "fields": [
            "event",
            "message",
            "cluster_name"
          ]
        }
      }
    }
  },
  "throttle_period": "60s",
  "condition": {
    "compare" : { "ctx.payload.hits.size()" : { "gt" : 0 }}
  },
  "actions" : {
    "send_email" : {
      "email" : {
        "to" : "alina.october@gmail.com",
        "subject" : "{{ctx.payload.hits.hits.fields.event}} the cluster",
        "body" : "{{ctx.payload.hits.hits.fields.message}} the cluster {{ctx.payload.hits.hits.fields.cluster_name}} "
      }
    }
  }
}'
