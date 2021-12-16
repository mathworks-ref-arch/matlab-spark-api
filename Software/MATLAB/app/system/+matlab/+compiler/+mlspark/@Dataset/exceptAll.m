function ds = exceptAll(obj, otherDataset)
    % EXCEPTALL Returns a new Dataset having rows in this Dataset but not in another, preserving duplicates
    %
    % EXCEPTALL(obj,otherDataset) will return a new dataset that contains only
    % the rows in this Dataset that do not exist in the otherDataset, while
    % preserving the duplicates (unlike the except() method).
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
    %     % Create a new Dataset that only has rows unique to this Dataset
    %     newDataSet = myDataSet.exceptAll(otherDataset);
    %
    %     % This will naturally return an empty Dataset (having no rows):
    %     newDataSet = myDataSet.exceptAll(myDataset);
    %     disp(newDataSet.count())  % displays 0
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#exceptAll-org.apache.spark.sql.Dataset-
    
    % Copyright 2021 MathWorks, Inc.

    if isa(otherDataset,class(obj))

        % Process the Spark API action and return a new MATLAB Dataset object
        try
            jDataset = obj.dataset.exceptAll(otherDataset.dataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        error('SPARK:ERROR', 'Wrong datatype for exceptAll: must be a MATLAB Dataset object');
    end

end %function
