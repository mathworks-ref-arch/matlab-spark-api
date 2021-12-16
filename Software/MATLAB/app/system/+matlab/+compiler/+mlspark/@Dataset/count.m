function numRows = count(obj)
    % COUNT Return the number of rows in the Dataset.
    %
    % Example:
    %
    %  sparkDataSet = spark.read.format('csv')...
    %                   .option('header','true')...
    %                   .option('inferSchema','true')...
    %                   .load(inputLocation);
    %
    %  numRows = sparkDataSet.count();

    % Copyright 2020-2021 MathWorks, Inc.

    try
        numRows = obj.dataset.count();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
