function genSparkWrappers(obj, JW)
    % genSparkWrappers File to generate helper functions in Java
    
    % Copyright 2021 MathWorks, Inc.
    
    errPrefix = "SPARK:ERROR";
    warnPrefix = "SPARK:WARNING";
    baseClassName = obj.name;
    pkgName = obj.parent.package;
    wrapperName = obj.WrapperName;
    
    JW.addImport("org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema");
    JW.addImport("org.apache.spark.sql.Row");
    JW.addImport("org.apache.spark.sql.types.StructType");
    JW.addImport("org.apache.spark.sql.types.DataTypes");
    JW.addImport("org.apache.spark.sql.Encoder");
    JW.addImport("org.apache.spark.sql.Encoders");
    JW.addImport("com.mathworks.toolbox.javabuilder.MWArray");
    JW.addImport("java.util.Iterator");
    JW.addImport("org.apache.spark.api.java.function.MapPartitionsFunction");
    JW.addImport("scala.collection.mutable.WrappedArray");
    
    useMetrics = obj.parent.Metrics;
    useDebug = obj.parent.Debug;
    numFiles = length(obj.files);
    for k=1:numFiles
        file = obj.files(k);
        % TODO:
        if file.ExcludeFromWrapper
            % This file doesn't need any wrapper functions
            continue;
        end

        % Add encoder for this files type
        if file.nArgOut > 0
            % No encoder for void / Unit
            JW.addEncoder(file.getEncoderStruct() );
        end

        generateOutputNamesConverter(JW, file);

        rowIteratorToMWCell(JW, file, baseClassName, wrapperName, useMetrics, useDebug);
        
        plainFunctionWrapper(JW, file, baseClassName);
        
        rowFunctionWrapper(JW, file); % Normal Scala map function
        
        javaMapWrapper(JW, file, wrapperName);
        
        mapPartitionsWrapper(JW, file, baseClassName, wrapperName, useMetrics);

        mapPartitionsTableWrapper(JW, file, baseClassName, wrapperName, useMetrics);
        
        filterWrapper(JW, file, wrapperName);

        foreachWrapper(JW, file);
        foreachWrapperJava(JW, file, wrapperName);
        foreachPartitionsWrapperJava(JW, file, baseClassName, wrapperName, useMetrics);
        
        udfWrapper(JW, file);
        
    end
    
    
end

