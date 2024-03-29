# Python Spark Builder

This utility use the Compiler SDK to create a Python library, and then generates
wrapper code that will make it easier to use the underlying compiled MATLAB functions
in a Spark context.

> The examples here assume that the following is present:
> * MATLAB Compiler SDK (and dependent toolboxes)
> * A Python installation (tested with 3.9)

> Note:
> This is an early release of this package. Some combinations of datatypes and sizes may not be functional.



## Basic usage

### Setup
There is a function, `detectAnomaly`, which takes 3 inputs and has 2 outputs, to be run on 3 columns
on every row of a dataset. The dataset is accessed using Spark/Databricks APIs.

### Building the wheel
First compile the function to a Python library.

```matlab
% First set a few options
buildOpts = compiler.build.PythonPackageOptions(...
    'detectAnomaly.m', ...
    'OutputDir', 'outAnomaly', ...
    'PackageName', 'demo.anomaly')

% And then start the build
OUT = compiler.build.spark.pythonPackage(buildOpts)
```

> **Note** the `pythonPackage` and `PythonPackageOptions` function/class were added
> to MATLAB in R2021a, and thus cannot be used in earlier releases. To address this
> in earlier releases, there are alternatives to these functions.
> If using e.g. R2020a, use the command `compiler.build.spark.PythonPackageOptions`
> for the build options.
>
> This interface's support for Python based packaging for releases prior to R2021a,
> is partial. Moving to a newer release of MATLAB is recommended.

At this point, there should be a *wheel* present in the corresponding dist folder:
```bash
$ ls outAnomaly/dist 
demo.anomaly-9.11.0-py3-none-any.whl
```

If this wheel file is used in a Spark/Databricks environment, the following
steps are required:

### Providing the Wheel file to the cluster
To run the file, it must be available on the cluster, and different clusters 
may have different options for this.

In the case of Databricks, a method on the result object of the build can be
used to upload and install this on a Databricks cluster.
 The output was named `OUT` in the previous example:
```matlab
OUT.uploadWheelToDatabricks("/some/folder", cluster_id);
```
Please note that this is currently only possible for DBFS.

### Importing to the environment

The functions to use with Spark will be created in a module called `wrapper`. In order to
call a specific function, import it from the package.

```python
# First, import the Wrapper class of this package
from demo.anomaly.wrapper import detectAnomaly
```
### Calling a simple function
```python
# Test the function detectAnomaly
T = detectAnomaly(3,4,5)
```

The result of the last operation will be a tuple, as there were two outputs.

### Load a dataset/dataframe
The next step is to run it on Spark dataset.

```python
df = spark.read.format("parquet").load("/some/data")
```

### Run a map function
To run a map function on every row of this dataset, it can be done as follows.
Please note that `_map` is added to the name of the function.
There is also a helper variable, with the suffix `_output_names`, that can
give the same names to the columns, as the output names in MATLAB.
```python
# Assume the data is in the columns A, B and C
from demo.anomaly.wrapper import detectAnomaly_map, detectAnomaly_output_names
df2 = df.select("A", "B", "C").rdd.map(detectAnomaly_map).toDF(detectAnomaly_output_names)
```
This will return a new dataframe with the columns X and Y, with the results of the
calculations.

### Run a mapPartition function
The previous example will call the MATLAB Runtime once for every row. If instead one uses the
`mapPartition` method, it uses a data partition, and can run it all in one batch
in the compiled MATLAB function.
Please note in this case the added `_mapPartitions` in the name of the function.
```python
# Assume the data is in the columns A, B and C
from demo.anomaly.wrapper import detectAnomaly_mapPartitions
df2 = df.select("A", "B", "C").rdd.mapPartitions(detectAnomaly_mapPartitions).toDF(detectAnomaly_output_names)
```

In this case, the MATLAB Runtime is called fewer times, which can speed up calculations.

### Running on a table function
Many algorithms don't work on a simple row, they need a set of data
(e.g. a *normalize* function cannot work on a single value). To use this in Spark,
one must take a few more steps. The reason is the following:

The dataframe being used will have a specific set of columns, 3 in this case, like
this: `df.select("A", "B", "C")`.

The function being called, however, expects a table. This means the data has to be converted
accordingly.

To achieve this a few steps are required. Assuming there is a function `mynormalize`,
which takes a table of data and normalizes the different columns, provide some additional
information to this function.

