function ds = dropDuplicates(obj, varargin)
    % DROPDUPLICATES Method to drop duplicate rows specified by certain columns.
    %
    % Returns a new Dataset with duplicates removed
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
    %     % Returns a new Dataset that contains only the unique rows from this Dataset.
    %     newDataSet = myDataSet.dropDuplicates();
    %
    %     % Returns a new Dataset with duplicate rows removed, considering only the subset of columns.
    %     newDataSet = myDataSet.dropDuplicates("UniqueCarrier", "Day", "Month");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#dropDuplicates-java.lang.String:A-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no selection cols

        % Return a dataset with no duplicate rows (consider all columns)
        colNames = {};

    elseif isa(varargin{1}, 'matlab.compiler.mlspark.Column')

        assertUniformClass('matlab.compiler.mlspark.Column', varargin);
        if length(varargin) == 1  % single input arg: array of Column objects
            cols = varargin{1};
        else  % multiple independent Column input args
            cols = [varargin{:}];
        end
        % Spark's dropDuplicates() API does not accept Column objects (unlike
        % column name strings), so convert to column names
        colNames = {string([cols.column])};  % convert into a string array

    else  % presumably a char array, a string, or an array of these

        % Spark's drop() API accepts multiple string column names directly
        if length(varargin)==1  % a single cellstr or string array
            colNames = varargin{1};
        else  % multiple char array or string input args
            colNames = varargin;
        end
        colNames = {string(colNames)};  % convert into a string array
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.dropDuplicates(colNames{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
end %function