function generateOutputNamesConverter(JW, file)

    SW = JW.newMethod();
    %     public static Dataset normalizeStuff_setOutputTypes(Dataset df) {
    %         return df.toDF("Time_sec","VehicleID","CmdCurrent","EngineSpeed");
    %     }
    SW.pf('/** Helper method to set the correct output names after a map/mapPartitions method.\n');
    SW.pf('*/\n');
    file.API.setOutputNames = sprintf('%s_setOutputNames', file.funcName);
    SW.pf('public static Dataset<Row> %s(Dataset<Row> ds) {\n', file.API.setOutputNames);
    SW.indent();
    outNames = file.getOutputNameArray;
    outNameStr = join(arrayfun(@(x) """" + x + """", outNames, 'UniformOutput', true), ", ");
    SW.pf("return ds.toDF(%s);\n", outNameStr);
    SW.unindent();
    SW.pf('}\n');

    JW.addMethod(SW);
end

function rowIteratorToMWCell(JW, file, baseClassName, wrapperName, useMetrics, useDebug)
    SW = JW.newMethod();
    
    file.API.rowIteratorToMWCell = sprintf("rowIteratorToMWCell_%s", file.funcName);

    SW.pf("/** Iterate over a set of rows to create a MWCellArray of the contents\n");
    SW.pf(" * This method will take an Iterator for a Spark Row object, and create\n");
    SW.pf(" * a MATLAB Cell array, containing all the entries.\n");
    SW.pf(" * It is specific for a particular MATLAB function, as it will need knowledge\n");
    SW.pf(" * about MATLAB data types\n");
    SW.pf(" * @param rowIterator An iterator for a Spark Row object\n");
    SW.pf(" * @param instance An instance of the base class, %s\n", baseClassName);
    SW.pf(" * @return a MATLAB Cell array\n");
    SW.pf(" */\n");
    SW.pf("public static com.mathworks.extern.java.MWCellArray %s(Iterator<Row> rowIterator, %s instance) {\n", ...
        file.API.rowIteratorToMWCell, baseClassName);
    SW.indent();
    SW.pf('com.mathworks.extern.java.MWCellArray mwCell = null;\n');
    if useDebug
        SW.pf('log("%s:instance: " + instance);\n', file.API.rowIteratorToMWCell);
    end
    if useMetrics
        SW.pf('long lastTic;\n');
    end

    SW.pf('/* The rowIterator is an iterator of the rows contained in this partition.\n');
    SW.pf('* In the loop, the entries of each row will be converted to corresponding\n');
    SW.pf('* MW array values, and the entries will be placed in a MW cell array.\n');
    SW.pf('* Each of these cell arrays will be added to a list of type MWArray\n');
    SW.pf('*/\n');
    if useMetrics
        SW.pf('lastTic = tic("rowIterator");\n');
    end
    if file.TableInterface
        caVec = file.InTypes(1).TableCols;

    else
        caVec = file.InTypes;
    end
    numCols = length(caVec);
    SW.pf('int numCols = %d;\n', numCols);
    SW.pf('ArrayList<Row> sparkRows = new ArrayList<Row>();\n');
    SW.pf('while (rowIterator.hasNext()) {\n');
    SW.indent();
    SW.pf('sparkRows.add(rowIterator.next());\n');

    SW.unindent();
    SW.pf('}\n');
    if useMetrics
        SW.pf('toc("rowIterator", lastTic);\n');
    end
    SW.pf('/* Create a cell array with the rows and columns */\n');
    SW.pf('int numRows = sparkRows.size();\n');
    if useMetrics
        SW.pf('lastTic = tic("convertToRows, " + numRows + " rows");\n');
    end
    SW.pf('mwCell = new com.mathworks.extern.java.MWCellArray(numRows, numCols);\n');
    SW.pf('int[] idx = new int[2];\n');
    SW.pf('for (int k=0; k<numRows; k++) {\n');
    SW.indent();

    SW.pf('java.util.List<Object> args = rowToJavaList(sparkRows.get(k));\n')
    SW.pf('idx[0] = k + 1;\n');
    
    for ka = 1:numCols
        CA = caVec(ka);
        SW.pf('idx[1] = %d;\n', ka);
        SW.pf("mwCell.set(idx, %s);\n", ...
            ...CA.instantiateMWValue(sprintf("args.get(%d)", ka-1), ...
            CA.getBoxedJavaValue(sprintf("args.get(%d)", ka-1), ...
            true ... Cast arguments explicitly
            ));
    end

    SW.unindent();
    SW.pf('}\n');
    if useMetrics
        SW.pf('toc("convertToRows, " + numRows + " rows", lastTic);\n');
    end
    
    SW.pf('return mwCell;\n');
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
end

function plainFunctionWrapper(JW, file, baseClassName)
    if file.TableInterface
        % Don't create plain method for table interface
        return
    end
    retType = file.getReturnType;
    inArgNames = file.generateArgNames('in', 'arg');
    inMWArgNames = file.generateArgNames('in', 'marg');
    retValNames = file.generateArgNames('out', 'ret');
    inArgTypes = file.InTypes.getFuncArgTypes;
    retArgTypes = file.OutTypes.getReturnTypes;
    
    % First, write plain method
    SW = JW.newMethod();
    funcName = file.funcName;
    SW.pf("/** \n");
    SW.pf(" * This is a 'plain' version of the function we've generated.\n");
    SW.pf(" * It can be called with 'plain' arguments, like double/int/etc.,\n");
    SW.pf(" * and the connection with the runtime will be handled automatically.\n");
    for k=1:file.nArgIn
        SW.pf(" * @param %s Argument #%d\n", inArgNames(k), k);
    end
    if file.nArgOut > 0
        SW.pf(" * @return See source MATLAB function for explanation.\n");
    end
    SW.pf(" */\n");
    %         file.writeMethodComment(funcName, SW);
    
    funcSignature = join( ...
        ... Strings
        arrayfun(@(T, A) T + " " + A, inArgTypes, inArgNames), ...
        ... Join with comma
        ", ");
    
    SW.pf("public static %s %s(%s) {\n", retType, funcName, funcSignature);
    SW.indent();
    
    % Declare variables
    for ka = 1:file.nArgIn
        CA = file.InTypes(ka);
        SW.pf("%s %s = null;\n", CA.getMWArgType, inMWArgNames(ka));
    end
    if file.nArgOut > 0
        SW.pf("%s retVal = null;\n", file.getReturnType());
    end
    
    % Make the function call in try/catch
    SW.pf("%s instance = null;\n", baseClassName);
    SW.pf("try {\n");
    SW.indent();
    SW.pf("instance = getInstance();\n");
    SW.pf("/* Instantiate MW variables from function arguments */\n");
    for ka = 1:file.nArgIn
        CA = file.InTypes(ka);
        SW.pf("%s = %s;\n", ...
            inMWArgNames(ka), CA.instantiateMWValue(inArgNames(ka)));
    end
    if file.nArgOut == 0
        SW.pf("instance.%s(%s);\n\n", ...
            file.funcName, inMWArgNames.join(", "));
    else
        SW.pf("Object[] ret = instance.%s(%d, %s);\n\n", ...
            file.funcName, file.nArgOut, inMWArgNames.join(", "));
    end
    for ka = 1:file.nArgOut
        CA = file.OutTypes(ka);
        SW.pf("%s %s = %s;\n", ...
            retArgTypes(ka), retValNames(ka), ...
            CA.convertMWToRetValue(sprintf("ret[%d]", ka-1)))
    end
    if file.nArgOut ==0
        SW.pf("/* No return value */\n");
    elseif file.nArgOut == 1
        SW.pf("retVal = %s;\n", retValNames(1));
    else
        SW.pf("retVal = new %s(%s);\n", retType, retValNames.join(", "));
    end
    
    SW.unindent();
    SW.pf("}\n");
    SW.pf("catch ( MWException mwex) {\n");
    SW.indent();
    SW.pf("System.out.println(mwex.getMessage());\n");
    SW.pf("mwex.printStackTrace();\n");
    SW.unindent();
    SW.pf("} finally {\n");
    SW.indent();
    dispTypes = inMWArgNames;
    for dt = 1:length(dispTypes)
        SW.pf("MWArray.disposeArray(%s);\n", dispTypes(dt));
    end
    SW.pf("/* TODO: Dispose of ret too, as it really contains MW variables? */\n");
    SW.pf("releaseInstance(instance);\n")
    SW.unindent();
    SW.pf("}\n");
    if file.nArgOut > 0
        SW.pf("return retVal;\n");
    else
        SW.pf("return;\n");
    end
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    
end

function rowFunctionWrapper(JW, file)
    if file.nArgOut == 0
        % No map possible without out arguments
        return;
    end
    if file.TableInterface
        % Don't create normal row/map method for table interface
        return
    end
    SW = JW.newMethod();
    retType = file.getReturnType();
    inArgNames = file.generateArgNames('in', 'arg');
    
    SW.pf("/**\n");
    SW.pf(" * This function will be executed on a Spark Row as input\n");
    SW.pf(" * It is used directly when doing a Dataset.map in Scala\n");
    SW.pf(" * @param row A Spark Row\n");
    SW.pf(" * @return the result of the calculation (in Tuple if several return values)\n");
    SW.pf(" */\n");
    SW.pf("public static %s %s(Row row) {\n", retType, file.funcName);
    SW.indent();
    SW.pf("java.util.List<Object> args = rowToJavaList(row);\n");
    for ka = 1:file.nArgIn
        CA = file.InTypes(ka);
        SW.insertLines(CA.declareAndSetRowValue( ...
            sprintf("args.get(%d)", ka-1), inArgNames(ka)));
    end
    SW.pf("return %s(%s);\n", file.funcName, inArgNames.join(", "));
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
end

function javaMapWrapper(JW, file, wrapperName)
    if file.nArgOut == 0
        % No map possible without out arguments
        return;
    end

    if file.TableInterface
        % Don't create normal mapPartition method for table interface
        return
    end

    retType = file.getReturnType();
    
    JW.addImport("org.apache.spark.api.java.function.MapFunction");
    SW = JW.newMethod();
    SW.pf("/** Function: %s\n", file.funcName);
    SW.pf(" * This function is used directly when doing a Dataset.map in Java \n");
    SW.pf(" * To call it in Java, it will also need an encoder. This encoder is generated\n");
    SW.pf(" * as a static property of this class, e.g.\n");
    SW.pf(" *    myDataset.map(%s.%s, %s.%s_encoder);\n", ...
        wrapperName, file.funcName, wrapperName, file.funcName);
    SW.pf(" * @return MapFunction with correct template type\n")
    SW.pf(" */\n");
    SW.pf("public static MapFunction<Row, %s> %s() {\n", retType, file.funcName);
    SW.indent();
    SW.pf("return new MapFunction<Row, %s>() {\n", retType);
    SW.indent();
    SW.pf("@Override public %s call(Row arg) {\n", retType);
    SW.indent();
    SW.pf("return %s(arg);\n", file.funcName);
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("};\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
end

function mapPartitionsWrapper(JW, file, baseClassName, wrapperName, useMetrics)
    if file.nArgOut == 0
        % No mapPartition possible without out arguments
        return;
    end
    if file.TableInterface
        % Don't create normal mapPartition method for table interface
        return
    end
    
    retType = file.getReturnType();
    %     inArgNames = file.generateArgNames('in', 'arg');
    %     inMWArgNames = file.generateArgNames('in', 'marg');
    retValNames = file.generateArgNames('out', 'ret');
    inArgTypes = file.InTypes.getFuncArgTypes;
    retArgTypes = file.OutTypes.getReturnTypes;
    
    mapFuncName = file.funcName + "_mapPartitions";
    
    
    SW = JW.newMethod();
    SW.pf("/** Java version of mapPartitions for %s\n", file.funcName);
    SW.pf(" * This function is used directly when doing a Dataset.mapPartitions in Java \n");
    SW.pf(" * To call it in Java, it will also need an encoder. This encoder is generated\n");
    SW.pf(" * as a static property of this class, e.g.\n");
    SW.pf(" *    myDataset.mapPartitions(%s.%s(), %s.%s_encoder);\n", ...
        wrapperName, mapFuncName, wrapperName, file.funcName);
    SW.pf(" * @return MapPartitionsFunction with correct template type\n")
    SW.pf(" */\n");
    SW.pf("public static MapPartitionsFunction<Row, %s> %s() {\n", retType, mapFuncName);
    SW.indent();
    SW.pf("return new MapPartitionsFunction<Row, %s>() {\n", retType);
    SW.indent();
    SW.pf("@Override public Iterator<%s> call(Iterator<Row> inputIterator) {\n", retType);
    SW.indent();
    SW.pf('com.mathworks.extern.java.MWCellArray mwCell = null;\n');
    SW.pf("ArrayList<%s> retList = new ArrayList<%s>();\n", retType, retType);
    if useMetrics
        SW.pf('long lastTic;\n');
    end
    
    SW.pf("%s instance = null;\n", baseClassName);
    SW.pf("try {\n");
    SW.indent();
    SW.pf("instance = getInstance();\n");
    SW.pf('mwCell = %s(inputIterator, instance);\n', file.API.rowIteratorToMWCell);

    SW.pf("int[] dims = mwCell.getDimensions();\n")
    SW.pf("int sz = dims[0];\n");
    SW.pf("Object[] ret = null;\n");
    SW.pf("/* Call the partition function with these rows.\n");
    SW.pf(" * The partition function is a helper function that was generated\n");
    SW.pf(" * by the SparkBuilder. */\n");
    
    
    if useMetrics
        SW.pf('lastTic = tic("%s_partition");\n', file.funcName);
    end
    SW.pf("ret = instance.%s_partition(1, mwCell);\n\n", file.funcName);
    if useMetrics
        SW.pf('toc("%s_partition", lastTic);\n', file.funcName);
    end
    
    if useMetrics
        SW.pf('lastTic = tic("output collection");\n');
    end
    
    SW.pf("MWCellArray mwRet = (MWCellArray) (ret[0]);\n");
    
    % Put return values in ArrayList
    SW.pf("for (int k=0; k<sz; k++) {\n");
    SW.indent();
    if file.nArgOut == 1
        CA = file.OutTypes;
        SW.pf("%s mTmp = (%s) mwRet.getCell(k+1);\n", CA.MWType, CA.MWType);
        SW.pf("%s %s = %s;\n", CA.getReturnType, retValNames, CA.convertMWToRetValue("mTmp"));
        SW.pf("retList.add(%s);\n", retValNames);
    else
        SW.pf("MWCellArray cEntry = (MWCellArray) mwRet.getCell(k+1);\n");
        for ka = 1:file.nArgOut
            CA = file.OutTypes(ka);
            SW.pf("%s %s = %s;\n", CA.getReturnType, retValNames(ka), ...
                CA.convertMWToRetValue(sprintf("(cEntry.getCell(%d))", ka)));
        end
        SW.pf("retList.add(new %s(%s));\n", retType, retValNames.join(", "));
    end
    
    SW.unindent();
    SW.pf("}\n");
    if useMetrics
        SW.pf('toc("output collection", lastTic);\n');
    end
    
    SW.unindent();
    SW.pf("} catch ( MWException mwex) {\n");
    SW.indent();
    SW.pf("System.out.println(mwex.getMessage());\n");
    SW.pf("mwex.printStackTrace();\n");
    SW.unindent();
    SW.pf("} finally {\n");
    SW.indent();
    SW.pf("MWArray.disposeArray(mwCell);\n");
    SW.pf("releaseInstance(instance);\n");

    SW.unindent();
    SW.pf("} // try\n");
    
    SW.pf("return retList.iterator();\n");
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("};\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
end

function mapPartitionsTableWrapper(JW, file, baseClassName, wrapperName, useMetrics)
    
    if ~file.TableInterface
        % Create this specific mapPartition method only for table interface
        return
    end
    
    retType = file.getReturnType();
    mapFuncName = file.funcName + "_mapPartitions";
    SW = JW.newMethod();
    typedArgs = file.generateJavaTableTypeHelperArgs();
    SW.pf("public static MapPartitionsFunction<Row, %s> %s(%s) {\n", ...
        retType, mapFuncName, typedArgs);
    SW.indent();
    SW.pf("return new MapPartitionsFunction<Row, %s>() {\n", retType);
    SW.indent();
    SW.pf("@Override public Iterator<%s> call(Iterator<Row> inputIterator) {\n", retType);
    SW.indent();
    SW.pf("ArrayList<%s> retList = new ArrayList<%s>();\n", retType, retType);
    SW.pf('com.mathworks.extern.java.MWCellArray mwCell = null;\n');
    if useMetrics
        SW.pf('long lastTic;\n');
    end
    % Add local variables for the case when we have additional arguments
    % Declare variables
    inMWArgNames = file.generateNameList("marg", file.nArgIn-1);
    inArgNames = file.generateNameList("arg", file.nArgIn-1);
    mwArgString = inMWArgNames.join(", ");
    if ~isempty(mwArgString)
        mwArgString = ", " + mwArgString;
    end
    for ka = 2:file.nArgIn
        CA = file.InTypes(ka);
        SW.pf("%s %s = null;\n", CA.getMWArgType, inMWArgNames(ka-1));
    end

    SW.pf("%s instance = null;\n", baseClassName);
    SW.pf("try {\n");
    SW.indent();
    SW.pf("instance = getInstance();\n");

    SW.pf("/* Instantiate MW additional variables from function arguments */\n");
    for ka = 2:file.nArgIn
        CA = file.InTypes(ka);
        SW.pf("%s = %s;\n", ...
            inMWArgNames(ka-1), CA.instantiateMWValue(inArgNames(ka-1)));
    end

    if useMetrics
        SW.pf('lastTic = tic("%s");\n', file.API.rowIteratorToMWCell);
    end

    SW.pf('mwCell = %s(inputIterator, instance);\n', file.API.rowIteratorToMWCell);
    if useMetrics
        SW.pf('toc("%s", lastTic);\n', file.API.rowIteratorToMWCell);
    end

    if useMetrics
        SW.pf('lastTic = tic("instance.%s_table");\n', file.funcName);
    end
    SW.pf('Object[] objResult = instance.%s_table(1, mwCell%s);\n', ...
        file.funcName, mwArgString);
    if useMetrics
        SW.pf('toc("instance.%s_table", lastTic);\n\n', file.funcName);
    end

    if useMetrics
        SW.pf('lastTic = tic("MWData->Spark - %s_partition");\n', file.funcName);
    end
    SW.pf('MWCellArray result = (MWCellArray) objResult[0];\n\n');
    
    SW.pf('int[] resultDims = result.getDimensions();\n');
    SW.pf('int numRows = resultDims[0];\n');
    SW.pf('int[] idx = new int[2];\n');
    SW.pf('for (int k=0; k<numRows; k++) {\n');
    SW.indent();
    SW.pf('idx[0] = k + 1;\n');

%     retValNames = file.generateArgNames('out', 'ret');
    if file.TableInterface
        if isa(file.OutTypes(1), 'compiler.build.spark.types.Table')
            caVec = file.OutTypes.TableCols;
        else
            caVec = file.OutTypes;
        end
    else
        caVec = file.OutTypes;
    end
    numOut = length(caVec);
    retValNames = file.generateNameList('ret', numOut);
    for ka = 1:numOut
        CA = caVec(ka);
        SW.pf('idx[1] = %d;\n', ka);
        SW.pf("%s %s = %s;\n", ...
            CA.getReturnType, retValNames(ka), ...
            CA.convertMWToRetValue("result.getCell(idx)"));
    end
    if numOut == 1
        SW.pf("retList.add(%s);\n", retValNames);
    else
        SW.pf("retList.add(new %s(%s));\n", ...
            file.getReturnType, retValNames.join(", "));
    end
    
    SW.unindent();
    SW.pf('}\n');
    if useMetrics
        SW.pf('toc("MWData->Spark - %s_partition", lastTic);\n', file.funcName);
    end
    
    SW.unindent();
    SW.pf("} catch ( MWException mwex) {\n");
    SW.indent();
    SW.pf("System.out.println(mwex.getMessage());\n");
    SW.pf("mwex.printStackTrace();\n");
    SW.unindent();
    SW.pf("} finally {\n");
    SW.indent();
    SW.pf("MWArray.disposeArray(mwCell);\n");
%     SW.pf("MWArray.disposeArray(mwRows);\n");
    SW.pf("releaseInstance(instance);\n")

    SW.unindent();
    SW.pf("} // try\n");

    SW.pf("return retList.iterator();\n");
    SW.unindent();
    SW.pf("}\n");

    SW.unindent();
    SW.pf("};\n");

    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
end

function filterWrapper(JW, file, wrapperName)
    if file.TableInterface
        % Don't create filter method for table interface
        return
    end
    
    if file.nArgOut == 1 && file.OutTypes.JavaType == "Boolean"
        % Only generate wrapper for single return value of Boolean type
        
        JW.addImport("org.apache.spark.api.java.function.FilterFunction");
        SW = JW.newMethod();
        filterName = file.funcName + "_filter";
        SW.pf("//* Function: %s\n", filterName);
        SW.pf("// This function is used directly when doing a Dataset.filter in Java \n");
        SW.pf("//    myDataset.filter(%s.%s);\n", ...
            wrapperName, filterName);
        SW.pf("public static FilterFunction<Row> %s() {\n", filterName);
        SW.indent();
        SW.pf("return new FilterFunction<Row>() {\n");
        SW.indent();
        SW.pf("@Override public boolean call(Row arg) {\n");
        SW.indent();
        SW.pf("return %s(arg);\n", file.funcName);
        SW.unindent();
        SW.pf("}\n");
        SW.unindent();
        SW.pf("};\n");
        SW.unindent();
        SW.pf("}\n");
        JW.addMethod(SW);
    end
    
end


function foreachWrapper(JW, file)
    if file.nArgOut > 0
        % Foreach is for functions without return values.
        % TODO: Consider allowing normal methods, but ignoring their return
        % values.
        return;
    end

    funcName = file.funcName;
    inArgNames = file.generateArgNames('in', 'arg');

    SW = JW.newMethod();
    SW.pf("/** Scala foreach function for %s\n", funcName);
    SW.pf(" * @param row A Spark row\n");
    SW.pf(" */\n");
    SW.pf("public static void %s(Row row) {\n", funcName);
    SW.indent();
    SW.pf("java.util.List<Object> args = rowToJavaList(row);\n");
    for ka = 1:file.nArgIn
        CA = file.InTypes(ka);
        SW.insertLines(CA.declareAndSetRowValue( ...
            sprintf("args.get(%d)", ka-1), inArgNames(ka)));
    end
    SW.pf("%s(%s);\n", file.funcName, inArgNames.join(", "));
    SW.unindent();
    SW.pf("} \n")
    JW.addMethod(SW);
    
end

function foreachWrapperJava(JW, file, wrapperName)
    if file.nArgOut > 0
        % Foreach is for functions without return values.
        % TODO: Consider allowing normal methods, but ignoring their return
        % values.
        return;
    end


    JW.addImport("org.apache.spark.api.java.function.ForeachFunction");

    funcName = file.funcName + "_foreach";
    SW = JW.newMethod();
    SW.pf("/** Java version of foreach for %s\n", file.funcName);
    SW.pf(" * This function is used directly when doing a Dataset.foreach in Java, e.g. \n");
    SW.pf(" *    myDataset.foreach(%s.%s());\n", ...
        wrapperName, funcName);
    SW.pf(" */\n");
    SW.pf("public static ForeachFunction<Row> %s() {\n", funcName);
    SW.indent();
    SW.pf("return new ForeachFunction<Row>() {\n");
    SW.indent();
    SW.pf("@Override public void call(Row row) {\n");
    SW.indent();
    SW.pf("%s(row);\n", file.funcName);
    
    SW.unindent();
    SW.pf("}\n");
    
    SW.unindent();
    SW.pf("};\n");
    SW.unindent();
    SW.pf("}\n");

    JW.addMethod(SW);
    
end


function foreachPartitionsWrapperJava(JW, file, baseClassName, wrapperName, useMetrics)
    if file.nArgOut > 0
        % Foreach is for functions without return values.
        % TODO: Consider allowing normal methods, but ignoring their return
        % values.
        return;
    end


    JW.addImport("org.apache.spark.api.java.function.ForeachPartitionFunction");

    funcName = file.funcName + "_foreachPartition";
    SW = JW.newMethod();
    SW.pf("/** Java version of foreachPartition for %s\n", file.funcName);
    SW.pf(" * This function is used directly when doing a Dataset.foreachin Java, e.g. \n");
    SW.pf(" *    myDataset.foreachPartition(%s.%s());\n", ...
        wrapperName, funcName);
    SW.pf(" */\n");
    SW.pf("public static ForeachPartitionFunction<Row> %s() {\n", funcName);
    SW.indent();
    SW.pf("return new ForeachPartitionFunction<Row>() {\n");
    SW.indent();
    SW.pf("@Override public void call(Iterator<Row> rowIterator) {\n");
    SW.indent();
    SW.pf('com.mathworks.extern.java.MWCellArray mwCell = null;\n');
    if useMetrics
        SW.pf('long lastTic;\n');
    end

    %     SW.pf("ArrayList<%s> retList = new ArrayList<%s>();\n", retType, retType);

    SW.pf("%s instance = null;\n", baseClassName);
    SW.pf("try {\n");
    SW.indent();
    SW.pf("instance = getInstance();\n");
    SW.pf('mwCell = %s(rowIterator, instance);\n', file.API.rowIteratorToMWCell);

    SW.pf("/* Call the partition function with these rows.\n");
    SW.pf(" * The partition function is a helper function that was generated\n");
    SW.pf(" * by the SparkBuilder. */\n");
    
    if useMetrics
        SW.pf('lastTic = tic("%s_partition");\n', file.funcName);
    end
    SW.pf("instance.%s_partition(mwCell);\n\n", file.funcName);
    if useMetrics
        SW.pf('toc("%s_partition", lastTic);\n', file.funcName);
    end
    
    SW.unindent();
    SW.pf("} catch ( MWException mwex) {\n");
    SW.indent();
    SW.pf("System.out.println(mwex.getMessage());\n");
    SW.pf("mwex.printStackTrace();\n");
    SW.unindent();
    SW.pf("} finally {\n");
    SW.indent();
    SW.pf("MWArray.disposeArray(mwCell);\n");
    SW.pf("releaseInstance(instance);\n")
    SW.unindent();
    SW.pf("} // try\n");
    
    SW.pf("return;\n");
    
    SW.unindent();
    SW.pf("}\n");
    
    SW.unindent();
    SW.pf("};\n");
    SW.unindent();
    SW.pf("}\n");

    JW.addMethod(SW);



    
%     JW.addMethod(SW);
end

function udfWrapper(JW, file)
    if file.nArgOut == 0
        % No UDF possible without out arguments
        return;
    end

    if file.TableInterface
        % Don't create udf methods for table interface
        return
    end
    retType = file.getReturnType;
    inArgNames = file.generateArgNames('in', 'arg');
    inMWArgNames = file.generateArgNames('in', 'marg');
    retValNames = file.generateArgNames('out', 'ret');
    inArgTypes = file.InTypes.getFuncArgTypes;
    retArgTypes = file.OutTypes.getReturnTypes;
    
    [udfName, udfType, callTypes, UDF] = file.getUDFInfo();
    % UDF
    
    JW.addImport(sprintf("org.apache.spark.sql.api.java.%s", UDF.FuncName));
    
    SW = JW.newMethod();
    funcName = "reg_" + file.funcName + "_udf";
    SW.pf("/** Function: %s\n", funcName);
    SW.pf(" * Register a UDF for the function %s\n", file.funcName);
    SW.pf(" * @param spark A SparkSession instance\n");
    SW.pf(" * @param udfName The name to give the UDF\n");
    SW.pf(" */\n");
    
    SW.pf("public static void %s(SparkSession spark, String udfName) {\n", funcName);
    SW.indent();
    [outSparkType, outSparkTypeDefinition] = getOutSparkType(file);
    if strlength(outSparkTypeDefinition) > 0
        JW.addImport("org.apache.spark.sql.types.StructField");
        SW.insertLines(outSparkTypeDefinition);
    end
    SW.pf("spark.udf().register(udfName, new %s() {\n", udfType);
    SW.indent();
    SW.pf("@Override\n");
    funcSignature = join( ...
        ... Strings
        arrayfun(@(T, A) T + " " + A, callTypes, inArgNames), ...
        ... Join with comma
        ", ");
    SW.pf("public %s call(%s) {\n", file.getReturnType, funcSignature);
    SW.indent();
    for k=1:file.nArgIn
        if ~isempty(UDF.ConvCode(k))
            SW.insertLines(UDF.ConvCode(k));
        end
    end
    SW.pf("return %s(%s);\n", file.funcName, UDF.ConvArgs.join(", "));
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("}, %s);\n", outSparkType);
    
    SW.unindent();
    SW.pf("}\n");
    
    JW.addMethod(SW);
    
    % ================================================================
    SW = JW.newMethod();
    funcName = "reg_" + file.funcName + "_udf";
    SW.pf("/** Function: %s\n", funcName);
    SW.pf(" * Register a UDF for the function %s\n", file.funcName);
    SW.pf(" * The registered name will be the same name as the function\n");
    SW.pf(" * itself, i.e. %s\n", file.funcName);
    SW.pf(" * @param spark A SparkSession instance\n");
    SW.pf(" */\n");
    
    SW.pf("public static void %s(SparkSession spark) {\n", funcName);
    SW.indent();
    SW.pf("%s(spark, ""%s"");\n", funcName, file.funcName);
    SW.unindent();
    SW.pf("}\n");
    
    JW.addMethod(SW);
end


