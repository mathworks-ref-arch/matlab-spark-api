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
Please note that `_rows` is added to the name of the function.
```python
# Assume the data is in the columns A, B and C
from demo.anomaly.wrapper import detectAnomaly_rows
df2 = df.select("A", "B", "C").rdd.map(detectAnomaly_rows).toDF(["X", "Y"])
```
This will return a new dataframe with the columns X and Y, with the results of the
calculations.

### Run a mapPartition function
The previous example will call the MATLAB Runtime once for every row. If instead one uses the
`mapPartition` method, it uses a data partition, and can run it all in one batch
in the compiled MATLAB function.
Please note in this case the added `_iterator` in the name of the function.
```python
# Assume the data is in the columns A, B and C
from demo.anomaly.wrapper import detectAnomaly_iterator
df2 = df.select("A", "B", "C").rdd.mapPartitions(detectAnomaly_iterator).toDF(["X", "Y"])
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

> The inline comments below is one way of handling this. It is also possible to create this
> information in a separate JSON file, kept alongside the function. This is described in
> further detail in [Function Signatures](FunctionSignatures.md).

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


[//]: #  (Copyright 2022 The MathWorks, Inc.)

