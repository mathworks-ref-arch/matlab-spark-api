function ds = select(obj, varargin)
    % SELECT Method to select columns by name
    %
    % SELECT(obj,columns) will return a new dataset that contains only the
    % specified COLUMNS from the original dataset. COLUMNS can be an array of
    % MATLAB Column objects, an array of strings (column names), or cell-array
    % of chars (column names). Note that only the first variant (array of Column
    % objects) enables using ad-hoc constructed columns; when using the column
    % names variants, only existing columns can be specified, not ad-hoc ones.
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
    %     % Select a subset of the Dataset with just a few columns
    %     newDataSet = myDataSet.select("UniqueCarrier", "Day", "Month");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#select-org.apache.spark.sql.Column...-
    
    % Copyright 2020-2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no selection cols

        % Return a dataset with no columns
        selectCols = {javaArray('org.apache.spark.sql.Column',0)};

    elseif isa(varargin{1}, 'matlab.compiler.mlspark.Column')

        % Spark's select() API accepts an array of Column objects
        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        mCols = [varargin{:}];
        cols = makeJavaArray([mCols.column]);
        selectCols = {cols};

    else  % presumably a char array or a string

        if length(varargin)==1  % a single cellstr or string array
            cols = string(varargin{1});
        else  % multiple char array or string input args
            cols = string(varargin);
        end
        % Spark's select() API for strings requires 2 inputs: String,String[]
        if length(cols) > 1  % multiple sort columns
            selectCols = {cols(1), cols(2:end)};
        else  % a single sort column
            selectCols = {cols, javaArray('java.lang.String',0)};
        end
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.select(selectCols{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function
