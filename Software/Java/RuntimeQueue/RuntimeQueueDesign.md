# RuntimeQueue - Design document

## Introduction

This document should describe the design of our solution for running a MATLAB function in a
Spark context, as in the example below.

```java
// DS is a Dataset/Dataframe
// foo, is the MATLAB function that was compiled
// foo_mapPartitions is a helper method for running foo in a Spark context
OUT = DS.mapPartitions(foo_mapPartitions(), foo_schema)
```

To enable this, with little or no manual work for the user, the function
`foo_mapPartitions` must fulfil the following requirements:

1. Data must automatically be marshalled from *Spark data* to *MATLAB data*
2. Some helper functions in MATLAB must be created that convert cell data to a MATLAB table. 
This ensure that a user can work with tables in MATLAB, and compile this and it will still
work in Spark, although the Compiler SDK interfaces currently don't support tables.
This function (and possibly others) should be compiled with the other functions.
3. The `foo_mapPartitions` function must use a MATLAB Runtime, and this should be completely
transparent to the user running the code. There is no reference to the MATLAB runtime
in the above code snippet.

All of this has already been implemented. This document focuses on the last point
on how to  handle the MATLAB Runtime.

## Requirements

1. When a function needs an instance of the MATLAB Runtime, it should get one
from a central source, the `RuntimeQueue`. 
2. The `RuntimeQueue` will keep a list of available Runtime instances.
3. Runtime instances will be not be created before requested.
4. When the `RuntimeQueue` gets a runtime request, it will look in its list of
available instances. If a correct one is found, it will be returned to the user.
If none is found, a new will be created.
5. There is a limit to how many runtimes can be in the list. By default, the number
is set to the number of cores on the machine.
6. When a runtime is left unused for a certain time, it will be disposed of.

### Rationale

1. A cluster may run for a long time, and different users may run different MATLAB Jars there.
There must be a way to ensure that there is not an abundance of runtimes (ctfserver processes)
running there, although not used anymore. Req #4, #5, #6
2. A spark job will only run as many threads in a job as there are cores. It doesn't make sense
to instantiate more runtimes than cores. Req #2, #3
3. If a user needs to manually handle runtimes, it will enforce them to write wrapper functions
to a degree that strongly reduces the appeal for a MATLAB workflow. Req #1.
4. If possible, runtimes should be reused. If a job runs a MATLAB function on a dataset with
20 partitions, this will require 20 invocations of the MATLAB function. If the system has 4 cores
in total, only 4 threads will be run simultaneously. This means there is no need to instantiate more
than 4 runtimes. When a MATLAB function returns, it will also return the runtime to the
`RuntimeQueue`. If the same thread makes another call to the same function, it will ask the
`RuntimeQueue` for an instance, and possible get back the same instance that it just used.
The process of getting/returning instances is very quick, though. Req #1, #2, #3, #4, #5.

## Implementation

*Pending*

[//]: #  (Copyright 2022 The MathWorks, Inc.)