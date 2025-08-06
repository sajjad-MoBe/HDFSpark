# HDFSpark

**HDFSpark** is a scalable and highly available **Hadoop Distributed File System (HDFS)** cluster built with **Docker Compose**, featuring automatic failover via **ZooKeeper** and integrated with **Apache Spark**.


## Project Overview

This project provides a complete setup for distributed data processing using:

- HDFS for distributed storage
- Apache Spark for data processing
- Docker for containerization
- Java for implementation

## Project Setup and Execution Guide

### 1. Initial Cluster Setup with Docker Compose

The project uses Docker Compose to set up a multi-container HDFS cluster. This includes:
- ZooKeeper quorum for automatic failover coordination
- JournalNodes for shared edit log persistence
- Multiple DataNodes with persistent volumes
- DataNodes for distributed storage
- Spark client for run jobs

#### 1. Clone the repository

```bash
git clone https://github.com/sajjad-MoBe/HDFSpark.git
cd HDFSpark
```

#### 2. Format the Cluster (First-Time Only)

Run the management script and select option `1) Format NameNodes`. This initialization:

- Creates necessary directories
- Formats the HDFS filesystem
- Prepares the cluster for first use
  This step is only required for the first run.

```bash
chmod +x manage.sh
./manage.sh
```

After formatting is complete, you can start the cluster.

#### 3. Start the Cluster

```bash
docker compose up
```

Or to run it in the background:

```bash
docker compose up -d
```

Once running, the HDFS web UI will be available at:

* [http://localhost:9870](http://localhost:9870) — Active NameNode UI

---


### 2. Loading Files to HDFS

#### Step 1: Copy Files to Local Directory

The system processes NYC taxi trip data. Place these files in `hdfs-data/taxi`:

- `yellow_tripdata_<date>.parquet`: Contains taxi trip records
- `taxi_zone_lookup.csv`: Contains mapping of zone IDs to locations

Using commands:

```bash
cp yellow_tripdata_*.parquet hdfs-data/taxi/
cp taxi_zone_lookup.csv hdfs-data/taxi/
```

#### Step 2: Sync Files with HDFS

The management script provides utilities to sync local files to HDFS:

```bash
bash manage.sh
```

Select option `2) Sync hdfs-data/taxi local -> HDFS`
This copies all files from local `hdfs-data/taxi` to HDFS `/data/taxi` directory.

---
### 3. Running Spark Jobs

#### Step 0: Building JAR File (if needed)

If you need to compile the Java Spark application:

```bash
cd simple-java-spark-code
mvn clean package    # Builds the project and runs tests
cp target/your-app.jar ../spark-apps/
```

#### Step 1: Execute Spark-submit

Launch the Spark job using:

```bash
bash manage.sh
```

Select option `4) Run Spark-submit java` and follow the prompts:

- Specify the .jar file path: Path to your compiled application
- Enter the main class name (e.g., `src.TaxiAnalysis`): The entry point class

The Spark job will:

1. Read input data from HDFS
2. Process the taxi trip data
3. Write results back to HDFS

When spark is running, the Splark web UI will be available at:

* [http://localhost:4040](http://localhost:40404) — Spark web UI
---
### 4. Retrieving Outputs from HDFS

To get the processed results:

```bash
bash manage.sh
```

Select option `3) Sync hdfs-data/output HDFS -> local`
This downloads all output files from HDFS to your local machine.

---
### 5. Data Paths Reference

The system uses consistent paths for data management:

| Data Type | Local Path       | HDFS Path    | Description         |
| --------- | ---------------- | ------------ | ------------------- |
| Inputs    | hdfs-data/taxi   | /data/taxi   | Raw taxi data files |
| Outputs   | hdfs-data/output | /data/output | Processed results   |

### Quick Execution Script

For automated execution, use this sequence:

```bash
# Navigate to project directory
cd project-directory/

# Format HDFS (first time only)
bash manage.sh  # Select option 1

# Start Docker containers
docker compose up -d

# Upload local files
cp yellow_tripdata_*.parquet hdfs-data/taxi/
cp taxi_zone_lookup.csv hdfs-data/taxi/
bash manage.sh  # Select option 2

# Build JAR (if needed)
cd simple-java-spark-code
mvn clean package
cp target/your-app.jar ../spark-apps/

# Run Spark submit
bash manage.sh  # Select option 4
# Enter JAR path and class name (e.g., src.TaxiAnalysis)

# Download outputs
bash manage.sh  # Select option 3
```

## 👥 Contributors

> Made with ❤️ by:

* **Sajjad Mohammadbeigi**
* **Nazanin Yousefi**
* **Mohammad Mohammadbeigi**

---