> The inline comments, available in a previous release, **are no longer supported**.
> The information should be specified in a separate JSON file, kept alongside the function.
> This is described in further detail in [Function Signatures](FunctionSignatures.md).

```matlab
function outTable = mynormalize(inTable)
    % mynormalize Function that normalizes the columns in a 3-column table
    %
    % @SB-Start@
    % {
    % "TableInterface": true,
    % "InTypes": ["double", "double", "double"],
    % "OutTypes": ["double", "double", "double"]
    % }
    % @SB-End@

    outTable = normalize(inTable);

end
```
As seen, this is a simple example, and the function is trivial. What is different to
the previous ones, is that there are additional comments between the keywords
`@SB-Start@` and `@SB-End@`. The text between these tokens is in JSON format, and if
the tokens are present, this text will be parsed.

3 things are specifed:
1. This function is using the `TableInterface`
2. It's `InputTypes` are 3 doubles
3. It's `OutputTypes` are 3 doubles

The information provided will enable the conversion from 3 columns to 1 table,
as described above.

Add this function to the previous example (many functions can be compiled into
the same Python library).

```matlab
% First set a few options
buildOpts = compiler.build.PythonPackageOptions(...
    {'detectAnomaly.m', 'mynormalize.m'}, ...
    'OutputDir', 'outAnomaly', ...
    'PackageName', 'demo.anomaly')

% And then start the build
OUT = compiler.build.spark.pythonPackage(buildOpts)
```

One can now run this function in Spark, and the input will be handled as a table.
To do this, use the `mapPartitions` method, and also add `_table` to the function name.

```python
# Assume the data is in the columns A, B and C
from demo.anomaly.wrapper import detectAnomaly_table
df2 = df.select("A", "B", "C").rdd.mapPartitions(detectAnomaly_table).toDF(["X", "Y"])
```

The return values from `mapPartitions` is still a dataset with two columns. 
The *table* is a MATLAB table.

### Running Pandas on a table function
It's also possible to run Pandas functions on a Table function. Pandas wrappers will automatically
be generated, and can be called like in the following example. Here 2 functions are shown,
`myfunction` which takes a table as input and a table as output, and `myotherfunction`, which takes a table and a constant
as input, and a table as output.

The `wrapper` also contains constants with the output schemas for the pandas functions.

The wrapper functions gets the extension `_applyInPandas`, and the schema gets the extension
`_output_schema`. So for the function `my_function` these will be respecitvely 
`myfunction_applyInPandas`, `myfunction_output_schema`

> **Note** In a previous version, these extensions were merely `_pandas` and `_pandas_schema`.
> This has changed now, but these older names are still present and pointing to the new
> functions. These additional names are deprecated, and will be removed in a future release.

#### Use `applyInPandas` on the result of a groupBy operation
```python
from demo.anomaly.wrapper import myfunction_applyInPandas, myfunction_output_schema

# This function has an interface like Tout = myfunction(Tin)
df3_fix = df3.groupby("cat").applyInPandas(
    myfunction_applyInPandas, schema=myfunction_output_schema)

# This function has an interface like Tout = myotherfunction(Tin, sigma)
# Sigma is just a constant, and not a table.
df3_fix2 = df3.groupby("cat").applyInPandas(
    myotherfunction_applyInPandas(10000.0), schema=myotherfunction_output_schema)
```

#### Use `mapInPandas` on a dataframe
This functionality is very similar to the previous `applyInPandas`, but this function
operates directly on a `Dataframe`.

```python
from demo.anomaly.wrapper import myfunction_mapInPandas, myfunction_output_schema

# This function has an interface like Tout = myfunction(Tin)
df3_fix = df3..mapInPandas(
    myfunction_mapInPandas, schema=myfunction_output_schema)

# This function has an interface like Tout = myotherfunction(Tin, sigma)
# Sigma is just a constant, and not a table.
df3_fix2 = df3..mapInPandas(
    myotherfunction_mapInPandas(10000.0), schema=myotherfunction_output_schema)
```


### Running Pandas series as a UDF
If one of the generated MATLAB functions
* doesn't use tables for inputs or outputs, and
* only has one output

a `_series` function will be generated. It is a function that works on `pandas.Series` objects,
and can be used as a UDF.

