function ds = toDF(obj, varargin)
    % TODF Method to convert a Dataset into a generic DataFrame with renamed cols.
    %
    % TODF(obj) returns a new Dataset that is a generic DataFrame representation
    % of the original Dataset object.
    %
    % TODF(obj, colNames) returns a new Dataset (DataFrame) with the original
    % columns renamed as colNames (strings array or cell-array of chars).
    % The length of colNames must match the number of Dataset columns.
    %
    % TODF(obj, colName1, colName2, ...) returns a new Dataset (DataFrame) with
    % the original columns renamed (strings or char arrays).
    % The number of column names must match the number of Dataset columns.
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
    %     % Create a new dataset with the specified columns
    %     newDataSet = myDataSet.toDF("Carrier", "TheDay", "TheMonth");
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#toDF-java.lang.String...-

    % Copyright 2021 MathWorks, Inc.

    try
        if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no renamed cols

            % Use the default toDF() method
            jDataset = obj.dataset.toDF();

        else  % presumably a char array, a string, or an array of these

            % Spark's toDF() method accepts multiple string column names directly
            if length(varargin)==1  % a single cellstr or string array
                cols = string(varargin{1});
            else  % multiple char array or string input args
                cols = string(varargin);
            end
            jDataset = obj.dataset.toDF(cols);
        end
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

    % Convert into a MATLAB Dataset object
    ds = matlab.compiler.mlspark.Dataset(jDataset);

end %function
