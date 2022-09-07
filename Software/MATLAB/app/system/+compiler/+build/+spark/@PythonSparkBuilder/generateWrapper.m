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
    SW.pf("import numpy\n");
    SW.pf("import matlab\n");
    SW.pf("import threading\n");
    SW.pf("import pandas as pd\n");
    SW.pf("import os\n");
    SW.pf("import queue\n");
    if obj.Metrics
        SW.pf("import pyspark\n");
    end
    SW.pf("from pyspark.sql.functions import pandas_udf, PandasUDFType\n\n");

    % Import the RuntimePool implementation
    here = fileparts(mfilename('fullpath'));
    SW.insertFile(fullfile(here, 'runtimepool.py'));
    SW.insertFile(fullfile(here, 'psb_utils.py'));

    if obj.Debug
        SW.insertFile(fullfile(here, 'dbgvar.py'));
    end

    SW.pf("class %s:\n", obj.WrapperClassName);
    SW.indent();
    SW.pf('"""This class implements a Wrapper for running certain\n')
    SW.pf('compiled MATLAB functions more easily in a Spark environment."""\n\n');
    SW.pf("# Static variables\n")

    SW.pf("pool = None\n");
    SW.pf("poolSize = 4\n\n");


    SW.pf("def __init__(self):\n");
    SW.indent();
    SW.pf('"""This method initiates the package by instantiating (or reusing)\n')
    SW.pf('the MATLAB Runtime"""\n\n')
    SW.pf("super().__init__()\n");
    SW.pf("print('### Initializing MATLAB Runtime')\n");
    SW.pf("self.RT = %s.initialize()\n\n", obj.PkgName);
    SW.unindent();


    % SW.pf("@synchronized\n");
    SW.pf("@staticmethod\n");
    SW.pf("def getPool():\n");
    SW.indent();
    SW.pf('"""Return a pool object, that will deal with the MATLAB runtimes"""\n');
    SW.pf('if Wrapper.pool is None:\n');
    SW.indent();
    SW.pf("Wrapper.pool = RuntimePool(%s.initialize_runtime)\n\n", obj.PkgName);
    SW.unindent();

    SW.pf('return Wrapper.pool\n\n');
    SW.unindent();

    SW.pf("@staticmethod\n");
    SW.pf("def getInstance():\n");
    SW.indent();
    SW.pf('"""This static method returns a singleton handle to this class.\n');
    SW.pf('If no pool resources are available, the function is blocking."""\n\n');
    SW.pf('the_pool = Wrapper.getPool()\n\n');
    SW.pf('# The next call is possibly blocking\n')
    SW.pf('wrapper = the_pool.get()\n\n');
    SW.pf('return wrapper\n\n');
    SW.unindent();

    SW.pf("@staticmethod\n");
    SW.pf("def releaseInstance(wrapper):\n");
    SW.indent();
    SW.pf('"""This static returns a Wrapper instance, and its runtime, to the pool.\n');
    SW.pf('This is necessary to ensure resource sharing."""\n\n');
    SW.pf('the_pool = Wrapper.getPool()\n\n');
    SW.pf('# The next call is possibly blocking\n')
    SW.pf('the_pool.put(wrapper)\n\n');
    SW.unindent();

    SW.pf("# Methods for pickling:\n");
    SW.pf("def __getstate__(self):\n");
    SW.indent();
    SW.pf('"""Method to return state, as used by pickling.\n');
    SW.pf('It overrides the shipping method, and excludes some non-serializable\n')
    SW.pf('elements from the __dict__ entries."""\n\n');
    SW.pf("state = self.__dict__.copy()\n");
    SW.pf("del state['pool']\n");
    SW.pf("return state\n\n");
    SW.unindent();

    SW.pf("def __setstate__(self, state):\n");
    SW.indent();
    SW.pf('"""Method to initialize a class after reading in the serialization.\n');
    SW.pf('It handles non-serializable elements specifically."""\n')
    SW.pf("self.__dict__.update(state)\n");
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

