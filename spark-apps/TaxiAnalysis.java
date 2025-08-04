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
        
        System.out.println("Processing complete. Output written to " + outputPath);
        spark.stop();
    }

    
}