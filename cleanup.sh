#!/bin/bash

read -p "Are you sure you want to continue? (y/N): " answer

answer=${answer:-n}

if [[ "$answer" =~ ^[Yy]$ ]]; then
    docker compose down -v

else
    echo "Operation cancelled."
    exit 1
fi


docker compose up zookeeper journalnode1 journalnode2  -d

sleep 10

docker run --rm -it \
  -v ./config/core-site.xml:/etc/hadoop/core-site.xml \
  -v ./config/hdfs-site.xml:/etc/hadoop/hdfs-site.xml \
  -v HDFSpark_namenode1-data:/hadoop/dfs/name \
  --network HDFSpark_hadoop-network \
  --name namenode1 -e HDFS_CONF_dfs_ha_namenode_id=namenode1 \
  bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8 \
  hdfs namenode -format -force test-ha

docker compose up namenode1  -d

sleep 10

docker run --rm -it \
  -v ./config/core-site.xml:/etc/hadoop/core-site.xml \
  -v ./config/hdfs-site.xml:/etc/hadoop/hdfs-site.xml \
  -v HDFSpark_namenode2-data:/hadoop/dfs/name \
  --network HDFSpark_hadoop-network \
  --name namenode2  -e HDFS_CONF_dfs_ha_namenode_id=namenode2 \
  bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8 \
  hdfs namenode -bootstrapStandby -force

docker compose up namenode2 -d

sleep 10

docker compose up datanode1 datanode2

sleep 20

docker compose down