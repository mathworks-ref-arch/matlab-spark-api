function col = to_json(col, options)
    % TO_JSON Convert a column with StructType/ArrayType/MapType to JSON string
    %
    % to_json(col) returns a dataset column that contains a JSON string that 
    % represents the input column's contents. Only columns that contain a map,
    % struct or array are supported; other column types will cause an error.
    % 
    % to_json(col,options) uses optional map of JSON option keys/values, as per
    % https://spark.apache.org/docs/latest/sql-data-sources-json.html#data-source-option
    % In addition to the options listed on that webpage, you can also specify
    % the "pretty" option to get pretty (formatted) JSON generation.
    % The options argument can be either a containers.Map object, Nx2 table, Nx2
    % cell array of keys and values, or struct array with 'key','value' fields.
    %
    % Inputs:
    %     col - input column to process. Must contain a struct, array or map.
    %     options - (optional) controls how to handle the JSON conversion.
    %
    % Example:
    %
    %     % DS is a dataset
    %     % Get a value column
    %     inCol = DS.col("x_loc")
    %     % Convert to a column with a JSON string representing the col data
    %     outCol = to_json(inCol)
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/functions.html#to_json-org.apache.spark.sql.Column-

    % Copyright 2021 The MathWorks, Inc.

    try
        try col = col.column; catch, end  % col may be a column name or object
        if nargin < 2
            jcol = org.apache.spark.sql.functions.to_json(col);
        else
            joptions = getOptionsMap(options);  % convert into a Java Map object
            jcol = org.apache.spark.sql.functions.to_json(col, joptions);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    if ~isempty(jcol)
        col = matlab.compiler.mlspark.Column(jcol);
    else
        error('SPARK:ERROR', ...
              'The Spark %s function is only supported for arguments that are numeric, a string, or a matlab.compiler.mlspark.Column object', ...
              mfilename);
    end
end

% Convert MATLAB options (various possible types) into a java.util.Map object
function joptions = getOptionsMap(options)
    switch class(options)
        case 'table'
            joptions = getOptionsMap(table2cell(options));
        case 'struct'
            try
                keys = {options.key};
                vals = {options.value};
                joptions = getOptionsMap([keys; vals]');
            catch
                error('SPARK:ERROR', 'JSON options for Spark should be either a containers.Map object, Nx2 table, Nx2 cell array, or struct array with ''key'',''value'' fields');
            end
        case 'containers.Map'
            keys = options.keys;
            vals = options.values;
            joptions = getOptionsMap([keys; vals]');
        case 'cell'
            if size(options,2) ~= 2
                error('SPARK:ERROR', 'JSON options for Spark should be either a containers.Map object, Nx2 table, Nx2 cell array, or struct array with ''key'',''value'' fields');
            end
            joptions = java.util.HashMap;
            for row = 1 : size(options,1)
                joptions.put(options{row,1}, options{row,2});
            end
        otherwise
            error('SPARK:ERROR', 'JSON options for Spark should be either a containers.Map object, Nx2 table, Nx2 cell array, or struct array with ''key'',''value'' fields');
    end
end
