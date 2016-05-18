curl -XPUT 'http://localhost:9200/_watcher/watch/watcher1' -d '{
  "trigger": {
    "schedule": {
      "interval": "60s"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": [
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
                    "from": "{{ctx.trigger.triggered_time}}||-15m",
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
  "actions": {
    "send_email": {
      "email": {
        "to": "alina.october@gmail.com",
        "subject": " the cluster",
        "body": "{{ctx.payload.hits.input}}"
      }
    }
  }
}'
