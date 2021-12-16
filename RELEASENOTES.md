#  MATLAB *Spark API* - Release Notes

## 0.1.18 (16th Dec 2021)
* Minor, cosmetic fixes

## 0.1.17 (15th Dec 2021)
* Update SparkAPI generated documentation

## 0.1.16 (8th Dec 2021)
* Fix VERSION number
* Pure cosmetic changes

## 0.1.15 (8th Dec 2021)
* Add several methods from `org.apache.spark.sql.functions`

## 0.1.14 (1st Dec 2021)
* Improved documentation
* SparkBuilder improvements

## 0.1.13 (21th Oct 2021)
* Documentation updates
* Added 3.1.1 configuration of Spark
* Several methods on Dataset object added
* Fixed bug with mapPartion Table generation

## 0.1.12 (28 September 2021)
* Improvements to thread handling in Map/udf functions
* Add metrics option to SparkBuilder
* Add support for Tables in mapPartitions

## 0.1.11 (8 September 2021)
* Fix SparkBuilder bug on Windows
* Adapt Jar naming in SparkBuilder

## 0.1.10 (3 September 2021)
* Fixed issues with datatype handling for map/udf
* More array encoders added (Short, String, Byte)

## 0.1.9 (24 August 2021)
* Remove dependency on SparkConf and SparkContext in SparkSession
* Update SparkUtility, 0.2.8., with methods for creating Encoders
* Add support for non-scalar mapping/filter methods on Datasets

## 0.1.8 (16 July 2021)
* Add missing text fixture

## 0.1.7 (16 July 2021)
* Added initial Spark UI REST API support
* Add drop method to Dataset
* Improve UDF/map SparkBuilder

## 0.1.6 (8 June 2021)
* Add arithmetic, relational and boolean operators on Column object.
  This also includes overloading of corresponding MATLAB operators.
* Add feature to generate wrapper functions to use with Dataset map
  functions and UDFs.
* New version of matlab-spark-utility, 0.2.7
* Support converting binary data to table

## 0.1.5 (31 March2021)
* Fix issue when converting Maps to and from MATLAB
* Add schema method to Dataset
* Update JVM utility to create HashMap
* Make it possible to create Dataset (in table2dataset) using an existing schema.

## 0.1.4 (16 March 2021)
* Minor fix for resource cleanup in test

## 0.1.3 (14 March2021)
* Add support for Spark 3.0.1 with Hadoop 3.2
* Add support for in-memory Spark configuration
* Add the SparkCluster to connect to as part of configuration
* Additional Spark methods: 
  * Column explain(), when(), lit() methods
  * Dataset saveAsTable(); 
  * Spark.sql.functions when() and column() methods.
  * Unit test for all the methods

## 0.1.2 (4 March 2021)
* Add dependencies in Java, needed for OSX
* Add tests for join and sample

## 0.1.1 (3 March 2021)
* Update of matlab-spark-utility, version 0.2.3
* Methods added for dataset joins, and relational group datasets sum
* Improved handling of different Spark versions

## 0.1.0 (21 January 2021)
* First release
* Major rework to split out the Spark API into a separate repository.

[//]: #  (Copyright 2020-2021 The MathWorks, Inc.)
