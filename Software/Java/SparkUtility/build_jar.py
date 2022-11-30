# build_jar.py
# A small utility that builds the matlab-spark-utility.
# To do this, it must read through configurations and put it together.
# This script is primarily intended for a server side Databricks based build

# Copyright 2021-2022 MathWorks, Inc.

import json
import sys
import os
import argparse

def install_local_dbc(dbcversion, dbclocation):
    str = f'mvn -B org.apache.maven.plugins:maven-install-plugin:2.5.2:install-file '\
    '-Dfile="' + dbclocation + '" '\
    '-Dpackaging=jar '\
    '-DartifactId="matlab-databricks-connect" '\
    '-Dversion="' + dbcversion + '" '\
    '-DgroupId="com.mathworks"'

    print("str: " + str, flush=True)
    retCode = os.system(str)
    if retCode != 0:
        sys.exit("Maven install failed for: " + dbcversion + ", " + dbclocation + ", Returned: " + str(retCode))

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--profile", type=str, choices=["apachespark", "apachespark_plain", "databricks"], default="apachespark",
                        help="Choose profile to build for. databricks is not shaded and thinner")
    parser.add_argument("-r", "--release", type=str, default="3.0.1",
                        help="Choose Spark release to build for")
    parser.add_argument("-t", "--target", type=str, choices=["package", "compile"], default="package",
                        help="Choose build target")
    parser.add_argument("-d", "--dbcversion", type=str, default="10.4.12",
                        help="Choose build target")
    parser.add_argument("-l", "--dbclocation", type=str, default="",
                        help="Choose build target")
    args = parser.parse_args()

    profile = args.profile
    release = args.release
    dbcversion = args.dbcversion
    dbclocation = args.dbclocation
    if len(dbclocation) > 0:
         install_local_dbc(dbcversion, dbclocation)


    print('profile == ' + profile)
    fileName = "../../MATLAB/config/matlab_spark_config.json"
    with open(fileName) as json_file:
        data = json.load(json_file)

        for v in data['Version']:
            if v['name'] == release:
                ver = v

    print('ver: ' + ver['name'])
    
    # Pointing Java home to the jdk directory - required only for the databricks environment
    javaHome = "JAVA_HOME=/usr/lib/jvm/zulu8-ca-amd64 " if(os.environ.get('DATABRICKS_RUNTIME_VERSION',None) != None) else ""

    cmdStr = javaHome + "mvn --batch-mode -P" + profile + " -Dspark.fullversion=" + ver['name'] + " -Dmatlab.databricks.connect.version=" + dbcversion

    for opt in ver['maven']:
        # print("opt[" + opt['name'] + "] == " + opt['value'])
        cmdStr += " -D" + opt['name'] + "=" + opt['value']
        
    cmdStr += " clean " + args.target
    print("cmdStr: " + cmdStr, flush=True)
    retCode = os.system(cmdStr)
    if retCode != 0:
        sys.exit("Maven failed for: " + cmdStr + ", Returned: " + str(retCode))


