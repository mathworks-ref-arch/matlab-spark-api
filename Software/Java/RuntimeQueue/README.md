# Building the package

The function `matlab.sparkutils.buildMatlabRuntimeQueue` is provided to build the Runtime Queue
jar file. This can in turn be called from `matlab.sparkutils.buildMatlabSparkAPIJars` which will
build the package's other jar files also.

>Note: The following steps are not required if the above commands are used.

If building the Runtime Queue jar file manually note that prior to building the
package, the MATLAB `javabuilder.jar` of the correct MATLAB runtime must be
installed in the local Maven repository.

In the case of MATLAB R2022b the file can be found in the following locations:

```
macOS: <MATLAB_ROOT>/toolbox/javabuilder/jar/javabuilder.jar
Linux: <MATLAB_ROOT>/toolbox/javabuilder/jar/javabuilder.jar
Windwos: <MATLAB_ROOT>\toolbox\javabuilder\jar\javabuilder.jar
```

The javabuilder.jar can also be found in an installation of the MATLAB runtime.

To install it in the local Maven repository, run the following command
(change the actual path for the `-Dfile` argument)

```bash
mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file \
    -Dfile="/<MATLAB_INSTALL>/toolbox/javabuilder/jar/javabuilder.jar" \
    -Dpackaging=jar -DartifactId="javabuilder.jar" -Dversion="9.13" \
    -DgroupId=com.mathworks.sparkbuilder
```

The version field is based on the output of `ver('matlab').Version`, thus giving a
unique version in the Maven repository per release of MATLAB.
