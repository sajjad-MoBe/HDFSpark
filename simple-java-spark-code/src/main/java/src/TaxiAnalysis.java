package src;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import static org.apache.spark.sql.functions.*;

public class TaxiAnalysis {

    public static void main(String[] args) {
        String dataPath = "hdfs://ns1/data/taxi/";  // Container path
        String outputPath = "hdfs://ns1/data/output/";  // Container path

        // Create a SparkSession for local execution
        SparkSession spark = SparkSession.builder()
                .appName("Local Taxi Analysis")
                .master("local[*]") // Run locally using all available cores
                .getOrCreate();

        // Load datasets
        Dataset<Row> tripData = spark.read().parquet(dataPath + "yellow_tripdata_2025-01.parquet");
        Dataset<Row> zoneData = spark.read().option("header", "true").csv(dataPath + "taxi_zone_lookup.csv");    

        // Run the analyses
        analysis1(tripData, outputPath);
        analysis2(tripData, zoneData, outputPath);
        analysis3(tripData, zoneData, outputPath);
        analysis4(tripData, outputPath); 

        System.out.println("Processing complete. Output written to " + outputPath);
        try{
            spark.stop();
        } catch (Exception e) {
            System.err.println("Error stopping Spark session, don't worry, it will stop automatically.");
        }
    }

    /**
     * Analysis 1: Filters for long trips with more than 2 passengers, calculates duration,
     * and saves the result.
     */
    public static void analysis1(Dataset<Row> tripData, String outputPath) {
        System.out.println("Running Analysis 1: Long Trips...");
        Dataset<Row> longTrips = tripData
                .filter(col("passenger_count").gt(2).and(col("trip_distance").gt(5)))
                .withColumn("duration_minutes",
                        (unix_timestamp(col("tpep_dropoff_datetime")).minus(unix_timestamp(col("tpep_pickup_datetime")))).divide(60))
                .orderBy(col("duration_minutes").desc());

        longTrips.write().mode("overwrite").parquet(outputPath + "q1_long_trips_parquet");
        longTrips.write().mode("overwrite").option("header", "true").csv("/output/q1_long_trips_csv");
        System.out.println("Analysis 1 finished.");
    }

    /**
     * Analysis 2: Calculates the average fare for each pickup zone.
     */
    public static void analysis2(Dataset<Row> tripData, Dataset<Row> zoneData, String outputPath) {
        System.out.println("Running Analysis 2: Average Fare by Zone...");
        Dataset<Row> avgFareByZone = tripData
                .join(zoneData, tripData.col("PULocationID").equalTo(zoneData.col("LocationID")))
                .groupBy("Zone", "Borough")
                .agg(avg("fare_amount").alias("average_fare"))
                .orderBy(col("average_fare").desc());

        avgFareByZone.write().mode("overwrite").parquet(outputPath + "q2_avg_fare_by_zone_parquet");
        avgFareByZone.write().mode("overwrite").option("header", "true").csv(outputPath + "q2_avg_fare_by_zone_csv");
        System.out.println("Analysis 2 finished.");
    }


    /**
     * Nnalysis 3: Calculates total revenue and trip count for each destination Borough.
     */
    public static void analysis3(Dataset<Row> tripData, Dataset<Row> zoneData, String outputPath) {
        System.out.println("Running Analysis 3: Revenue by Destination Borough...");
        Dataset<Row> revenueByBorough = tripData
                // Join based on Dropoff Location ID (DOLocationID)
                .join(zoneData, tripData.col("DOLocationID").equalTo(zoneData.col("LocationID")))
                // Group by the destination Borough
                .groupBy("Borough")
                // Calculate sum of total_amount and count of trips
                .agg(
                    sum("total_amount").alias("total_revenue"),
                    count("*").alias("trip_count")
                )
                .orderBy(col("total_revenue").desc());

        revenueByBorough.write().mode("overwrite").parquet(outputPath + "q3_revenue_by_borough_parquet");
        revenueByBorough.write().mode("overwrite").option("header", "true").csv(outputPath + "q3_revenue_by_borough_csv");

        System.out.println("Analysis 3 finished.");
    }

    /**
     * Analysis 4: Calculates the maximum tip amount per day.
     */
    public static void analysis4(Dataset<Row> tripData, String outputPath) {
        System.out.println("Running Analysis 4: Maximum Tip per Day...");
        Dataset<Row> maxTipPerDay = tripData
                // Create a new column 'date' by converting the pickup timestamp
                .withColumn("date", to_date(col("tpep_pickup_datetime")))
                // Group by the new 'date' column
                .groupBy("date")
                // Find the maximum tip_amount for each day
                .agg(max("tip_amount").alias("max_tip"))
                .orderBy("date");

        maxTipPerDay.write().mode("overwrite").parquet(outputPath + "q4_max_tip_per_day_parquet");
        maxTipPerDay.write().mode("overwrite").option("header", "true").csv(outputPath + "q4_max_tip_per_day_csv");

        System.out.println("Analysis 4 finished.");
    }
}