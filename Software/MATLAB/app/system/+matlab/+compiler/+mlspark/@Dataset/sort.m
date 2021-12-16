function ds = sort(obj, varargin)
    % SORT Method to select rows by name
    %
    % SORT(obj,columns) will return a new Dataset, sorted by the specified
    % COLUMNS in the original dataset. COLUMNS can be an array of MATLAB Column
    % objects, an array of strings (column names), or a cell-array of chars
    % (column names). Note that only the first variant (array of Column objects)
    % enables use of ad-hoc constructed columns; when using the other variants
    % (column names), only existing columns can be specified, not ad-hoc ones.
    %
    % Example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Sort the dataset using the specified columns
    %     newDataSet = myDataSet.sort("UniqueCarrier", "Day", "Month");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#sort-org.apache.spark.sql.Column...-
    
    % Copyright 2020-2021 MathWorks, Inc.
    
    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no sorting cols

        % return a copy of the original object
        ds = matlab.compiler.mlspark.Dataset(obj.dataset);
        return

    elseif isa(varargin{1}, 'matlab.compiler.mlspark.Column')

        % Spark's sort() API for Column objects accepts an array of objects
        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        mCols = [varargin{:}];
        cols = makeJavaArray([mCols.column]);
        sortCols = {cols};

    else  % presumably a char array or a string

        if length(varargin)==1  % a single cellstr or string array
            cols = string(varargin{1});
        else  % multiple char array or string input args
            cols = string(varargin);
        end
        % Spark's sort() API for strings requires 2 inputs: String,String[]
        if length(cols) > 1  % multiple sort columns
            sortCols = {cols(1), cols(2:end)};
        else  % a single sort column
            sortCols = {cols, javaArray('java.lang.String',0)};
        end
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.sort(sortCols{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function
