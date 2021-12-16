function ds = drop(obj, varargin)
    % DROP Method to return a new Dataset with one or more columns dropped
    % Returns a new dataset with the column(s) dropped
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
    %     % Create a new dataset without the specified columns
    %     newDataSet = myDataSet.drop("UniqueCarrier", "Day", "Month");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#drop-java.lang.String-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no dropped cols

        % return a copy of the original object
        ds = matlab.compiler.mlspark.Dataset(obj.dataset);
        return

    elseif isa(varargin{1}, 'matlab.compiler.mlspark.Column')

        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        jDataset = obj.dataset;
        if length(varargin) == 1  % single input arg: array of Column objects
            cols = varargin{1};
        else  % multiple independent Column input args
            cols = [varargin{:}];
        end
        % Spark's drop() API does not accept multiple Column objects (unlike
        % column name strings), so process the column objects one by one
        for colIdx = 1 : length(cols)
            if iscell(cols)
                mcol = cols{colIdx};
            else
                mcol = cols(colIdx);
            end
            jcol = mcol.column;
            jDataset = dropDatasetCol(jDataset, jcol);
        end

    else  % presumably a char array, a string, or an array of these

        % Spark's drop() API accepts multiple string column names directly
        if length(varargin)==1  % a single cellstr or string array
            cols = string(varargin{1});
        else  % multiple char array or string input args
            cols = string(varargin);
        end
        jDataset = dropDatasetCol(obj.dataset, cols);

        % Warn user if any specified column(s) do not exist (case-insensitive)
        [badCols, badIdx] = setdiff(lower(cols), lower(obj.columns), 'stable');
        if ~isempty(badCols)
            badColsStr = strjoin(cols(badIdx),'","');
            warning('SPARK:Warning', 'Missing column(s) "%s" ignored (not dropped)', badColsStr);
        end
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function

% Drop col(s) from a Java Dataset, returning the modified Dataset
function ds = dropDatasetCol(ds, cols)
    try
        ds = ds.drop(cols);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
end