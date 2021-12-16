function ds = unionAll(obj, otherDataset)
    % UNIONALL Returns a new Dataset having rows in either this Dataset or another, preserving duplicates
    % (alias for the union() method)
    %
    % UNIONALL(obj,otherDataset) will return a new dataset that contains the
    % rows that exist in either this Dataset or the otherDataset.
    %
    % Note: this method preserves duplicate rows, i.e. rows that exist in both
    % Datasets will be duplicated in the new Dataset. This is equivalent to
    % "UNION ALL" in SQL. To do a SQL-style set union (which de-duplicates the
    % elements), call the distinct() method on the results of this function.
    %
    % Also as standard in SQL, UNION resolves columns by position (not by name).
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
    %     newDataSet = myDataSet.unionAll(otherDataset);
    %
    %     % This will return a copy of the current Dataset with rows duplicated:
    %     newDataSet = myDataSet.unionAll(myDataset);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#unionAll-org.apache.spark.sql.Dataset-
    
    % Copyright 2021 MathWorks, Inc.

    % unionAll() is just an alias for the union() method
    ds = union(obj, otherDataset);

end %function
