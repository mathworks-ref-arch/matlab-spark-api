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

### Importing to the environment

There is always a class generated, `Wrapper`, which is needed to call the functions.
```python
# First, import the Wrapper class of this package
from demo.anomaly.wrapper import Wrapper as W
```
### Calling a simple function
```python
# Test the function detectAnomaly
T = W.detectAnomaly(3,4,5)
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
df2 = df.select("A", "B", "C").rdd.map(W.detectAnomaly_rows).toDF(["X", "Y"])
```
This will return a new dataframe with the columns X and Y, with the results of the
calculations.

### Run a mapPartition function
The previous example will call the MATLAB Runtime once for every row. If instead one uses the
`mapPartition` method, it uses a data partition, and can run it all in one batch
in the compiled MATLAB function.
Please note that in this case, the added `_iterator` in the name of the function.
```python
# Assume the data is in the columns A, B and C
df2 = df.select("A", "B", "C").rdd.mapPartitions(W.detectAnomaly_iterator).toDF(["X", "Y"])
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
df2 = df.select("A", "B", "C").rdd.mapPartitions(W.detectAnomaly_table).toDF(["X", "Y"])
```

The return values from `mapPartitions` is still a dataset with two columns. 
The *table* is a MATLAB table.


[//]: #  (Copyright 2022 The MathWorks, Inc.)

