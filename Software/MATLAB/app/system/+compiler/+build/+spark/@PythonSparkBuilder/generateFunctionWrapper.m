function generateFunctionWrapper(obj, SW, fileObj)
    % generateFunctionWrapper Wrapper for generating interface for one
    % function

    % Copyright 2022 The MathWorks, Inc.

    % =========== Just call function, nice interface  ===========
    SW.pf("# ========= %s =========\n", fileObj.funcName);
    SW.pf("# A plain call to the MATLAB function %s\n", fileObj.funcName);
    SW.pf("@staticmethod\n");
    SW.pf("def %s(%s):\n", ...
        fileObj.funcName, ...
        fileObj.generatePythonInputArgs(false));
    SW.indent();
    SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
    SW.pf("return instance.RT.%s(%s)\n\n", ...
        fileObj.funcName, ...
        fileObj.generatePythonInputArgs(true));
    SW.unindent();

    % =========== Call function on a row ===========
    SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
    SW.pf("# The input argument in this case is a Spark row\n");
    SW.pf("# The row should have the same number of entries as arguments to the function\n");
    SW.pf("@staticmethod\n");
    SW.pf("def %s_rows(row):\n", fileObj.funcName);
    SW.indent();
    SW.pf("return %s.%s(%s)\n\n", ...
        obj.WrapperClassName, ...
        fileObj.funcName, ...
        fileObj.generatePythonRowInputArgs("row"));
    SW.unindent();
    
    % =========== Helper functions to get iterator to a list of rows ===========
    SW.pf("@staticmethod\n");
    SW.pf("# A helper function to convert an iterator to a list%s\n", fileObj.funcName);
    SW.pf("def %s_iterator_rows(iterator):\n", fileObj.funcName);
    SW.indent();
    SW.pf("for row in iterator:\n")
    SW.indent();
    if fileObj.nArgIn == 1
        SW.pf("yield %s\n\n", fileObj.generatePythonRowInputArgs("row"));
    else
        SW.pf("yield [%s]\n\n", fileObj.generatePythonRowInputArgs("row"));
    end
    SW.unindent();
    SW.unindent();

    % =========== mapPartitions (fast) ===========
    SW.pf("@staticmethod\n");
    SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
    SW.pf("# The input argument in this case is an iterator\n");
    SW.pf("# It is used as argument e.g. to mapPartition\n");
    SW.pf("def %s_iterator(iterator):\n", fileObj.funcName);
    SW.indent();
    SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
    SW.pf("rows = list(%s.%s_iterator_rows(iterator))\n", obj.WrapperClassName, fileObj.funcName);
    SW.pf("results = instance.RT.%s_iterator(rows)\n", fileObj.funcName);
    SW.pf("# results = list(iterator)\n")
    SW.pf("return iter(results)\n\n")
    SW.unindent();

    % =========== Table function ===========
    if fileObj.TableInterface
        SW.pf("@staticmethod\n");
        SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
        SW.pf("# The input argument in this case is an iterator\n");
        SW.pf("# It is used as argument e.g. to mapPartition\n");
        SW.pf("def %s_table(iterator):\n", fileObj.funcName);
        SW.indent();
        SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
        SW.pf("rows = list(%s.%s_iterator_rows(iterator))\n", obj.WrapperClassName, fileObj.funcName);
        SW.pf("results = instance.RT.%s_table(rows)\n", fileObj.funcName);
        SW.pf("# results = list(iterator)\n")
        SW.pf("return iter(results)\n\n")
        SW.unindent();
    end
    
    % =========== mapPartitions (slow) ===========
    SW.pf("@staticmethod\n");
    SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
    SW.pf("# The input argument in this case is an iterator\n");
    SW.pf("# It is used as argument e.g. to mapPartition\n");
    SW.pf("def %s_iterator_slow(iterator):\n", fileObj.funcName);
    SW.indent();
    SW.pf("for elem in iterator:\n");
    SW.indent();
    SW.pf("yield Wrapper.%s(%s)\n\n", ...
        fileObj.funcName, ...
        fileObj.generatePythonRowInputArgs("elem"));
    SW.unindent();
    SW.unindent();

end

