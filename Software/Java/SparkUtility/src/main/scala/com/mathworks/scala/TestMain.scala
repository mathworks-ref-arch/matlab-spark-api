/** This just contains some static tests for while developing the software.
  *
  * Copyright 2020-2021 MathWorks, Inc.
  */
package com.mathworks.scala

import org.apache.spark.SparkConf
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.{Dataset, Row}

object TestMain {
  def main(args: Array[String]) {
    println("### Hello, SparkTest!")
    val master = "local"
    val appName = "Scala-App"
    val sparkConf = new SparkConf()
    sparkConf.setMaster(master)
    sparkConf.setAppName(appName)

    val sparkSessionBuilder = SparkSession.builder();
    sparkSessionBuilder.config(sparkConf);

    println("### Creating spark session")
    val spark = sparkSessionBuilder.getOrCreate();
    println("### spark session created: " + spark)
    val fn =
      // "file:///local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/test/fixtures/wrapperarray.parquet"
//      "file:///local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/test/fixtures/nested2"
//      "file:///local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/test/fixtures/readme.parquet"
      "file:///C:/EI/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/test/fixtures/readme.parquet"
//      "file:///local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/test/fixtures/2008_small.csv"

    println("### Reading Dataset")
    val DS = spark.read
      .format("parquet")
      .load(fn)
      .select("PartID", "test_vals")
      .limit(5)
//    val DS = spark.read
//      .format("csv")
//      .option("header", "true")
//      .option("inferSchema", "true")
//      .load(fn)
////      .select("CancellationCode")
//      .limit(10)

    println("### Entries in DS: " + DS.count)

    DS.show(5, false)

//    import spark.implicits._
//    //    val DS2 = DS.map( goof(_) )
//    val DS2 = DS.map(row => {
//      goof(row)
//      //      (row.getInt(0), row.getString(6) + "#" + row.getString(8))
//    })
//    val DF2 = DS2.toDF("Year", "Arr")
//    DF2.printSchema()
//    DF2.show(10, false)

    println("### Scala conversion:")
    val newDeal = SparkUtilityHelper.convertDatasetToData(DS)
    println("### newDeal: " + newDeal)

    println("### Get rows from DS")
    val rows = DS.collectAsList

    println("### Get first row from rows")
    val r0 = rows.get(0)

    // println("### Get WrappedArray from first row")
    // val wa =
    //   (r0.get(1)).asInstanceOf[scala.collection.mutable.WrappedArray$ofRef]

    // println("### isWrappedArray(wa): " + isWrappedArray(wa))
    // val wa0 = wa(0)
    // val wa0IsWrapped = isWrappedArray(wa0)
    // println("### isWrappedArray(wa0): " + wa0IsWrapped)
    // if (wa0IsWrapped) {
    //   val wa0AIO = wa0.asInstanceOf[WrappedArray$ofRef]
    //   val wa00 = wa0AIO(0)
    //   println("### wa00: " + wa00)
    // }

    // val L = WrappedArrayRefToList(wa)
    // println("### wa: " + wa)
    // println("### L: " + L)

    spark.close();

  }

  def goof(row: Row) = {
    (row.getInt(0), row.getString(6) + "#" + row.getString(8))
  }

}
