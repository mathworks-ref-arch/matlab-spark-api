function tbl = table(obj)
    % TABLE Convert a Spark dataset or dataframe to a MATLAB table
    %
    % Converts from a Spark dataset to a MATLAB table
    %
    % This function should be used for tests, not for large tables.
    %
    % For example:
    %
    %     % Create a dataset
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %
    %     % Convert the dataset to a MATLAB table
    %     filterDataSet = myDataSet.filter("UniqueCarrier LIKE 'AA'");
    %     matlabTable = table(filterDataSet);
    %
    % See also: struct

    % Copyright 2020-2021 MathWorks, Inc.

    try
        tbl = dataset2table(obj.dataset);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
