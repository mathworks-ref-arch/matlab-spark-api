function ds = union(obj, otherDataset)
    % UNION Returns a new Dataset having rows in either this Dataset or another.
    %
    % UNION(obj,otherDataset) will return a new dataset that contains the
    % rows that exist in either this Dataset or the otherDataset.
    %
    % Note: this method preserves duplicate rows, i.e. rows that exist in both
    % Datasets will be duplicated in the new Dataset. This is equivalent to
    % "UNION ALL" in SQL. To do a SQL-style set union (that does deduplication
    % of elements), use this function followed by a call to distinct().
    %
    % Also as standard in SQL, UNION resolves columns by position (not by name).
    % Notice that the column positions in the schema aren't necessarily matched
    % with the fields in the strongly typed objects in a Dataset. UNION resolves
    % columns by their positions in the schema, not the field names. Use the
    % unionByName() method to resolve the columns by the Dataset field name.
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
    %     % Create a new Dataset that merges both Datasets
    %     newDataSet = myDataSet.union(otherDataset);
    %
    %     % This will return a copy of the current Dataset with rows duplicated:
    %     newDataSet = myDataSet.union(myDataset);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#union-org.apache.spark.sql.Dataset-
    
    % Copyright 2021 MathWorks, Inc.

    if isa(otherDataset,class(obj))

        % Process the Spark API action and return a new MATLAB Dataset object
        try
            jDataset = obj.dataset.union(otherDataset.dataset);
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        error('SPARK:ERROR', 'Wrong datatype for union: must be a MATLAB Dataset object');
    end

end %function
