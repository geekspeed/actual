## Apptual Ruby Plateform

### MongoDB in background

mongod --config /etc/mongodb/mongod.conf

### Deployment

rake <env> vlad:deploy

**env referes to environment of application running in

### Background services

QUEUE=* rake environment resque:work

### Job scheduling system built on top of resque

QUEUE=* rake environment resque:scheduler

### Redis in production

redis-server /etc/redis/redis.conf

### PIDS

nginx: /var/run/nginx.pid
mongod: /var/run/mongod.pid
redis: /var/run/redis.pid
