function generateFunctionWrapper(obj, SW, fileObj)
    % generateFunctionWrapper Wrapper for generating interface for one
    % function

    % Copyright 2022 The MathWorks, Inc.

    genPandasReturnTypes()

    genPlainFunction()

    genIteratorRows()

    genInputsTransformer()

    genArrayResultIterator()

    genMapPartitionsIterator()

    genMapPartitionsTable()

    genApplyInPandas()

    genMapInPandas()

    genPandasSeries()

    function genPandasReturnTypes()
        outNames = fileObj.getOutputNameArray;
        fileObj.API.outputNames = sprintf("%s_output_names", fileObj.funcName);
        SW.pf("%s = ['%s']\n", fileObj.API.outputNames, join(outNames, "', '"));
        if fileObj.TableInterface
            % We need the types that are returned as schema
            schema = fileObj.generatePythonPandasSchema();
            if useMetrics(obj, fileObj)
                % stage_id = pyspark.TaskContext().stageId()
                % task_attempt_id = pyspark.TaskContext().taskAttemptId()
                % partition_id = pyspark.TaskContext().partitionId()
                schema = schema + ...
                    ", stage_id int" + ...
                    ", task_attempt_id int" + ...
                    ", partition_id int" + ...
                    ", matlab_runtime string";
            end
            fileObj.API.outputSchema = sprintf("%s_output_schema", fileObj.funcName);
            SW.pf("%s = '%s'\n", fileObj.API.outputSchema, schema);
            SW.pf('# The next row is for backwards compatibility, and will be removed\n')
            SW.pf('# in a later release.\n');
            SW.pf("%s_pandas_schema = %s_output_schema\n", fileObj.funcName, fileObj.funcName);
        end

    end

    function genPlainFunction()
        if fileObj.TableInterface
            % The plain function and the corresponding row function have no
            % meaning for a table interface.
        else
            fileObj.API.plainMATLAB = fileObj.funcName;
            SW.pf("def %s(%s):\n", ...
                fileObj.funcName, ...
                fileObj.generatePythonInputArgs(false));
            SW.indent();
            SW.pf('""" A plain call to the MATLAB function %s """\n', fileObj.funcName);
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            SW.pf("retVal = instance.RT.%s(%s)\n\n", ...
                fileObj.funcName, ...
                fileObj.generatePythonInputArgs(true));
            SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
            SW.pf("return retVal\n\n");
            SW.unindent();

            % =========== Call function on a row ===========
            fileObj.API.map = sprintf("%s_map", fileObj.funcName);
            SW.pf("def %s(row):\n", fileObj.API.map);
            SW.indent();
            SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
            SW.pf('The input argument in this case is a Spark row\n');
            SW.pf('The row should have the same number of entries as arguments to the function. """\n');
            SW.pf("result = %s(%s)\n", ...
                fileObj.API.plainMATLAB, ...
                fileObj.generatePythonRowInputArgs("row"));
            % rList = list(result)
            % rList[0] = rList[0].tomemoryview().tolist()[0]
            % rList[1] = rList[1].tomemoryview().tolist()[0]
            % return tuple(rList)
            if fileObj.hasOutputArrays()
                SW.pf("# Handle array output\n")
                if fileObj.nArgOut > 1
                    % The output is a tuple
                    SW.pf("resultList = list(result)\n")
                    for k=1:fileObj.nArgOut
                        OO = fileObj.OutTypes(k);
                        if ~OO.isScalarData
                            % Only arrays must be changed
                            elemName = sprintf("resultList[%d]", k-1);
                            SW.pf("%s = %s\n", elemName, fileObj.convertPythonArrayOutput(elemName));                            
                        end
                    end
                    SW.pf("return tuple(resultList)\n");
                else
                    SW.pf("convertedResult = [%s]\n", fileObj.convertPythonArrayOutput("result"));
                    SW.pf("return convertedResult\n");
                end
            else
                SW.pf("return result\n");
            end
            SW.pf("\n")
            SW.unindent();
        end
    end

    function genIteratorRows()
        % =========== Helper functions to get iterator to a list of rows ===========
        fileObj.API.rowsIterator = sprintf("__%s_iterator_rows", fileObj.funcName);
        SW.pf("def %s(iterator):\n", fileObj.API.rowsIterator);
        SW.indent();
        SW.pf('""" A helper function to convert an iterator to a list for %s"""\n', fileObj.funcName);
        SW.pf("for row in iterator:\n")
        SW.indent();
        SW.pf("yield %s\n\n", fileObj.generatePythonRowIteratorArgs());
        SW.unindent();
        SW.unindent();
    end

    function genInputsTransformer()
        hasArrays = fileObj.hasInputArrays();
        if ~hasArrays
            return
        end
        fileObj.API.inputsTransformer = sprintf("__%s_inputs_transformer", fileObj.funcName);
        SW.pf("def %s(rows):\n", fileObj.API.inputsTransformer);
        SW.indent();
        SW.pf('""" If there are arrays in the input to MATLAB,\n');
        SW.pf('this cannot be translated automatically. These arrays\n');
        SW.pf('may have to be transformed first. """\n');

        % if obj.Debug
        %     SW.pf("dbgvar('rows', rows, listIgnoreLimit=1)\n")
        % end
        SW.pf("# First check row 0, to determine conversions\n");
        SW.pf("row0 = rows[0]\n");

        if isa(fileObj.InTypes(1), 'compiler.build.spark.types.Table')
            inTypes = fileObj.InTypes(1).TableCols;
        else
            inTypes = fileObj.InTypes;
        end

        newElems = string.empty;
        checks =  string.empty;
        conversionCalls = string.empty;
        for iti = 1:length(inTypes)
            rowStr = "row[" + (iti-1) + "]";
            if (inTypes(iti).isScalarData)
                newElems(iti) = rowStr;
            else
                check = "c" + (iti-1);
                SW.pf("%s = __getConversionIndex(row0[%d])\n", check, iti-1);
                checks(end+1) = check; %#ok<AGROW>
                elemName = sprintf('row_%d', iti-1);
                conversionCalls(end+1) = ...
                    sprintf("%s = __convertWithIndex(%s, %s)", ...
                    elemName, rowStr, check); %#ok<AGROW>
                newElems(iti) = elemName;
            end
        end
        elemStr = join(newElems, ", ");

        SW.pf('\n');
        SW.pf("def innerMap(row):\n");
        SW.indent();
        for ci = 1:length(checks)
            SW.pf("nonlocal %s\n", checks(ci))
        end
        for ci = 1:length(conversionCalls)
            SW.pf("%s\n", conversionCalls(ci))
        end
        SW.pf("return [%s]\n\n", elemStr);
        SW.unindent();

        SW.pf("return list(map(innerMap, rows))\n")

        SW.unindent();
        SW.pf('\n\n');

    end

    function genArrayResultIterator()
        hasArrays = fileObj.hasOutputArrays();
        if ~hasArrays
            return
        end
        if isa(fileObj.OutTypes(1), 'compiler.build.spark.types.Table')
            outTypes = fileObj.OutTypes(1).TableCols;
        else
            outTypes = fileObj.OutTypes;
        end
        fileObj.API.outputsTransformer = sprintf("__%s_results_transformer", fileObj.funcName);
        SW.pf("def %s(iterator):\n", fileObj.API.outputsTransformer);
        SW.indent();
        SW.pf('""" If there are arrays in the output from MATLAB,\n');
        SW.pf('this cannot be translated automatically. The results\n');
        SW.pf('must be iterated and converted accordingly. """\n');
        SW.pf("for row in iterator:\n")
        SW.indent();
        newElems = string.empty;
        for oti = 1:length(outTypes)
            rowStr = "row[" + (oti-1) + "]";
            if (outTypes(oti).isScalarData)
                newElems(oti) = rowStr;
            else
                newElems(oti) = sprintf("%s[0].toarray().tolist()", rowStr);
            end
        end
        elemStr = join(newElems, ", ");

        SW.pf("yield [%s]\n\n", elemStr);
        SW.unindent();
        SW.unindent();
        SW.pf('\n');

    end

    function genMapPartitionsIterator()
        % =========== mapPartitions (fast) ===========
        if ~fileObj.TableInterface
            % Don't create a simple iterator for table interfaces
            fileObj.API.mapPartitions = sprintf("%s_mapPartitions", fileObj.funcName);
            SW.pf("def %s(iterator):\n", fileObj.API.mapPartitions);
            SW.indent();
            SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
            SW.pf('The input argument in this case is an iterator\n');
            SW.pf('It is used as argument e.g. to mapPartition. """\n')
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            SW.pf("rows = list(%s(iterator))\n", fileObj.API.rowsIterator);
            SW.pf("results = instance.RT.%s_iterator(rows)\n", fileObj.funcName);
            SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
            SW.pf("return iter(results)\n\n")
            SW.unindent();
        end
    end

    function genMapPartitionsTable()
        % =========== Table function ===========
        if fileObj.TableInterface
            fileObj.API.mapPartitions = sprintf("%s_mapPartitions", fileObj.funcName);
            if fileObj.ScopedTables
                extraArgs = fileObj.generatePythonTableRestArgs;
                SW.pf("def %s(%s):\n", fileObj.API.mapPartitions, extraArgs);
                SW.indent();
                SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
                SW.pf('The input arguments in this case are the additional\n');
                SW.pf('arguments, apart from the table, that gives the scope (context)\n');
                SW.pf('of the calculation.\n');
                SW.pf('This function returns a function handle to be used by\n');
                SW.pf('a mapIteration method. """\n');
                innerName = sprintf("%s_table_inner", fileObj.funcName);
                SW.pf("def %s(iterator):\n", innerName);
                SW.indent();
                SW.pf("nonlocal %s\n", extraArgs);
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = list(%s(iterator))\n", fileObj.API.rowsIterator);
                SW.pf("results = instance.RT.%s_table(rows, %s)\n", fileObj.funcName, extraArgs);
                SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
                SW.pf("return iter(results)\n\n")
                SW.unindent();
                SW.pf("return %s\n\n", innerName);
                SW.unindent();
            else

                SW.pf("def %s(iterator):\n", fileObj.API.mapPartitions);
                SW.indent();
                SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
                SW.pf('The input argument in this case is an iterator\n');
                SW.pf('It is used as argument e.g. to mapPartition. """\n');
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = list(%s(iterator))\n", fileObj.API.rowsIterator);
                SW.pf("results = instance.RT.%s_table(rows)\n", fileObj.funcName);
                SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
                SW.pf("return iter(results)\n\n")
                SW.unindent();
            end
        end
    end

    function genApplyInPandas()
        if fileObj.TableInterface
            applyInPandasName = sprintf("%s_applyInPandas", fileObj.funcName);
            fileObj.API.applyInPandas = applyInPandasName;
            if fileObj.ScopedTables

                extraArgs = fileObj.generatePythonTableRestArgs;
                SW.pf("def %s(%s):\n", applyInPandasName, extraArgs);
                SW.indent();
                SW.pf('""" A function to be used with applyInPandas.\n');
                SW.pf('This function takes additional arguments, which create\n')
                SW.pf('a local scope for this function. """\n')
                innerName = sprintf("%s_table_inner", fileObj.funcName);
                SW.pf("def %s(pdf : pd.DataFrame):\n", innerName);
                SW.indent();
                SW.pf("nonlocal %s\n", extraArgs);
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = pdf.to_numpy().tolist()\n");
                if fileObj.hasInputArrays()
                    SW.pf("rows = %s(rows)\n", fileObj.API.inputsTransformer);
                end

                SW.pf("result = instance.RT.%s_table(rows, %s)\n", fileObj.funcName, extraArgs);
                % if obj.Debug
                %     SW.pf("dbgvar('result', result, listIgnoreLimit=1)\n")
                % end

                if fileObj.hasOutputArrays()
                    SW.pf('# There are arrays in the output, so some transformation has to occur\n');
                    SW.pf("result = %s(result)\n", fileObj.API.outputsTransformer);
                    % if obj.Debug
                    %     SW.pf("dbgvar('result-post', result, listIgnoreLimit=1)\n")
                    % end
                end
                createPandasResultFrame();
                SW.unindent();
                SW.pf("return %s\n\n", innerName);
                SW.unindent();

            else

                SW.pf("def %s(pdf : pd.DataFrame):\n", applyInPandasName);
                SW.indent();
                SW.pf('""" A function to be used with applyInPandas."""\n');
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = pdf.to_numpy().tolist()\n");
                SW.pf("result = instance.RT.%s_table(rows)\n", fileObj.funcName);
                if fileObj.hasOutputArrays()
                    SW.pf('# There are arrays in the output, so some transformation has to occur\n');
                    SW.pf("result = %s(result)\n", fileObj.API.outputsTransformer);
                end
                createPandasResultFrame();
                SW.unindent();
            end
            SW.pf('%s_pandas = %s\n\n', fileObj.funcName, applyInPandasName)
        end
    end

    function genMapInPandas()
        if fileObj.TableInterface
            %             applyInPandasName = sprintf("%s_applyInPandas", fileObj.funcName);
            applyInPandasName = fileObj.API.applyInPandas;
            mapInPandasName = sprintf("%s_mapInPandas", fileObj.funcName);
            fileObj.API.applyInPandas = mapInPandasName;
            if fileObj.ScopedTables

                extraArgs = fileObj.generatePythonTableRestArgs;
                SW.pf("def %s(%s):\n", mapInPandasName, extraArgs);
                SW.indent();
                SW.pf('""" A function to be used with mapInPandas.\n');
                SW.pf('This function takes additional arguments, which create\n')
                SW.pf('a local scope for this function. """\n')
                innerName = sprintf("%s_table_inner", fileObj.funcName);
                SW.pf("def %s(iterator):\n", innerName);
                SW.indent();
                SW.pf("nonlocal %s\n", extraArgs);
                SW.pf("func = %s(%s)\n", applyInPandasName, extraArgs);
                SW.pf("for pdf in iterator:\n");
                SW.indent();
                SW.pf("yield func(pdf)\n");
                SW.unindent();
                SW.unindent();
                SW.pf("return %s\n\n", innerName);
                SW.unindent();

            else

                SW.pf("def %s(iterator):\n", mapInPandasName);
                SW.indent();
                SW.pf('""" A function to be used with mapInPandas."""\n');
                SW.pf("for pdf in iterator:\n");
                SW.indent();
                SW.pf("yield %s(pdf)\n\n", applyInPandasName);
                SW.unindent();
                SW.unindent();
            end

        end
    end

    function genPandasSeries()
        if fileObj.PandaSeries

            inTypesStr =  join(...
                "'" + [fileObj.InTypes.PrimitiveJavaType] + "'", ...
                ", ");

            % SW.pf("@pandas_udf(%s)\n", inTypesStr);
            [inArgString, inArgs] = fileObj.generatePythonInputArgs(false);
            funcSeries = sprintf("%s_series", fileObj.funcName);
            % inArgString = join(inArgs + " : pd.Series", ", ");
            SW.pf("def %s(%s):\n", funcSeries, inArgString);
            SW.indent();
            SW.pf('""" A function to be used as a pandas_udf on a Series.\n');
            SW.pf('It can be used as a UDF, but must first be wrapped for this, e.g.\n')
            SW.pf('from pyspark.sql.functions import pandas_udf\n');
            SW.pf('from %s.wrapper import %s\n', obj.PkgName, funcSeries)
            SW.pf("@pandas_udf(%s)\n", inTypesStr);
            SW.pf('def ml_%s(%s):\n', funcSeries, inArgString)
            SW.indent();
            SW.pf('return %s(%s)\n', funcSeries, inArgString);
            SW.unindent();
            SW.pf('"""\n');
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            lInArgs = "l_" + inArgs;
            for k = 1 : length(inArgs)
                SW.pf("%s = %s.to_numpy().tolist()\n", lInArgs(k), inArgs(k));
            end
            SW.pf("result = instance.RT.%s_series(%s)\n", ...
                fileObj.funcName, lInArgs.join(", "));
            SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
            SW.pf("return pd.Series(result)\n\n");
            SW.unindent();
        end
    end

    function createPandasResultFrame()
        if useMetrics(obj, fileObj)
            SW.pf("# Add metrics to Dataframe\n");
            SW.pf("result[0].append(pyspark.TaskContext().stageId())\n");
            SW.pf("result[0].append(pyspark.TaskContext().taskAttemptId())\n");
            SW.pf("result[0].append(pyspark.TaskContext().partitionId())\n");
            SW.pf("result[0].append(hex(id(instance.RT)))\n");
        end
        SW.pf("%s.releaseInstance(instance)\n", obj.WrapperClassName);
        SW.pf("return pd.DataFrame(result)\n\n");
    end

end


