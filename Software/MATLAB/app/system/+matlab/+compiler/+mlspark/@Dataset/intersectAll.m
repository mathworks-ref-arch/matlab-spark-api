function ds = intersectAll(obj, otherDataset)
    % INTERSECTALL Returns a new Dataset having rows common to this Dataset and another, preserving duplicates
    %
    % INTERSECTALL(obj,otherDataset) will return a new dataset that contains
    % the rows that exist in both this Dataset and the otherDataset, while
    % preserving the duplicates (unlike the intersect() method).
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
    %     newDataSet = myDataSet.intersectAll(otherDataset);
    %
    %     % This will naturally return a copy of the current Dataset:
    %     newDataSet = myDataSet.intersectAll(myDataset);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#intersectAll-org.apache.spark.sql.Dataset-
    
    % Copyright 2021 MathWorks, Inc.

    if isa(otherDataset,class(obj))

        % Process the Spark API action and return a new MATLAB Dataset object
        try
            jDataset = obj.dataset.intersectAll(otherDataset.dataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        error('SPARK:ERROR', 'Wrong datatype for intersectAll: must be a MATLAB Dataset object');
    end

end %function
