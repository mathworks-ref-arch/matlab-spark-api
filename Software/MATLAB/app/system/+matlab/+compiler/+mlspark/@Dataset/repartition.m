function ds = repartition(obj, varargin)
    % REPARTITION Method to return a new Dataset partitioned as requested.
    %
    % REPARTITION(obj) returns a new Dataset that has the default number (200)
    % of partitions.
    %
    % REPARTITION(obj, numPartitions) returns a new Dataset that has exactly
    % numPartitions partitions.
    %
    % REPARTITION(obj, columns) returns a new Dataset that is
    % partitioned by columns. The resulting Dataset is hash
    % partitioned. This is the same operation as "DISTRIBUTE BY" in SQL (Hive QL).
    %
    % REPARTITION(obj, numPartitions, columns) returns a new Dataset that is
    % partitioned by columns into numPartitions. The resulting Dataset is hash
    % partitioned. This is the same operation as "DISTRIBUTE BY" in SQL (Hive QL).
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
    %     % Create a new dataset repartitioned into 10 partitions
    %     newDataSet = myDataSet.repartition(10);
    %
    %     % Check the resulting partitions
    %     rdd = newDataSet.rdd();  % or: rdd(newDataset)
    %     numPartitions = rdd.getNumPartitions();  % should be =10
    %     partitions = rdd.getPartitions(); %array of org.apache.spark.Partition
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#repartition-int-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no partition number or cols specified
        % Return a dataset with the default partitioning (200 partitions)
        partitionArgs = {javaArray('org.apache.spark.sql.Column',0)};
    elseif isnumeric(varargin{1})
        % numPartitions was specified (with or without columns)
        % normalize the Column inputs as expected by the Spark API
        partitionArgs = [varargin{1}, getPartitionCols(varargin(2:end))];
    else
        % columns were specified (without numPartitions)
        % normalize the Column inputs as expected by the Spark API
        partitionArgs = getPartitionCols(varargin);
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.repartition(partitionArgs{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
    % Convert column args into an array of Column objects
    function partitionCols = getPartitionCols(inputCols)
        if isempty(inputCols)
            partitionCols = {};
        elseif isa(inputCols{1}, 'matlab.compiler.mlspark.Column') %Column object(s)
            % Spark's repartition() method accepts an array of Column objects
            assertUniformClass('matlab.compiler.mlspark.Column', inputCols);
            mCols = [inputCols{:}];
            cols = makeJavaArray([mCols.column]);
            partitionCols = {cols};
        else  % presumably char array or string: convert to Column objects array
            % Spark's repartition() method does NOT accept an array of
            % strings (column names) so convert them into Column objects
            if length(inputCols)==1  % a single cellstr or string array
                colNames = string(inputCols{1});
            else  % multiple char array or string input args
                colNames = string(inputCols);
            end
            for colIdx = length(colNames) : -1 : 1
                cols(colIdx) = obj.dataset.col(colNames{colIdx});
            end
            partitionCols = {cols};
        end
    end

end %function
