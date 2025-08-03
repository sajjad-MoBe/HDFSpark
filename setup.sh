docker-compose down -v

docker-compose up -d zookeeper journalnode

docker-compose run --rm namenode1 hdfs journalnode -format


docker-compose run --rm namenode1 hdfs namenode -format

docker-compose up -d namenode1

docker-compose run --rm namenode2 hdfs namenode -bootstrapStandby

docker-compose up