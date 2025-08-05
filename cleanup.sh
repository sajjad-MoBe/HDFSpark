#!/bin/bash

read -p "Are you sure you want to continue? (y/N): " answer

answer=${answer:-n}

if [[ "$answer" =~ ^[Yy]$ ]]; then
    docker compose down -v

else
    echo "Operation cancelled."
    exit 1
fi


docker compose up zookeeper1 zookeeper2 zookeeper3 journalnode1 journalnode2 journalnode3 -d

sleep 20

docker compose run --rm namenode1 format

docker compose up namenode1  -d

# Wait for namenode1 to be ready
while true; do
  if curl --silent --fail http://localhost:9870/ >/dev/null 2>&1; then
    echo "namenode1 is up!"
    break
  else
    echo "Waiting for namenode1..."
    sleep 2
  fi
done

docker compose run --rm namenode2 standby


docker compose down
echo "Cleanup and setup completed successfully. you can now start the services usint 'docker compose up' command."