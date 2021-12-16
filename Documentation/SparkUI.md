# Spark UI

The Spark UI package directory */Software/MATLAB/app/system/+sparkui* is an interface
to the Spark UI REST API. This requires the REST API to be configured on the server
side and accessible to the MATLAB client.

This is intended as a debugging aid and as the basis for further extension it does
support the complete API or represent a core feature of Spark AI package.

The interface is commonly referred to as the "Spark UI" interface as it is often
used as the basis for Spark Web UIs. In this case a GUI is not provided rather a
means of more easily making programmatic queries and returning results as MATLAB
data types.

Use of a Databricks endpoint requires that the MATLAB interface for Databricks be
configured and present on the MATLAB path.

Currently parameter arguments are not widely supported and data should be filter
once returned to MATLAB as an alternative.

## Basic Usage

```matlab
% Create a /applications object using Databricks connection and authentication
% details. A configured .databricks-connect in the users home directory is
% expected in this case
% 44181 is a sample port value
app = sparkui.Applications(sparkui.EndPointType.Databricks, 44181)
app = 
  Applications with properties:

         request: [1x1 matlab.net.http.RequestMessage]
             uri: [1x1 matlab.net.URI]
    endPointType: Databricks
     HTTPOptions: [1x1 matlab.net.http.HTTPOptions]
 

% Query the /applications root call to get the Id
rootData = app.root()
rootData =
  1x3 table
              id                     name            attempts  
    _______________________    ________________    ____________
    app-20210615155208-0000    Databricks Shell    [1×1 struct]


% Use the Id to query /applications/[app-id]/storage/rdd 
rddData = app.storageRdd(rootData.id);
% For brevity summarize
summary(rrdData)
Variables:
    id: 3x1 double
        Values:
            Min          304  
            Median      5496  
            Max         5552  
    name: 3x1 cell array of character vectors
    numPartitions: 3x1 double
        Values:
            Min           1   
            Median       12   
            Max          12   
    numCachedPartitions: 3x1 double
        Values:
            Min           1   
            Median       12   
            Max          12   
    storageLevel: 3x1 cell array of character vectors
    memoryUsed: 3x1 double
        Values:
            Min             923
            Median        11820
            Max       1.062e+08
    diskUsed: 3x1 double
        Values:
            Min          0    
            Median       0    
            Max          0    
    dataDistribution: 3x1 cell
    partitions: 3x1 cell


% Query /applications/[app-id]/executors
% No executors present in this case
execData = app.executors(rootData.id)
Client Error: Not Found
Not Found
Body.Data:
/api/v1/applications/app-20210615155208-0000/storage/rdd/app-20210615155208-0000/executors
Returning []
execData =
     []


% Query /applications/[app-id]/allexecutors
% No executors present in this case
allexecData = app.allexecutors(rootData.id)
Client Error: Not Found
Not Found
Body.Data:
/api/v1/applications/app-20210615155208-0000/storage/rdd/app-20210615155208-0000/executors/app-20210615155208-0000/allexecutors
Returning []
allexecData =
     []
```

## Endpoint configuration
The port used by Databricks clusters is not fixed and needs to be determined
before the API endpoint can be accessed. To determine this for a given cluster
following statements can be used from a Python or SQL notebook:

In Python:
```python
port = spark.sql("set spark.ui.port").collect()[0].value
```

In SQL:
```SQL
set spark.ui.port
```
In the case of a local Apache Spark endpoint the default value is 4040.


## Supported endpoints

* /applications
* /applications/[app-id]/jobs
* /applications/[app-id]/jobs/[job-id]
* /applications/[app-id]/stages
* /applications/[app-id]/stages/[stage-id]
* /applications/[app-id]/stages/[stage-id]/[stage-attempt-id]
* /applications/[app-id]/stages/[stage-id]/[stage-attempt-id]/taskSummary
* /applications/[app-id]/stages/[stage-id]/[stage-attempt-id]/taskList
* /applications/[app-id]/executors
* /applications/[app-id]/executors/[executor-id]/threads
* /applications/[app-id]/allexecutors
* /applications/[app-id]/storage/rdd
* /applications/[app-id]/storage/rdd/[rdd-id]
* /version

## Unsupported endpoints

* /applications/[base-app-id]/logs
* /applications/[base-app-id]/[attempt-id]/logs
* /applications/[app-id]/streaming/statistics
* /applications/[app-id]/streaming/receivers
* /applications/[app-id]/streaming/receivers/[stream-id]
* /applications/[app-id]/streaming/batches
* /applications/[app-id]/streaming/batches/[batch-id]
* /applications/[app-id]/streaming/batches/[batch-id]/operations
* /applications/[app-id]/streaming/batches/[batch-id]/operations/[outputOp-id]
* /applications/[app-id]/sql
* /applications/[app-id]/sql/[execution-id]
* /applications/[app-id]/environment

Additional endpoints will be added over time, please contact MathWorks to request
specific endpoints as required.

## References

For further information see:
* [https://spark.apache.org/docs/latest/monitoring.html](https://spark.apache.org/docs/latest/monitoring.html)

[//]: #  (Copyright 2021 The MathWorks, Inc.)
