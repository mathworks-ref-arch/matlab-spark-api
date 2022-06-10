function setTableProperties(obj)
    % setTableProperties Set table informations on object
    %
    % This function will check the types of the function.
    % The following cases exist:
    % 1. No tables, neither in input or output. This is a 'normal'
    %    function.
    % 2. 1 input and 1 output, both tables. This is a 'normal table
    %    operation'.
    % 3. 2 or more inputs, and 1 output. The output is a table, and
    %    exactly 1 of the inputs, the fist argument is a table.
    %    This is a scoped table operation, and ok.
    % 4. 1 or more inputs, 1 or more outputs. The input with index 1 is a
    %    table, and the outputs are all non-table elements. In this case
    %    the output will be converted to a one-row table automatically.
    %    This can be used in aggregation functions.
    % 5. Some other combination, where there's at least 1 table.
    %    This is an unsupported combination.

    % Copyright 2022 The MathWorks, Inc.

    inTypes = [obj.InTypes.MATLABType];
    outTypes = [obj.OutTypes.MATLABType];
    inTableIdx = find(inTypes == "table");
    outTableIdx = find(outTypes == "table");
    if isempty(inTableIdx) && isempty(outTableIdx)
        % Case 1
        obj.TableInterface = false;
        obj.ScopedTables = false;
        obj.PandaSeries = obj.nArgOut == 1;
        return;
    end

    % It has something to do with tables
    if length(inTableIdx)==1
        if inTableIdx ~= 1
            error('MATLAB_SPARK_API:bad_table_arguments', ...
                ['With table inputs and additional arguments, ', ...
                'the table must be the first argument.']);
        end

        % This can be case 2, 3 or 4
        if length(outTableIdx) == 1
            % This can be case 2 or 3
            if obj.nArgOut > 1
                error('MATLAB_SPARK_API:bad_table_arguments', ...
                    ['With table types, there can only be one output argument, ', ...
                    'which should be of type table.']);
            end
            if length(inTypes) == 1
                % Case 2
                obj.TableInterface = true;
                obj.PandaSeries = false;
                obj.ScopedTables = false;
            else
                % Case 3
                obj.TableInterface = true;
                obj.PandaSeries = false;
                obj.ScopedTables = true;
            end
        elseif isempty(outTableIdx)
            % Case 4
            obj.TableAggregate = true;
            obj.TableInterface = true;
            obj.PandaSeries = false;
            obj.ScopedTables = length(inTypes) > 1;

        else
            error('MATLAB_SPARK_API:bad_table_arguments', ...
                'There cannot be more than one output table argument.');
        end
    else
        % Case 5
        error('MATLAB_SPARK_API:bad_table_arguments', ...
            'With table inputs, there can only be exactly one table argument.');
    end


end
