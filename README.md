# HDFSpark

A scalable data analytics project

## Project Setup and Execution Guide

### 1. Initial Cluster Setup with Docker Compose

First, navigate to the project's root directory:

```bash
cd path/to/project-directory
```

Run the management script:

```bash
bash manage.sh
```

Select option `1) Format NameNodes`. This initialization is only required for the first run.

Start the Docker containers:

```bash
docker compose up -d
```

### 2. Loading Files to HDFS

#### Step 1: Copy Files to Local Directory

Place the following files in `hdfs-data/taxi`:

- `yellow_tripdata_<date>.parquet`
- `taxi_zone_lookup.csv`

Using commands:

```bash
cp yellow_tripdata_*.parquet hdfs-data/taxi/
cp taxi_zone_lookup.csv hdfs-data/taxi/
```

#### Step 2: Sync Files with HDFS

Run:

```bash
bash manage.sh
```

Select option `2) Sync hdfs-data/taxi local -> HDFS`

### 3. Running Spark Jobs

#### Step 0: Building JAR File (if needed)

```bash
cd simple-java-spark-code
mvn clean package
cp target/your-app.jar ../spark-apps/
```

#### Step 1: Execute Spark-submit

Run:

```bash
bash manage.sh
```

Select option `4) Run Spark-submit java` and follow the prompts:

- Specify the .jar file path
- Enter the main class name (e.g., `src.TaxiAnalysis`)

### 4. Retrieving Outputs from HDFS

Run:

```bash
bash manage.sh
```

Select option `3) Sync hdfs-data/output HDFS -> local`

### 5. Data Paths Reference

| Data Type | Local Path       | HDFS Path    |
| --------- | ---------------- | ------------ |
| Inputs    | hdfs-data/taxi   | /data/taxi   |
| Outputs   | hdfs-data/output | /data/output |

### Quick Execution Script

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
bash manage.sh
```
