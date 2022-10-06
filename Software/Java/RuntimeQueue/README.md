
# Building the package
Prior to building the package, the MATLAB `javabuilder.jar` of the correct MATLAB Runtime
must be installed in the local Maven repository.

In the case of MATLAB R2022a:

```bash
fd -e jar javabuilder -a                                                                       ─╯
/<MATLAB_INSTALL>/toolbox/javabuilder/jar/javabuilder.jar
```

The Jar can also be found in an installation of the MATLAB runtime

To install this in the local Maven repository, run the following command
(change the actual path for the `-Dfile` argument)

```bash
mvn org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file \
    -Dfile="/<MATLAB_INSTALL>/toolbox/javabuilder/jar/javabuilder.jar" \
    -Dpackaging=jar -DartifactId=javabuilder-v912 -Dversion="1.0.0" \
    -DgroupId=com.mathworks.sparkbuilder
```

