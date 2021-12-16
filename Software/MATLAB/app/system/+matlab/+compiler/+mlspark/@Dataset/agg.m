function ds = agg(obj, varargin)
    % AGG Aggregates on the entire Dataset without groups.
    %
    % Inputs:
    %   - Column objects
    %   - containers.Map Object with a mapping of columns => functions
    %   - Nx2 table (2 columns, representing columnName, functionName)
    %   - Nx2 cell-array (same 2 columns)
    %   - Nx2 string-array (same 2 columns)
    %
    % Examples:
    %
    %     dataset = spark.read.format('csv')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load('/data/sample1.csv')...
    %
    %     map = ["col1", "Count"; ...
    %            "col2", "Max"; ...
    %            "col3", "Min"; ...
    %            "col4", "Avg"];
    %     newDataset = dataset.agg(map);
    %     newDataset.show()
    %        +-----------+---------+---------+---------+
    %        |count(col1)|max(col2)|min(col3)|avg(col4)|
    %        +-----------+---------+---------+---------+
    %        |      52312|   123523|  15.7697|     12.5|
    %        +-----------+---------+---------+---------+
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#agg-java.util.Map-

    % Copyright 2021 The MathWorks, Inc.

    if nargin > 1 && isa(varargin{1}, 'matlab.compiler.mlspark.Column')

        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        mCols = [varargin{:}];
        jCols = [mCols.column];
        if length(jCols) > 1
            if length(jCols)==2
                endSlice = java.util.Arrays.copyOfRange(jCols, 1, 2);
                cols = {jCols(1), endSlice};
            else
                cols = {jCols(1), jCols(2:end)};
            end
        else
            cols = {jCols(1), jCols(1:0)};
        end
        try
            jDataset = obj.dataset.agg(cols{:});
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end

    elseif nargin == 2  % column => function mapping

        % Convert the input into a string array (presumably of size Nx2)
        inputMap = varargin{1};
        switch class(inputMap)
            case {'cell', "string"}
                % do nothing - inputMap is already a string array
            case 'containers.Map'
                inputMap = [inputMap.keys; inputMap.values]';
            case 'table'
                inputMap = [inputMap{:,:}];
            otherwise
                error('SPARK:ERROR', ...
                      'The agg function is only supported for input arguments of type matlab.compiler.mlspark.Column, containers.Map, and Nx2 table/array/cell-array of strings');
        end

        % Croak in case the input is not Nx2
        if size(inputMap,2) ~= 2
            error('SPARK:ERROR', 'The agg function expects an Nx2 array of strings as input');
        end

        % Croak in case the input is not an array of strings
        inputMap = string(inputMap);  % convert cellstr => string array

        % Create a new java.util.Map object, one element (input row) at a time
        map = java.util.HashMap;
        for row = 1 : size(inputMap,1)
            map.put(inputMap(row,1), inputMap(row,2));
        end

        % Process the API's agg(Map) method
        try
            jDataset = obj.dataset.agg(map);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end

    else

        error('SPARK:ERROR', ...
              'The agg function is only supported for input arguments of type matlab.compiler.mlspark.Column, containers.Map, and Nx2 table/array/cell-array of strings');
    end

    % No error so far - return a new MATLAB Dataset object with the results
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end
