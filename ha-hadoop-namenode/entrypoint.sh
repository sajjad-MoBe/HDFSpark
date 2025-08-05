#!/bin/bash


if [[ "$1" == "format" ]]; then
  echo "Formatting namenode..."
  hdfs namenode -format -force "$CLUSTER_NAME"
  hdfs zkfc -formatZK
  exit 0
fi

if [[ "$1" == "standby" ]]; then
  echo "bootstrapStandby namenode..."
  hdfs namenode -bootstrapStandby -force
  exit 0
fi
function wait_for_namenode_ui() {
  while true; do
    if curl --silent --fail http://localhost:9870/ >/dev/null 2>&1; then
      echo "Namenode is up!"
      break
    else
      echo "Waiting for Namenode..."
      sleep 2
    fi
  done
}

hdfs namenode &

wait_for_namenode_ui

hdfs zkfc

wait