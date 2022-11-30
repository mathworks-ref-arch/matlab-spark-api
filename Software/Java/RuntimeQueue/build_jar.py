# build_jar.py
# A utility that builds the sparkbuilder-runtimequeue jar
# This script is primarily intended for server side Databricks based builds

# Copyright 2022 MathWorks, Inc.

import json
import sys
import os
import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--javabuilderPath", type=str,
                   help="Full path to a copy of the MATLAB javabuilder.jar file")
    parser.add_argument("-m", "--matlabVersion", type=str,
                   help="Version of MATLAB corresponding to the javabuilder.jar file of the form e.g.: 9.13")
    args = parser.parse_args()

    # Pointing Java home to the jdk directory - required only for the databricks environment
    javaHome = "JAVA_HOME=/usr/lib/jvm/zulu8-ca-amd64 " if(os.environ.get('DATABRICKS_RUNTIME_VERSION',None) != None) else ""

    # Used in Maven install
    artifactId = "javabuilder"

    print(f'Installing javabuilder.jar to Maven, MATLAB version: {args.matlabVersion}, path: {args.javabuilderPath}')

    if not os.path.exists(args.javabuilderPath):
        sys.exit("javabuilder.jar not found: " + args.javabuilderPath)
    else:
        mvnInstCmd = "mvn -B org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file -Dfile=\"" + args.javabuilderPath + "\" -Dpackaging=jar -DartifactId=\"" + artifactId + "\" -Dversion=\"" + args.matlabVersion + "\" -DgroupId=\"com.mathworks.sparkbuilder\""
        print(f'mvnInstCmd: {mvnInstCmd}')
        instRetCode = os.system(mvnInstCmd)
        if instRetCode != 0:
            sys.exit("Maven install failed for: " + args.javabuilderPath + ", Returned: " + str(instRetCode))
        else:
            print(f'Installed javabuilder.jar version: {args.matlabVersion}, path: {args.javabuilderPath}')
            print(f'Building Runtime Queue jar')
            mvnPkgCmd = "mvn -B -Dmatlab.runtime.version=\"" + args.matlabVersion + "\" clean package"
            print(f'mvnPkgCmd: {mvnPkgCmd}')
            pkgRetCode = os.system(mvnPkgCmd)
            if pkgRetCode != 0:
                sys.exit("Maven package failed for: " + args.matlabVersion + ", Returned: " + str(pkgRetCode))
            else:
                 print(f'Finished building Runtime Queue jar')
