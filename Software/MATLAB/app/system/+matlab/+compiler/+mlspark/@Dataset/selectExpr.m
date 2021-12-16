function ds = selectExpr(obj, varargin)
    % SELECTEXPR Method to select Dataset columns via SQL expressions
    %
    % SELECT(obj,sqlExpr1,...) will return a new dataset that contains only the
    % specified columns from the original dataset modified by the specified SQL
    % expressions. 
    %
    % Note: the SQL expressions must be individual strings or chars, or a single
    % array of strings/chars; they cannot be Column objects.
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
    %     % Filter the dataset, returning a new Dataset with just a few columns
    %     newDataSet = myDataSet.selectExpr("UniqueCarrier as Carrier", ...
    %                                       "Day", "Value/12 as Dozens", ...
    %                                       "-5*abs(Year-2000) as Something");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#selectExpr-java.lang.String...-
    
    % Copyright 2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no selection cols

        error('SPARK:ERROR', 'Spark API requires at least one column to be specified for the selectedExpr() method')

    elseif isString(varargin{1}) || (iscell(varargin{1}) && ~isempty(varargin{1}) && isString(varargin{1}{1}))

        if length(varargin)==1  % a single cellstr or string array
            cols = string(varargin{1});
        else  % multiple char array or string input args
            cols = string(varargin);
        end
        % Spark's selectExpr() API for strings requires String[] input
        selectCols = {cols};

    else
        error('SPARK:ERROR', 'Wrong datatype for selectExpr: must be a char array or string');
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.selectExpr(selectCols{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function

function flag = isString(value)
    flag = isa(value,'char') || isa(value,'string');
end
