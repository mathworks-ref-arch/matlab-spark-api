# Build UDFs and Dataset functions
## SparkBuilder

This utility uses the Compiler SDK to create a Jar library, and then generates certain
wrapper classes that will make it easier to use the compiled functions in a Spark context.

The current implementations supports functions for calling the `map` and
`mapPartitions` methods on a Dataset,
and also a wrapper for *UDF* methods.

We want to compile a small function, `myfun`, that calculates the factorial, and then use
this in a Dataset mapping.

```matlab
function F = myfun(N)
    F = 1;
    for k=2:N
        F = F*k;
    end 
end
```

> **Note** The SparkBuilder functions may take strings as arguments. Return values, however,
> cannot be a `string`. These should instead be converted to `char arrays`.
> The technical reason for this is that the MATLAB Runtime is spawned *out-of-process*,
> as this is preferable for performance reasons on a Spark cluster. The matlab `string` type,
> however, cannot be returned from the MATLAB Runtime when running *out-of-process*.
> If this is enabled in a later release, this package will adapt accordingly.

### Building the Jar file
We create a `SparkBuilder` object, specifying the output folder (`outFolder`) and
the name of package (`mw.datasetexample`) that the classes will belong to.

```matlab
SB = compiler.build.spark.SparkBuilder('outFolder', 'mw.datasetexample');
```
The `SparkBuilder` has certain properties that can be set.

* `Verbose` - Can be set to `true/false`. Default is `false`.
* `AddReleaseToName` - Can be set to `true/false`. Default is `true`. This will add
both the MATLAB Release version (e.g. R2021a) and the Spark version (e.g. Spark3.x)
to the name of the created Jar file.

The Compiler SDK will compile functions into methods in one or more classes,
so we first instantiate a helper class for the Java class, which we'll call *Arith*.

```matlab
JC1 = compiler.build.spark.JavaClass("Arith");
```
We now add the functions that should belong in the class, only our `myfun` in
this example. The arguments to the `File` class are the name of the file,
the input argument types and the output argument types.
```matlab
BF = compiler.build.spark.File("myfun.m", {"int64"}, {"int64"});
```

> **Note** If the function depends on other MATLAB functions, these will
> get pulled in automatically by the MATLAB Compiler. The dependent functions,
> however, will not be part the external interface of the Java class.

We then add the function to our Java class, and we add the Java class to the
`SparkBuilder`.
```matlab
JC1.addBuildFile(BF);
SB.addClass(JC1);
```
It's possible to add several functions to a class, and several classes to the
SparkBuilder, but we're just using this one right now.

Finally, we start the build. This will generate the usual classes for Compiler SDK,
after which the wrapper classes are generated, and finally all the sources are recompiled
and packaged in a Jar.

```matlab
SB.build
```
After this command, we will have all the output in the folder `outFolder`, and in
particular our Jar file, `outFolder/datasetexample.jar`.

After the build, the `SB` object will have some additional information in the `Info`
field, which can be helpful for further use. E.g.
```matlab
>> SB.Info
ans = 
  struct with fields:

         JarFile: 'bobby_R2021b_Spark3.x_glnxa64.jar'
     FullJarFile: '/local/Software/MATLAB/examples/TableData/outBDOY/bobby_R2021b_Spark3.x_glnxa64.jar'
         Imports: "import com.mathworks.demo.bobby.TablesWrapper;"
    EncoderInits: "TablesWrapper.initEncoders(spark)"
```

### Using the methods in a Spark context
The methods generated can now be used in a Spark context. A Spark context here could
be e.g. a *Spark Shell* or an executable notebook.

An example file, `runSparkShell.sh` will be generated in the `outFolder`. It's not a
complete test, but shows how some functions can be used. When run, it also copies
some lines of code into the clipboard, so that by copying these lines into the 
*Spark Shell* command line, it will do some imports and create some test datasets.
This file only works on a Linux system (possibly also OSX, but this is not tested).

> **Note**: Before running this file, it must be changed to be executable, e.g.
```bash
$ chmod +x runSparkShell.sh
```


### Methods generated
Not all methods are generated for all functions. Some methods make no sense in certain contexts.
For example, a filter method will only be generated for a function with exactly one return argument
which is of `logical` type.

#### initEncoders method
Some of the methods described below require `Encoder` arguments. These can be created
manually, but are also present in the created Jar file.
To use this encoders, they must first be initialized, which is done with the `initEncocders`
method, which takes the active `SparkSession` as argument.
```Java
initEncoders(spark);
```

#### map method
The `map` method will run one function on each row in a dataset. To run the `myfun` function
created above, it would look like this in a Scala context
```scala
val Result = MyDataset.map(Arith.myfun)
```

In Java, we have to be a bit more explicit:
```Java
Dataset Result = MyDataset.map(Arith.myfun(), Arith.myfun_encoder);
```

