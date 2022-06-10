function generateWrapper(obj)
    % generateWrapper Wrapper for easier handling of Python library

    % Copyright 2022 The MathWorks, Inc.

    wrapperName = "wrapper.py";
    wrapperFile = fullfile(obj.SrcDir, wrapperName);
    obj.WrapperClassName = "Wrapper";
    wrapperInstance = "instance";
    wrapperInstanceFullName = obj.WrapperClassName + "." + wrapperInstance;

    SW = matlab.sparkutils.StringWriter(wrapperFile);

    SW.pf("# Wrapper file for %s package\n\n", obj.PkgName);

    SW.pf("from __future__ import print_function\n");
    SW.pf("import %s\n", obj.PkgName);
    SW.pf("import numpy as np\n");
    SW.pf("import pandas as pd\n");
    if obj.Metrics
        SW.pf("import pyspark\n");
    end
    SW.pf("from pyspark.sql.functions import pandas_udf, PandasUDFType\n\n");

    SW.pf("class %s:\n", obj.WrapperClassName);
    SW.indent();
    SW.pf('"""This class implements a Wrapper for running certain\n')
    SW.pf('compiled MATLAB functions more easily in a Spark environment."""\n\n');
    SW.pf("# Static variables\n")
    SW.pf("# Class instance\n");
    SW.pf("%s = None\n", wrapperInstance);
    SW.pf("# MATLAB Runtime\n");
    SW.pf("RT = None\n\n");

    SW.pf("def __init__(self):\n");
    SW.indent();
    SW.pf('"""This method initiates the package by instantiating (or reusing)\n')
    SW.pf('the MATLAB Runtime"""\n\n')
    SW.pf("super().__init__()\n");
    SW.pf("self.__setMATLABRuntime()\n\n");
    SW.unindent();

    SW.pf("@staticmethod\n");
    SW.pf("def getInstance():\n");
    SW.indent();
    SW.pf('"""This static method returns a singleton handle to this class."""\n\n');
    SW.pf("if %s is None:\n", wrapperInstanceFullName);
    SW.indent();
    SW.pf("%s = %s()\n", wrapperInstanceFullName, obj.WrapperClassName);
    SW.unindent();
    SW.pf("return %s\n\n", wrapperInstanceFullName);
    SW.unindent();

    SW.pf("# Methods for pickling:\n");
    SW.pf("def __getstate__(self):\n");
    SW.indent();
    SW.pf('"""Method to return state, as used by pickling.\n');
    SW.pf('It overrides the shipping method, and excludes some non-serializable\n')
    SW.pf('elements from the __dict__ entries."""\n\n');
    SW.pf("state = self.__dict__.copy()\n");
    SW.pf("del state['RT']\n");
    SW.pf("del state['instance']\n");
    SW.pf("return state\n\n");
    SW.unindent();

    SW.pf("def __setstate__(self, state):\n");
    SW.indent();
    SW.pf('"""Method to initialize a class after reading in the serialization.\n');
    SW.pf('It handles non-serializable elements specifically."""\n')
    SW.pf("self.__dict__.update(state)\n");
    SW.pf("self.__setMATLABRuntime()\n\n");
    SW.unindent();

    SW.pf("def __setMATLABRuntime(self):\n");
    SW.indent();
    SW.pf('"""Set the MATLAB runtime, initializing it if necessary."""\n\n')
    SW.pf("if %s.RT is None:\n", obj.WrapperClassName);
    SW.indent();
    SW.pf("print('### Initializing MATLAB Runtime')\n");
    SW.pf("%s.RT = %s.initialize()\n", obj.WrapperClassName, obj.PkgName);
    SW.unindent();
    SW.pf("else:\n");
    SW.indent();
    SW.pf("print('### MATLAB Runtime alread initialized')\n");
    SW.unindent();
    SW.pf("self.RT = %s.RT\n\n", obj.WrapperClassName);

    SW.unindent();
    SW.unindent();
    SW.pf('### End of Wrapper class\n\n');

    for k=1:length(obj.Files)
        fileObj = obj.Files(k);
        SW.pf("# ==================================\n")
        SW.pf("# ========= %s =========\n", fileObj.funcName);
        SW.pf("# ==================================\n")
        obj.generateFunctionWrapper(SW, fileObj);
    end


    SW.pf("# End of file\n")


end

