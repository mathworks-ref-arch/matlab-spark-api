function setTableProperties(obj)
    % This function will check the types of the function.
    % The following cases exist:
    % 1. No tables, neither in input or output. This is a 'normal'
    %    function.
    % 2. 1 input and 1 output, both tables. This is a 'normal table
    %    operation'.
    % 3. 2 or more inputs, and 1 output. The output is a table, and
    %    exactly 1 of the inputs, the fist argument is a table.
    %    This is a scoped table operation, and ok.
    % 4. Some other combination, where there's at least 1 table.
    %    This is an unsupported combination.
    inTypes = [obj.InTypes.MATLABType];
    outTypes = [obj.OutTypes.MATLABType];
    inIdx = find(inTypes == "table");
    outIdx = find(outTypes == "table");
    if isempty(inIdx) && isempty(outIdx)
        % Case 1
        obj.TableInterface = false;
        obj.ScopedTables = false;
        return;
    end
    if ~isempty(inIdx) || ~isempty(outIdx)
        % It has something to do with tables
        if (length(inIdx)==1 && length(outIdx) == 1)
            % This can be case 2 or 3
            if obj.nArgOut > 1
                error('MATLAB_SPARK_API:bad_table_arguments', ...
                    ['With table types, there can only be one output argument, ', ...
                    'which should be of type table.']);
            end
            obj.TableInterface = true;
            if length(inTypes) > 1
                % Case 3
                if inIdx==1
                    obj.ScopedTables = true;
                else
                    error('MATLAB_SPARK_API:bad_table_arguments', ...
                        ['With table inputs and additional arguments, ', ...
                        'the table must be the first argument.']);
                end
            else
                % Case 2
                obj.ScopedTables = false;
            end
            return;
        else
            % Case 4
            error('MATLAB_SPARK_API:bad_table_arguments', ...
                ['With table inputs and additional arguments, ', ...
                'the table must be the first argument.']);
        end
    else
        % Case 4
        error('MATLAB_SPARK_API:bad_table_arguments', ...
            ['With table inputs and additional arguments, ', ...
            'the table must be the first argument.']);
    end

end
