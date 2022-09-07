function genPartitionHelperFiles(obj, F)
    % genPartitionHelperFiles

    % Copyright 2022 The MathWorks, Inc.

    if F.TableInterface
        generateTable(obj, F);
    else
        generateSeries(obj, F);
        generateIterator(obj, F);
    end

    
end

function generateSeries(obj, F)
    funcName = F.funcName + "_series";
    fileName = funcName + ".m";
    fullFileName = fullfile(obj.GenMatlabDir, fileName);

    SW = matlab.sparkutils.StringWriter(fullFileName);

    inArgs = F.generateArgNames('in', 'IN');
    outArgs = F.generateArgNames('out', 'OUT');
    SW.pf("function [%s] = %s(%s)\n", ...
        outArgs.join(", "), ...
        funcName, ...
        inArgs.join(", "));
    SW.indent();
    SW.pf("%% %s Helper function for %s\n\n", funcName, F.funcName);

    SW.pf("N = numel(%s);\n\n", inArgs(1));

    %     SW.pf('fprintf("numel(%s): %%d\\n", N)\n', inArgs(1));
    %     SW.pf('fprintf("class(%s): %%s\\n", class(%s))\n', inArgs(1), inArgs(1));

    SW.pf('%% Initialize output arguments\n')
    for k=1:length(outArgs)
      SW.pf("%s = cell(1, N);\n", outArgs(k));
    end
    
    inArgsLoop = join(inArgs + "{k}", ", ");
    outArgsLoop = join(outArgs + "{k}", ", ");
    if F.nArgOut > 1
        outArgsLoop = "[" + outArgsLoop + "]";
    end
    SW.pf("\n");    
    SW.pf("%% Loop through inputs\n");
    
    SW.pf("for k=1:N\n");
    SW.indent();

    SW.pf("%s = %s(%s);\n", outArgsLoop, F.funcName, inArgsLoop);
    
    SW.unindent();
    SW.pf("end\n\n");

    SW.unindent();
    SW.pf("end\n")

    obj.HelperFiles(end+1) = fullFileName;

end

function generateIterator(obj, F)
    funcName = F.funcName + "_iterator";
    fileName = funcName + ".m";
    fullFileName = fullfile(obj.GenMatlabDir, fileName);

    SW = matlab.sparkutils.StringWriter(fullFileName);

    SW.pf("function OUT = %s(IN)\n", funcName)
    SW.indent();
    SW.pf("%% %s Helper function for %s\n\n", funcName, F.funcName);

    SW.pf("N = numel(IN);\n")

    SW.pf("OUT = cell(1, N);\n")
    outArgs = getArgs("out", F.nArgOut);
    inArgs = getArgs("in", F.nArgIn);
    SW.pf("for k=1:N\n");
    SW.indent();
    SW.pf("inArgs = IN{k};\n");
    if F.nArgIn > 1
        inArgsStr = "inArgs{:}";
    else
        inArgsStr = "inArgs";
    end
    if F.nArgOut > 1
        SW.pf("[%s] = %s(%s);\n", outArgs, F.funcName, inArgsStr);
        SW.pf("OUT{k} = {%s};\n", outArgs);
    else
        SW.pf("OUT{k} = %s(%s);\n", F.funcName, inArgsStr);
    end
    SW.unindent();

    SW.pf("end\n");
    SW.unindent();
    SW.pf("end\n")

    obj.HelperFiles(end+1) = fullFileName;
end

function generateTable(obj, F)
    funcName = F.funcName + "_table";
    fileName = funcName + ".m";
    fullFileName = fullfile(obj.GenMatlabDir, fileName);

    SW = matlab.sparkutils.StringWriter(fullFileName);

    SW.pf("function OUT = %s(%s)\n", funcName, F.generatePythonTableHelperArgs());
    SW.indent();
    SW.pf("%% %s Helper function for %s\n\n", funcName, F.funcName);

    SW.pf("%% We need the first entry to deduce the number of columns.\n");
    SW.pf("N = numel(IN);\n")
    SW.pf("numCols = numel(IN{1});\n\n")
    SW.pf("%% Reshape the cell array to create a table\n");
    SW.pf("reshapedCells = reshape([IN{:}], numCols, N)';\n");
    SW.pf("IN_T = cell2table(reshapedCells);\n\n");
    
    inputNames = F.InTypes(1).names;
    if isempty(inputNames)
        error('SPARK:SparkBuilder', ...
            'Table columns must have explicit names');
    else
        SW.pf("IN_T.Properties.VariableNames = ...\n");
        SW.indent();
        SW.pf('["%s"];\n', join(inputNames, '", "'));
        SW.unindent();
    end
    SW.pf("\n");

    % The conversion to rows will convert an typed array (e.g. double
    % array) to a cell array. This must be reverted here for array handling
    % to work.
    SW.pf("%% If needed, convert cell arrays to typed arrays\n");
    tArgs = F.InTypes(1).TableCols;
    for k=1:length(tArgs)
        tArg = tArgs(k);
        if ~tArg.isScalarData
            % This is an array, so we must convert it from cell to real
            % array
            SW.pf("IN_T.%s = cell2mat(IN_T.%s);\n", tArg.Name, tArg.Name);
        end
    end
    SW.pf("\n");

    % DEBUG, show IN_T
    % SW.pf('IN_T\n\n');
    % There are 2 use cases, either table output or scalar output. The
    % output data handling differs in theses cases.
    if F.TableAggregate
        SW.pf("%% Run the actual algorithm\n");

        SW.pf("OUT_C = cell(1, %d);\n", F.nArgOut);
        SW.pf("[OUT_C{:}] = %s(%s);\n\n", F.funcName, F.generatePythonTableHelperArgs("IN_T"));

        SW.pf("OUT = {OUT_C};\n")

    else
        SW.pf("%% Run the actual algorithm\n");
        SW.pf("OUT_T = %s(%s);\n\n", F.funcName, F.generatePythonTableHelperArgs("IN_T"));

        SW.pf("%% The output table may have a different number of rows\n");
        SW.pf("N_OUT = height(OUT_T);");
        SW.pf("%% Create a cell array with the same size as the table\n")
        SW.pf("OUT_C = table2cell(OUT_T);\n\n");

        SW.pf("%% Repackage the cell array in the format expected by Spark\n")
        SW.pf("OUT = cell(1, N_OUT);\n")
        SW.pf("for k=1:N_OUT\n");
        SW.indent();
        SW.pf("OUT{k} = OUT_C(k,:);\n");
        SW.unindent();
        SW.pf("end\n\n");
    end
    SW.unindent();
    SW.pf("end\n")

    obj.HelperFiles(end+1) = fullFileName;
end

function args = getArgs(prefix, num)
    fmt = sprintf("%s_%%d", prefix);
    args = arrayfun(@(x) sprintf(fmt, x), (1:num));
    args = join(args, ", ");
end