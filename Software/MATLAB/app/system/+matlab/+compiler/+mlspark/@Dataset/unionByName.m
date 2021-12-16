function ds = unionByName(obj, otherDataset, allowMissingColumns)
    % UNIONBYNAME Returns a new Dataset having rows in either this Dataset or another.
    %
    % UNIONBYNAME(obj,otherDataset) will return a new dataset that contains the
    % rows that exist in either this Dataset or the otherDataset.
    %
    % Note: this method preserves duplicate rows, i.e. rows that exist in both
    % Datasets will be duplicated in the new Dataset. This is equivalent to
    % "UNION ALL" in SQL. To do a SQL-style set union (that does deduplication
    % of elements), use this function followed by a call to distinct().
    %
    % Unlike standard SQL and the union() method, UNIONBYNAME resolves columns
    % by their field name, not by their schema position.
    %
    % UNIONBYNAME(obj,otherDataset, allowMissingColumns) accepts an optional
    % logical (true/false) value indicating whether the set of column names in
    % this Dataset and otherDataset can differ; missing columns will be filled
    % with null values. Any missing columns of this Dataset will be added at
    % the end of the columns in the union result's Dataset schema.
    % The default value of allowMissingColumns is false, i.e. both Datasets must
    % have exactly the same set of names (although not necessarily in the same
    % schema order, or in the same case-sensitivity).
    % Note: This method variant is only supported by Spark version 3.1 or newer.
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
    %     newDataSet = myDataSet.unionByName(otherDataset);
    %
    %     % This will return a copy of the current Dataset with rows duplicated:
    %     newDataSet = myDataSet.unionByName(myDataset);
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#unionByName-org.apache.spark.sql.Dataset-

    % Copyright 2021 MathWorks, Inc.

    % Default value for allowMissingColumns = false
    allowMissingColumns = nargin > 2 && allowMissingColumns;

    if isa(otherDataset,class(obj))

        % Process the Spark API action and return a new MATLAB Dataset object
        try
            if allowMissingColumns
                jDataset = obj.dataset.unionByName(otherDataset.dataset, allowMissingColumns);
            else
                jDataset = obj.dataset.unionByName(otherDataset.dataset);
            end
        catch err
            if allowMissingColumns && strcmpi(err.identifier,'MATLAB:UndefinedFunction')
                ver = matlab.sparkutils.Config.getInMemoryConfig.CurrentVersion;
                error('SPARK:ERROR', 'Spark error: unionByName supports the allowMissingColumns input only since version 3.1 (your version: %s)', ver);
            end
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        error('SPARK:ERROR', 'Wrong datatype for unionByName: must be a MATLAB Dataset object');
    end

end %function