Please note the parenthesis in the Java version, i.e. `Arith.myfun()`. This is because
the function will return a newly created `MapFunction<T,U>` object.

Calling `map` in Java requires us to specify an encoder too, but this has already
been generated for us in the wrapper library.

#### mapPartition method
The `mapPartition` method is similar to the `map` method.
```Scala
val Result = MyDataset.mapPartitions(Arith.myfun_mapPartitions(), Arith.myfun_encoder)
```

```Java
Dataset Result = MyDataset.mapPartitions(Arith.myfun_mapPartitions(), Arith.myfun_encoder)
```

Here too, the parenthesis are necessary in the function, `Arith.myfun_mapPartitions()`,
as this method returns a new instance of a `MapPartitionsFunction<T,U>` object.
Note that in Scala, the parenthesis are optional, as Scala will handle this automatically.

#### filter method
The `filter` will filter out rows, if applying a certain function on the row does not
return true.

In this case, the `filter` method will only be generated for MATLAB functions that have
* exactly one return value
* the type of the return value is `logical` (`Boolean` in Java)

It can be called as follows, assuming we have a function `mylogicalfunc` defined and compiled:
```Scala
val Result = MyDataset.filter(Arith.mylogicalfunc_filter())
```


#### UDF methods
For each function in your class, there will be two functions for registering the function
as a *UDF*. 

The first takes a `SparkSession` and a name of the UDF, i.e.
```Java
reg_myfun_udf(spark, "factorial");
```

This will enable this function in a UDF context, e.g.
```Scala
val TT = spark.sql("SELECT idDouble, factorial(idDouble) FROM myds4")
```

A second version of the function exists, that only takes a `SparkSession` as an argument.
It will register the UDF with the same name as the function, i.e.
```Java
// These two calls are equivalent
reg_myfun_udf(spark);
reg_myfun_udf(spark, "myfun");
```

**Note** Please be aware that the UDF functions currently do not work with
array arguments.

### Obfuscating code

