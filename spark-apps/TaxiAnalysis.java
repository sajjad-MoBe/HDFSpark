import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import static org.apache.spark.sql.functions.*;

public class TaxiAnalysis {

    public static void main(String[] args) {
        String dataPath = "../data/"; 
        String outputPath = "../data/output"; // write output

        // Create a SparkSession for local execution
        SparkSession spark = SparkSession.builder()
                .appName("Local Taxi Analysis")
                .master("local[*]") // Run locally using all available cores
                .getOrCreate();

        // Load datasets
        Dataset<Row> tripData = spark.read().parquet(dataPath + "yellow_tripdata_2025-01.parquet");
        Dataset<Row> zoneData = spark.read().option("header", "true").csv(dataPath + "taxiZoneLookupTable.csv");

        // Run the analyses
        analysis1(tripData, outputPath);

        System.out.println("Processing complete. Output written to " + outputPath);
        spark.stop();
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
                        (col("tpep_dropoff_datetime").cast("long") - col("tpep_pickup_datetime").cast("long")) / 60)
                .orderBy(col("duration_minutes").desc());

        longTrips.write().mode("overwrite").parquet(outputPath + "q1_long_trips.parquet");
        System.out.println("Analysis 1 finished.");
    }
}