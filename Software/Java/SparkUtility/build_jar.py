# build_jar.py
# A small utility that builds the matlab-spark-utility.
# To do this, it must read through configurations and put it together.

# Copyright 2021 MathWorks, Inc.

import json
import sys
import os
import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--profile", type=str, choices=["apachespark", "databricks"], default="apachespark",
                        help="Choose profile to build for. databricks is not shaded and thinner")
    parser.add_argument("-r", "--release", type=str, default="3.0.1",
                        help="Choose Spark release to build for")
    parser.add_argument("-t", "--target", type=str, choices=["package", "compile"], default="package",
                        help="Choose build target")
    args = parser.parse_args()

    profile = args.profile
    release = args.release
    print('profile == ' + profile)
    fileName = "../../MATLAB/config/matlab_spark_config.json"
    with open(fileName) as json_file:
        data = json.load(json_file)

        for v in data['Version']:
            if v['name'] == release:
                ver = v

    print('ver: ' + ver['name'])
    str = "mvn --batch-mode -P" + profile + " -Dspark.fullversion=" + ver['name']
    for opt in ver['maven']:
        # print("opt[" + opt['name'] + "] == " + opt['value'])
        str += " -D" + opt['name'] + "=" + opt['value']
    str += " clean " + args.target
    print("str: " + str, flush=True)
    retCode = os.system(str)
    print('Build returned' )
    print(retCode)

        