Starting in Release R2022b, MATLAB Compiler SDK supports obfuscating the
code and folders in the artifacts. 
This is done using the `-s` option for `mcc`,
 [https://www.mathworks.com/help/compiler/mcc.html](https://www.mathworks.com/help/compiler/mcc.html).

To use this with `SparkBuilder`, use call the method `obfuscateCode()`, i.e.
```matlab
SB.obfuscateCode()
```

### Using custom encryption

Starting in Release R2022b, it is possible to use custom encryption with
MATLAB Compiler SDK artifacts. This is done using the `-k` option for `mcc`,
 [https://www.mathworks.com/help/compiler/mcc.html](https://www.mathworks.com/help/compiler/mcc.html).
As per the mcc documentation specific contents of the Compiler SDK are already
encrypted, e.g. m files. However, this option adds the ability to provide a
user specified key.

The `SparkBuilder` class has support for adding this encryption. As described
in the documentation of `mcc`, encryption can be added like this:

```matlab
mcc -k "file=<key_file_path>;loader=<mex_file_path>" <other arguments>
```

To use this with `SparkBuilder`, specify the `key` and the `mexfile`
by calling the method `addEncryptionFiles`, e.g.:

```matlab
SB = <some initialization>

SB.addEncryptionFiles("./some.key", "./some_mex.mexa64")
```
This will then add the corresponding flag to the build, thereby enabling custom encryption.

#### Trying out encryption

To try out encryption, the option `-k` can be used without specifying the files. In this
case, the files will be created. When doing so, however, the build will fail.
This approach can still be used, though, by doing as follows:

```matlab
% Compile a function (simple example) with the -k option
mcc -W 'java:example.addTwo,addTwoClass' -k -d ./out -v -Z autodetect class{addTwoClass:./addTwo.m}
```

This will fail, but it will have created a sample key-file and a mex file. Copy these to the current folder.
In this example:

```matlab
% Please note that mex extension differs for different platforms
copyfile("./out/external_key_demo/addTwo.key", ".")
copyfile("./out/external_key_demo/addTwo_loader.mexa64", ".")
```

Now the build can be started again, but by explicitly using these new files:

```matlab
 mcc -W 'java:example.addTwo,addTwoClass' -k 'file=./addTwo.key;loader=./addTwo_loader.mexa64' -d .\out -v -Z autodetect class{addTwoClass:./addTwo.m}
```

This second build will now work. Correspondingly, these (example) key/mex combination can be used
with `SparkBuilder` too:

```matlab
SB = <some initialization>

SB.addEncryptionFiles("./addTwo.key", "./addTwo_loader.mexa64")
```

> Note, the sample key and mex file produced are for demonstration and are intented to be
> customised to meet production security requirements.

> Note, in most Spark environments e.g. Databricks the mex file will be excuted on a
> Linux based system thus it must also be compiled on a Linux based system as it is C
> based rather than MATLAB.

## JavaClass
The class `compiler.build.spark.JavaClass`, as seen above, is used to create a
reference to the Java class that will contain the entry points to the associated 
MATLAB files. The constructor takes different combinations of input arguments.

The first, non-optional argument is always the name of the Java class.

The second, optional argument is a list of files.
### The names of the files
This can be a cell array or a string array of function names or file names.
The two following calls are equivalent.

```matlab
J = compiler.build.spark.JavaClass("ClassName", {"datenum", "addFileProtocol"})
```
```matlab
J = compiler.build.spark.JavaClass("ClassName", ["datenum", "addFileProtocol"])
```

### The name of the files and their types
This way of calling the constructor allows the addition of types (and sizes)
for the input and arguments of the files (cf. the [File](#file) documentation).

> The handling of arguments can also be handled in a different way, described in more
> detail in [Function Signatures](FunctionSignatures.md). Please refer to this
> document for additional information.

Here, the second argument will be a cell array, whose entries will be either strings
or cell arrays.

```matlab
J = compiler.build.spark.JavaClass("ClassName", {{"addFileProtocol", "string", "string"}});
```

This example shows a JavaClass with one function (`addFileProtocol`) with explicit arguments,
and one function (`datenum`) with default arguments.
```matlab
J = compiler.build.spark.JavaClass("ClassName", {{"addFileProtocol", "string", "string"}, "datenum"});
```

### Adding files after creation
The `JavaClass` can also add files after its creation.

```matlab
J = compiler.build.spark.JavaClass("ClassName", "datenum")
F = compiler.build.spark.File("addFileProtocol");
J.addBuildFile(F)
```

## File
The class `compiler.build.spark.File`, as seen above, is used to create a
reference to a MATLAB file that should be part of the build. The constructor
takes different combinations of input arguments.

### Only file name
When given only a file name, the constructor will use the functions
`nargin` and `nargout` to deduce the number of input and output arguments.
The arguments will be assumed to be double scalars.
```matlab
F = compiler.build.spark.File("somefun.m");
```

### List of datatypes
If the constructor is called with 3 arguments, the arguments are:
1. File name
2. Input argument types
3. Output argument types

The format here may also differ, and the examples below will all give the same results.
#### Cell array
A cell array of strings containing the different types.
```matlab
F = compiler.build.spark.File("somefun.m", {"int64", "double"}, {"int64"});
```

#### String arrays
A simple string is a string array with one element, so the variants below are equivalent.
```matlab
F = compiler.build.spark.File("somefun.m", ["int64", "double"], ["int64"]);
```

```matlab
F = compiler.build.spark.File("somefun.m", ["int64", "double"], "int64");
```

### List of datatypes and sizes
This variant takes cell arrays with datatypes and sizes for the arguments.

**Note** The current version of this package does not yet support non-scalar
arguments, however, they may be used when constructing `File` object the class.

In this case, the input and output arguments are cell arrays, where each entry is
either:
* A string, or
* A cell array containing a string and a size, or
* A cell array containing a string, a size and a name

The following calls are all equivalent.

```matlab
F = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, "double"}, {"int64"});
```
```matlab
F = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, {"double", [1,1]}}, {{"int64", [1,1]}});
```
```matlab
F = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, {"double", [1,1]}}, "int64");
```

### Marking a function as a Table function
Some MATLAB functions don't expect a *single row* as an argument, but rather a *table*.
An example of this could be a function to normalize values in a vector, which makes no
sense for single values.

In this case, a `File` should be marked as `TableInterface`, i.e.
```matlab
file = compiler.build.spark.File("normalizeStuff", ...
    {{"double", [1,1], "Time_sec"}, {"string", [1,1], "VehicleID"}, ...
    {"double", [1,1], "CmdCurrent"}, {"double", [1,1], "EngineSpeed"}}, ...
    ["double", "string", "double", "double"]);
file.TableInterface = true;
```

For a function like this, only the `mapPartitions` method will be available.
As can be seen, when specifying the input types, there is also information about the name
of each input argument. This is necessary for the following reason.

The function that is compiled, in this example `normalizeStuff`, expects a MATLAB table
as input. The `mapPartition` method provides an iterator, not a table. A helper function
will take the data and create a MATLAB table. To create a table with the expected names,
instead of just `Var1`, `Var2`, etc., the names must be provided to this function.

The example function here looks like below, expecting at least the columns `CmdCurrent`
and `EngineSpeed`. For this reason, the names must be specified.

```matlab
function tOut = normalizeStuff(tIn)
    % normalizeStuff Example of normalizing two columns in a table
        
    tOut = normalize(tIn, ...
        'DataVariables', ["CmdCurrent", "EngineSpeed"]);
        
end
```

Another aspect of this is that the function has 1 input and 1 output, but we specify
4 inputs and 4 outputs when defining the `File` object. This corresponds to the number
columns in the input table and the output table.

[//]: #  (Copyright 2021-2022 The MathWorks, Inc.)


