# Configuration

Apache Spark comes in different versions, and the environment should be
configured to use the correct version. This is important for

1. building the `matlab-spark-utility` Jar file,
2. generating the Java classpath, and
3. setting up properties to instantiate a Spark environment.

The configuration is kept in a `json` file, and contains configurations for
different versions of Spark (at the time of writing *2.4.7* and *3.0.1*, but
more can be added). In general, there should be no need to edit this file
manually, but this can be done, e.g. to add another entry for a version of spark.

**Note** This class is used both by Apache Spark and Databricks, but the use


## The Config class

The configuration is handled most directly through the `Config` class.

```matlab
>> C = matlab.sparkutils.Config.getInMemoryConfig()
C = 
  Config with properties:

          Versions: ["2.4.5"    "2.4.7"    "3.0.1"    "3.0.1-hadoop3.2"]
    CurrentVersion: '3.0.1'
            Master: 'local'
```

The output will show us what versions are available, and which is set
as the `CurrentVersion`. The `CurrentVersion` is what will be used for the tasks
listed further above.

### Changing the version
The `CurrentVersion` can easily be changed.

```matlab
>> C = matlab.sparkutils.Config.getInMemoryConfig()
C = 
  Config with properties:

          Versions: ["2.4.5"    "2.4.7"    "3.0.1"    "3.0.1-hadoop3.2"]
    CurrentVersion: '3.0.1'
            Master: 'local'
>> C.CurrentVersion = "2.4.7"
C = 
  Config with properties:

          Versions: ["2.4.5"    "2.4.7"    "3.0.1"    "3.0.1-hadoop3.2"]
    CurrentVersion: "2.4.7"
            Master: 'local'
```

Only the available versions can be used:
```matlab
>> C.CurrentVersion = "2.4.8"
Error using matlab.sparkutils.Config/set.CurrentVersion (line 144)
The version 2.4.8 is not part of the available versions (2.4.5 2.4.7 3.0.1 3.0.1-hadoop3.2 )
```
To make this reflect in the `json` file, the configuration must now be saved.

```matlab
C.saveConfig
```

## Maven build info
The `matlab-spark-utility` Jar file, which is needed for certain operations,
must be built for the corresponding Spark version.

This build relies on both a JDK and Apache Maven being installed.

The Config object contains information pertaining to the build, as can be seen here:
```matlab
>> C.CurrentVersion = "3.0.1"
C = 
  Config with properties:

          Versions: ["2.4.5"    "2.4.7"    "3.0.1"    "3.0.1-hadoop3.2"]
    CurrentVersion: "3.0.1"
            Master: 'local'
>> C.genMavenBuildCommand
Run this command to build matlab-spark-utility:
	mvn --batch-mode -Papachespark -Dspark.fullversion=3.0.1 -Dspark.version=3.0.1 -Dspark.major.version=3.x -Dscala.version=2.12.10 -Dscala.compat.version=2.12 -Dhadoop.version=2.7.4 clean package    
```

The end user should not be required to use the `genMavenBuildCommand` command explicitly, as this
is wrapped in the `buildMatlabSparkUtility` command. This is explained in one of the containing
packages, i.e. MATLAB Interface *for Apache Spark* or MATLAB Interface *for Databricks*.

[//]: #  (Copyright 2020-2021 The MathWorks, Inc.)

