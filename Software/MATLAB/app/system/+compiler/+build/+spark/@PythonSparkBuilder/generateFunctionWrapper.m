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
    SW.pf("yield %s\n\n", fileObj.generatePythonRowIteratorArgs());
    SW.unindent();
    SW.unindent();

    % =========== mapPartitions (fast) ===========
    if ~fileObj.TableInterface
        % Don't create a simple iterator for table interfaces
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
    end
    % =========== Table function ===========
    if fileObj.TableInterface
        if fileObj.ScopedTables
            SW.pf("@staticmethod\n");
            SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
            SW.pf("# The input arguments in this case are the additional\n");
            SW.pf("# arguments, apart from the table, that gives the scope (context)\n");
            SW.pf("# of the calculation.\n");
            SW.pf("# This function returns a function handle to be used by\n");
            SW.pf("# a mapIteration method.\n");
            extraArgs = fileObj.generatePythonTableRestArgs;
            SW.pf("def %s_table(%s):\n", fileObj.funcName, extraArgs);
            SW.indent();
            innerName = sprintf("%s_table_inner", fileObj.funcName);
            SW.pf("def %s(iterator):\n", innerName);
            SW.indent();
            SW.pf("nonlocal %s\n", extraArgs);
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            SW.pf("rows = list(%s.%s_iterator_rows(iterator))\n", obj.WrapperClassName, fileObj.funcName);
            SW.pf("results = instance.RT.%s_table(rows, %s)\n", fileObj.funcName, extraArgs);
            SW.pf("# results = list(iterator)\n")
            SW.pf("return iter(results)\n\n")
            SW.unindent();
            SW.pf("return %s\n\n", innerName);
            SW.unindent();
        else
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
    end
    
    % =========== mapPartitions (slow) ===========
    % Don't do this anymore. It's the poor man's version, not used anymore,
    % since very slow.
    % SW.pf("@staticmethod\n");
    % SW.pf("# A call to the MATLAB function %s\n", fileObj.funcName);
    % SW.pf("# The input argument in this case is an iterator\n");
    % SW.pf("# It is used as argument e.g. to mapPartition\n");
    % SW.pf("def %s_iterator_slow(iterator):\n", fileObj.funcName);
    % SW.indent();
    % SW.pf("for elem in iterator:\n");
    % SW.indent();
    % SW.pf("yield Wrapper.%s(%s)\n\n", ...
    %     fileObj.funcName, ...
    %     fileObj.generatePythonRowInputArgs("elem"));
    % SW.unindent();
    % SW.unindent();

end

