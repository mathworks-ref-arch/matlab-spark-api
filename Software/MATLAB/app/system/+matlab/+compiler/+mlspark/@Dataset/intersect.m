function ds = intersect(obj, otherDataset)
    % INTERSECT Returns a new Dataset having rows common to this Dataset and another.
    %
    % INTERSECT(obj,otherDataset) will return a new dataset that contains the
    % rows that exist in both this Dataset and the otherDataset.
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
    %     % Create a new Dataset that only has rows common to both Datasets
    %     newDataSet = myDataSet.intersect(otherDataset);
    %
    %     % This will naturally return a copy of the current Dataset:
    %     newDataSet = myDataSet.intersect(myDataset);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#intersect-org.apache.spark.sql.Dataset-
    
    % Copyright 2021 MathWorks, Inc.

    if isa(otherDataset,class(obj))

        % Process the Spark API action and return a new MATLAB Dataset object
        try
            jDataset = obj.dataset.intersect(otherDataset.dataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        error('SPARK:ERROR', 'Wrong datatype for intersect: must be a MATLAB Dataset object');
    end

end %function