As an example, this (overly) simple function adds to numbers and returns the sum:
```matlab
function SUM = addme(x, y)
    SUM = x + y;
end
```
It is compiled with the `PythonSparkBuilder`. This will create an additional function in the `wrapper` module.

Now define a UDF for this function inside a notebook:
```python
from pyspark.sql.functions import pandas_udf
from mw.example.pandas.wrapper import addme_series
@pandas_udf('double', 'double')
def ml_addme_series(arg1, arg2):
    return addme_series(arg1, arg2)
```

This function can now be used as a UDF in a Spark operation, e.g.

```python
df4 = df3.withColumn("a_plus_b", ml_addme_series(df3.a, df3.b))
df4.show(10)
```

> **Note**: Each environment (Apache Spark, Python and MATLAB) have a certain set of supported data types.
> Often, there's a direct mapping between some types, and for others there's no exact mapping.
> For example, Spark supports (among other) `int16`, `int32` and `int64`, and so does MATLAB. Python however,
> supports one integer type, of potentially unlimited bits. This can lead to cases where the implementation difference
> cause numeric differences in output.

## Generated example files
In the process of compiling one ore more functions with `PythonSparkBuilder`, a few example functions will also
be generated. For each MATLAB function being compiled, a Python file for running a job will be created. 

If a the following options are made for compilation, compiling the functions `foo.m` and `baz.m`, in the package
`demo.p1`, as configured below:
```matlab
opts = compiler.build.PythonPackageOptions(...
    ["foo.m", "baz.m"], ...
    "OutputDir", "psb_out", ...
    "PackageName", "demo.p1" ...
    );

PSB = compiler.build.spark.pythonPackage(opts);
```

The following files will be generated:
* `demo_p1_baz_example.py`
* `demo_p1_foo_example.py`
* `deploy_baz_example.m`
* `deploy_foo_example.m`

The Python file can be run as a job on a Spark cluster, exercising some of
the methods that are generated. In the `baz` example, it may look like this:
```python
# Example file for generated functions

from __future__ import print_function
import sys
from random import random

from pyspark.sql import SparkSession
from pyspark.sql.functions import col,lit
from datetime import datetime

# Import special functions from wrapper
from demo.p1.wrapper import baz_output_names
from demo.p1.wrapper import baz_output_schema
from demo.p1.wrapper import baz_mapPartitions
from demo.p1.wrapper import baz_applyInPandas
from demo.p1.wrapper import baz_mapInPandas

if __name__ == "__main__":
    """
        Usage: demo_p1_baz_example.py range_limit out_folder
    """
    spark = SparkSession\
            .builder\
            .appName("simple_task")\
            .getOrCreate()
    
    now = datetime.now() # current date and time
    suffix = "_" + now.strftime("%Y%m%d_%H%M%S")
    range_limit = int(sys.argv[1]) if len(sys.argv) > 1 else 1000

    R = spark.range(range_limit).withColumnRenamed('id', 'xxxx')
    DF = (R
        .withColumn('ID', R['xxxx'].cast('long'))
        .withColumn('Hello', R['xxxx'].cast('String'))
        .withColumn('PIMult', R['xxxx'].cast('double'))
    ).select("ID","Hello","PIMult")

    OUT_mapPartitions = DF.rdd.mapPartitions(baz_mapPartitions).toDF(baz_output_names)
    print('mapPartitions result')
    OUT_mapPartitions.show(10, False)

    OUT_mapInPandas = DF.mapInPandas(baz_mapInPandas, baz_output_schema)
    print('mapInPandas result')
    OUT_mapInPandas.show(10, False)

    OUT_applyInPandas = DF.groupBy("ID").applyInPandas(baz_applyInPandas, baz_output_schema)
    print('applyInPandas result')
    OUT_applyInPandas.show(10, False)

    print("baz task is now done!")

# End of file demo_p1_baz_example.py
```
As can be seen, the function creates some sample data, whilst the values are irrelevant, the
required schema is applied.
It then proceeds to run some calculations 
with the available functions. The code in this example can be used as a base for creating
a *real function*, operating on *real data*. It may prove helpful for a MATLAB user
rather than as a guide to writing Spark jobs.

The MATLAB functions generated are specifically for users that run their Spark jobs on
Databricks. It will run the job on an existing cluster, or a temporary job cluster, and
is also aimed to be a help for users to run their Databricks jobs from within MATLAB.


[//]: #  (Copyright 2022 The MathWorks, Inc.)

