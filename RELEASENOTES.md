# MATLAB *Spark API* - Release Notes

## 0.2.9 (16th December 2022)
* Generate example files for `PythonSparkBuilder`

## 0.2.8 (29th November 2022)
* Support encryption for `SparkBuilder`
* Support obfuscation for `SparkBuilder`

## 0.2.7 (16th November 2022)
* Minor Apple silicon fix

## 0.2.6 (16th November 2022)
* Implemented `pivot` method on `RelationalGroupedDataset`
* Enabled Apple silicon beta in startup

## 0.2.5 (14th November 2022)
* Consolidated building Java based utilities

## 0.2.4 (4th Novebmer 2022)
* Support for more than 5 outputs for SparkBuilder (Scala)

## 0.2.3 (28th October 2022)
* Handle filename escaping for comments

## 0.2.2 (30th Sept 2022)
* Global handling of MATLAB Runtime for Java jobs, improving resource utilization.
* Make `runSparkShell` functions Runtime version dependent
* Add support for `pythonPackage` for older releases.
* Fixed `SparkBuilder` issue for release R2022b.

## 0.2.1 (7th Sept 2022)
* Update `SparkApiRef.md`

## 0.2.0 (7th Sept 2022)
* Improved PythonSparkBuilder
* Improved error handling in deployed mode
* Make it possible to use arrays as arguments to Python/Java Spark Builder functions
* Bugfix for `pretty` in R2019a

## 0.1.32 (14th July 2022)
* Pointing JAVA_HOME to JDK Home for Databricks environment

## 0.1.31 (7th July 2022)
* Support `mapInPandas`
* Rename `func_pandas` to `func_applyInPandas`
* Lazy creation of MATLAB Runtime for Python interface

## 0.1.30 (10th June 2022)
* Support for vectors in `dataset2table`
* Support string type for SparkBuilder additional arguments

## 0.1.29 (17th May 2022)
* Add `isin` method for `Column` object

## 0.1.28 (16th May 2022)
* Add exception cause for missing Jar in Databricks

## 0.1.27 (13th May 2022)
* Migrate from `distutils` to `setuptools` for `PythonSparkBuilder`
* Add metrics option for (some) Pandas methods
* Enable persistent spark sessions for Databricks
* Add concat method from `sql.functions`
* Add schema method on `DataFrameReader`
* Add `TableAggregate` type for `PythonSparkBuilder`

## 0.1.26 (11th Apr 2022)
* Support methods `describe` and `summary` on Dataset class
* Support *Pandas* methods in `PythonSparkBuilder`.

## 0.1.25 (30th Mar 2022)
* Enabling additional arguments for Table functions
* Provide helper functions for Compiler workflows
* Add `na` method for dataset

## 0.1.24 (15th Mar 2022)
* Minor fix to example

## 0.1.23 (14th Mar 2022)
* Minor fix for SparkSession/SparkConf

## 0.1.22 (7th Mar 2022)
* Implement more `sql.functions` methods
* YAML row/column order

## 0.1.21 (22nd Feb 2022)
* Add PythonSparkBuilder feature

## 0.1.20 (9th Feb 2022)
* Fixed Java build for newest MATLAB release (shading certain packages)
* Removed spark-avro Jar for Spark 2.2.0 (no longer available at repositories)
* Add support for Spark 3.2.1

## 0.1.19 (21th Jan 2022)
* SparkBuilder Info added
* Support Yarn as host for SparkSession

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

[//]: #  (Copyright 2020-2022 The MathWorks, Inc.)
