#!/bin/bash

function wait_for_namenode {
    while true; do
        if curl --silent --fail http://localhost:9870/ >/dev/null 2>&1; then
            echo "namenode1 is up!"
            break
        else
            echo "Waiting for namenode1..."
            sleep 2
        fi
    done
}

while true; do
  clear
  echo "==============================="
  echo "      Hadoop Menu Options      "
  echo "==============================="
  echo "warning: It is recommended to run all services before commands 2,3 and 4."
  echo "--------------------------------"
  echo "1) Format NameNodes"
  echo "2) Sync hdfs-data/taxi local -> HDFS"
  echo "3) Sync hdfs-data/output HDFS -> local"
  echo "4) Run Spark-submit java"
  echo "5) Exit"
  echo "-------------------------------"
  read -p "Select an option [1-4]: " choice

  case "$choice" in
    1)
      
      read -p "Are you sure you want to continue? (y/N): " answer

      answer=${answer:-n}

      if [[ "$answer" =~ ^[Yy]$ ]]; then
        docker compose down -v
        docker rm -f zookeeper1 zookeeper2 zookeeper3 journalnode1 journalnode2 journalnode3 \ 
                      namenode1 namenode2 datanode1 datanode2 spark-client

        docker compose up zookeeper1 zookeeper2 zookeeper3 journalnode1 journalnode2 journalnode3 -d

        sleep 20

        docker compose run --rm namenode1 format

        docker compose up namenode1  -d

        wait_for_namenode

        docker compose run --rm namenode2 standby


        docker compose down
        echo "--------------------------------"
        echo "Cleanup and setup completed successfully. you can now start the services usint 'docker compose up' command."
        exit 0
      else
        echo "Operation cancelled."
      fi
      
      ;;
    2)
      read -p "Are you sure you want to continue? (y/N): " answer

      answer=${answer:-n}

      if [[ "$answer" =~ ^[Yy]$ ]]; then
        docker compose up -d
        
        wait_for_namenode

        docker compose exec namenode1 hdfs dfs -mkdir -p /data/taxi
        docker compose exec namenode1 bash -c "hdfs dfs -put -f /data/taxi/* /data/taxi/"

        echo "Sync complete!"

        read -p "All services are running, stop them? (y/N): " answer
        answer=${answer:-n}
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            docker compose down
            echo "All services stopped."
        else
            echo "Services are still running."
        fi
      fi
      read -p "Press enter to return to menu..."
      ;;
    3)
      read -p "Are you sure you want to continue? (y/N): " answer

      answer=${answer:-n}

      if [[ "$answer" =~ ^[Yy]$ ]]; then
        docker compose up -d
        
        wait_for_namenode

        docker compose exec namenode1 bash -c "hdfs dfs -get -f -p /data/output/* /data/output"


        echo "Sync complete!"

        read -p "All services are running, stop them? (y/N): " answer
        answer=${answer:-n}
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            docker compose down
            echo "All services stopped."
        else
            echo "Services are still running."
        fi
      fi
      read -p "Press enter to return to menu..."
      ;;
    4)
      read -p "Are you sure you want to run the Spark-submit java? (y/N): " answer
        answer=${answer:-n}
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            docker compose up -d

            wait_for_namenode
            jars=($(find ./spark-apps -type f -name "*.jar"))
            if [ ${#jars[@]} -eq 0 ]; then
                echo "No .jar files found in $APP_DIR"
            else
                echo "Available JAR files:"
                for i in "${!jars[@]}"; do
                    echo "  $i) ${jars[$i]}"
                done

                while true; do
                    read -p "Enter the number of the JAR to run: " jar_index
                    if [[ "$jar_index" =~ ^[0-9]+$ ]] && [ "$jar_index" -ge 0 ] && [ "$jar_index" -lt "${#jars[@]}" ]; then
                    break
                    fi
                    echo "Invalid selection. Please try again."
                done

                selected_jar="${jars[$jar_index]}"
                jar_filename=$(basename "$selected_jar")

                read -p "Enter the main class (e.g. src.TaxiAnalysis): " main_class

                echo "Running $jar_filename with class $main_class"
                
                docker compose exec spark-client spark-submit \
                    --class "$main_class" \
                    --master "local[*]" \
                    "/spark-apps/$jar_filename"
            

                echo "Spark-submit java app executed, check the logs!"
                read -p "All services are running, stop them? (y/N): " answer
                answer=${answer:-n}
                if [[ "$answer" =~ ^[Yy]$ ]]; then
                    docker compose down
                    echo "All services stopped."
                else
                    echo "Services are still running."
                fi
            fi
        fi
        read -p "Press enter to return to menu..."
        ;;
    5)
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose 1-5."
      sleep 1
      ;;
  esac
done
