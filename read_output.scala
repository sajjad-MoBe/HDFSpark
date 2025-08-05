val q1 = spark.read.parquet("/opt/bitnami/spark/output/q1_long_trips.parquet")
val q2 = spark.read.parquet("/opt/bitnami/spark/output/q2_avg_fare_by_zone.parquet")
val q3 = spark.read.parquet("/opt/bitnami/spark/output/q3_revenue_by_borough.parquet")
val q4 = spark.read.parquet("/opt/bitnami/spark/output/q4_max_tip_per_day.parquet")

println("Q1: Long Trips")
q1.show()

println("\nQ2: Average Fare by Zone")
q2.show()

println("\nQ3: Revenue by Borough")
q3.show()

println("\nQ4: Maximum Tips per Day")
q4.show()