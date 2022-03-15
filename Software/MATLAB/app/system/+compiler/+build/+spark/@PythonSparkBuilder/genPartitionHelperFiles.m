function genPartitionHelperFiles(obj, F)
    % genPartitionHelperFiles

    % Copyright 2022 The MathWorks, Inc.

    if ~F.TableInterface
        generateIterator(obj, F);
    end

    if F.TableInterface
        generateTable(obj, F);
    end
    
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

    SW.pf("function OUT = %s(IN)\n", funcName)
    SW.indent();
    SW.pf("%% %s Helper function for %s\n\n", funcName, F.funcName);

    %     SW.pf("disp(IN) %% Debug stuff \n");
    SW.pf("%% We need the first entry to deduce the number of columns.\n");
    SW.pf("N = numel(IN);\n")
    SW.pf("numCols = numel(IN{1});\n\n")
    SW.pf("%% Reshape the cell array to create a table\n");
    SW.pf("reshapedCells = reshape([IN{:}], numCols, N)';\n");
    SW.pf("IN_T = cell2table(reshapedCells);\n\n");
    
    inputNames = F.getInputNameArray();
    if ~isempty(inputNames)
        SW.pf("IN_T.Properties.VariableNames = ...\n");
        SW.indent();
        SW.pf('["%s"];\n', join(inputNames, '", "'));
        SW.unindent();
    end

    SW.pf("%% Run the actual algorithm\n");
    SW.pf("OUT_T = %s(IN_T);\n\n", F.funcName);

    SW.pf("%% Create a cell array with the same size as the table\n")
    SW.pf("OUT_C = table2cell(OUT_T);\n\n");

    SW.pf("%% Repackage the cell array in the format expected by Spark\n")
    SW.pf("OUT = cell(1, N);\n")
    SW.pf("for k=1:N\n");
    SW.indent();
    SW.pf("OUT{k} = OUT_C(k,:);\n");
    SW.unindent();
    SW.pf("end\n\n");

    SW.unindent();
    SW.pf("end\n")

    obj.HelperFiles(end+1) = fullFileName;
end

function args = getArgs(prefix, num)
    fmt = sprintf("%s_%%d", prefix);
    args = arrayfun(@(x) sprintf(fmt, x), (1:num));
    args = join(args, ", ");
end