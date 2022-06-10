function generateFunctionWrapper(obj, SW, fileObj)
    % generateFunctionWrapper Wrapper for generating interface for one
    % function

    % Copyright 2022 The MathWorks, Inc.

    genPandasReturnTypes()

    genPlainFunction()

    genIteratorRows()

    genMapPartitionsIterator()

    genMapPartitionsTable()

    genPandasTable()

    genPandasSeries()

    function genPandasReturnTypes()
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
            SW.pf("%s_pandas_schema = '%s'\n", fileObj.funcName, schema);
        end

    end

    function genPlainFunction()
        if fileObj.TableInterface
            % The plain function and the corresponding row function have no
            % meaning for a table interface.
        else
            % SW.pf("@staticmethod\n");
            SW.pf("def %s(%s):\n", ...
                fileObj.funcName, ...
                fileObj.generatePythonInputArgs(false));
            SW.indent();
            SW.pf('""" A plain call to the MATLAB function %s """\n', fileObj.funcName);
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            SW.pf("return instance.RT.%s(%s)\n\n", ...
                fileObj.funcName, ...
                fileObj.generatePythonInputArgs(true));
            SW.unindent();

            % =========== Call function on a row ===========
            % SW.pf("@staticmethod\n");
            SW.pf("def %s_rows(row):\n", fileObj.funcName);
            SW.indent();
            SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
            SW.pf('The input argument in this case is a Spark row\n');
            SW.pf('The row should have the same number of entries as arguments to the function. """\n');
            SW.pf("return %s(%s)\n\n", ...
                fileObj.funcName, ...
                fileObj.generatePythonRowInputArgs("row"));
            SW.unindent();
        end
    end

    function genIteratorRows()
        % =========== Helper functions to get iterator to a list of rows ===========
        % SW.pf("@staticmethod\n");
        SW.pf("def %s_iterator_rows(iterator):\n", fileObj.funcName);
        SW.indent();
        SW.pf('""" A helper function to convert an iterator to a list for %s"""\n', fileObj.funcName);
        SW.pf("for row in iterator:\n")
        SW.indent();
        SW.pf("yield %s\n\n", fileObj.generatePythonRowIteratorArgs());
        SW.unindent();
        SW.unindent();
    end

    function genMapPartitionsIterator()
        % =========== mapPartitions (fast) ===========
        if ~fileObj.TableInterface
            % Don't create a simple iterator for table interfaces
            % SW.pf("@staticmethod\n");
            SW.pf("def %s_iterator(iterator):\n", fileObj.funcName);
            SW.indent();
            SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
            SW.pf('The input argument in this case is an iterator\n');
            SW.pf('It is used as argument e.g. to mapPartition. """\n')
            SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
            SW.pf("rows = list(%s_iterator_rows(iterator))\n", fileObj.funcName);
            SW.pf("results = instance.RT.%s_iterator(rows)\n", fileObj.funcName);
            SW.pf("return iter(results)\n\n")
            SW.unindent();
        end
    end

    function genMapPartitionsTable()
        % =========== Table function ===========
        if fileObj.TableInterface
            if fileObj.ScopedTables
                % SW.pf("@staticmethod\n");
                extraArgs = fileObj.generatePythonTableRestArgs;
                SW.pf("def %s_table(%s):\n", fileObj.funcName, extraArgs);
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
                SW.pf("rows = list(%s_iterator_rows(iterator))\n", fileObj.funcName);
                SW.pf("results = instance.RT.%s_table(rows, %s)\n", fileObj.funcName, extraArgs);
                SW.pf("# results = list(iterator)\n")
                SW.pf("return iter(results)\n\n")
                SW.unindent();
                SW.pf("return %s\n\n", innerName);
                SW.unindent();
            else
                % SW.pf("@staticmethod\n");
                SW.pf("def %s_table(iterator):\n", fileObj.funcName);
                SW.indent();
                SW.pf('""" A call to the MATLAB function %s\n', fileObj.funcName);
                SW.pf('The input argument in this case is an iterator\n');
                SW.pf('It is used as argument e.g. to mapPartition. """\n');
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = list(%s_iterator_rows(iterator))\n", fileObj.funcName);
                SW.pf("results = instance.RT.%s_table(rows)\n", fileObj.funcName);
                SW.pf("return iter(results)\n\n")
                SW.unindent();
            end
        end
    end

    function genPandasTable()
        if fileObj.TableInterface
            if fileObj.ScopedTables
                % SW.pf("@staticmethod\n");
                extraArgs = fileObj.generatePythonTableRestArgs;
                SW.pf("def %s_pandas(%s):\n", fileObj.funcName, extraArgs);
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
                SW.pf("result = instance.RT.%s_table(rows, %s)\n", fileObj.funcName, extraArgs);
                createPandasResultFrame();
                SW.unindent();
                SW.pf("return %s\n\n", innerName);
                SW.unindent();

            else
                % SW.pf("@staticmethod\n");
                SW.pf("def %s_pandas(pdf : pd.DataFrame):\n", fileObj.funcName);
                SW.indent();
                SW.pf('""" A function to be used with applyInPandas."""\n');
                SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
                SW.pf("rows = pdf.to_numpy().tolist()\n");
                SW.pf("result = instance.RT.%s_table(rows)\n", fileObj.funcName);
                createPandasResultFrame();
                SW.unindent();
            end
        end
    end

    function genPandasSeries()
        if fileObj.PandaSeries
                % SW.pf("@staticmethod\n");

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
            SW.pf("result[0].append(hex(id(Wrapper.RT)))\n");
            %             SW.pf("pdResults['task_attempt_id'] = [str(type(pyspark.TaskContext().taskAttemptId()))]\n");
            %             SW.pf("pdResults['partition_id'] = [str(type(pyspark.TaskContext().partitionId()))]\n");

            %             SW.pf("pdResults = pd.DataFrame(result)\n");
            %             SW.pf("pdResults['stage_id'] = [str(type(pyspark.TaskContext().stageId()))]\n");
            %             SW.pf("pdResults['task_attempt_id'] = [str(type(pyspark.TaskContext().taskAttemptId()))]\n");
            %             SW.pf("pdResults['partition_id'] = [str(type(pyspark.TaskContext().partitionId()))]\n");
            %             SW.pf("pdResults['partition_id'] = ['Currywurst']\n");
            %             SW.pf("return pdResults\n\n");
            %         else
        end
        %         SW.pf("return pd.DataFrame(result, columns=%s)\n\n", pandas_name);
        SW.pf("return pd.DataFrame(result)\n\n");
    end

end


