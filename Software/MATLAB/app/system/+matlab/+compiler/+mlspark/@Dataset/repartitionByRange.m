function ds = repartitionByRange(obj, varargin)
    % REPARTITIONBYRANGE Method to return a new Dataset partitioned as requested.
    %
    % REPARTITIONBYRANGE(obj, numPartitions, columns) returns a new Dataset that
    % is range-partitioned by columns into up to numPartitions. At least one
    % column must be specified. The rows are not sorted in each partition of the
    % resulting Dataset. For performance reasons this method uses sampling to
    % estimate the ranges. The output may not be consistent, since sampling can
    % return different values. The sample size can be controlled by the config
    % spark.sql.execution.rangeExchange.sampleSizePerPartition.
    %
    % REPARTITIONBYRANGE(obj, columns) returns a new Dataset that is partitioned
    % by columns, using spark.sql.shuffle.partitions as number of partitions.
    %
    % Note: unlike the repartition() method, REPARTITIONBYRANGE does not accept
    % a no-columns input - At least one column must be specified, otherwise the
    % range partitioning cannot be computed (the repartition() method uses hash
    % partitioning, so specifying the columns is optional).
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
    %     % Create a new dataset having up to 10 partitions based on Year value
    %     newDataSet = myDataSet.repartitionByRange(10, 'Year');
    %
    %     % Check the resulting partitions
    %     rdd = newDataSet.rdd();  % or: rdd(newDataset)
    %     numPartitions = rdd.getNumPartitions();  % should be <=10
    %     partitions = rdd.getPartitions(); %array of org.apache.spark.Partition
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#repartitionByRange-int-org.apache.spark.sql.Column...-

    % Copyright 2021 MathWorks, Inc.

    if nargin < 2 || (nargin < 3 && isempty(varargin{1})) % no partition number or cols specified
        % At least one column must be specified
        error('SPARK:ERROR', 'Spark API requires at least one column to be specified for the repartitionByRange() method')
    elseif isnumeric(varargin{1})
        % numPartitions was specified
        % normalize the Column inputs as expected by the Spark API
        partitionArgs = [varargin{1}, getPartitionCols(varargin(2:end))];
    else
        % columns were specified (without numPartitions)
        % normalize the Column inputs as expected by the Spark API
        partitionArgs = getPartitionCols(varargin);
    end

    % Process the Spark API action and return a new MATLAB Dataset object
    try
        jDataset = obj.dataset.repartitionByRange(partitionArgs{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    ds = matlab.compiler.mlspark.Dataset(jDataset);
    
    % Convert column args into an array of Column objects
    function partitionCols = getPartitionCols(inputCols)
        if isempty(inputCols)
            error('SPARK:ERROR', 'Spark API requires at least one column to be specified for the repartitionByRange() method')
        elseif isa(inputCols{1}, 'matlab.compiler.mlspark.Column') %Column object(s)
            % Spark's repartitionByRange() method accepts an array of Column objects
            assertUniformClass('matlab.compiler.mlspark.Column', inputCols);
            mCols = [inputCols{:}];
            cols = makeJavaArray([mCols.column]);
            partitionCols = {cols};
        else  % presumably char array or string: convert to Column objects array
            % Spark's repartitionByRange() method does NOT accept an array of
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
