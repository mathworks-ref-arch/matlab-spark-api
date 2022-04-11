function ds = summary(obj, stats)
    % DESCRIBE Return a summary of Dataset
    %
    % Example:
    %     % Assume myDataSet is a dataset
    %
    %     % Create a description of the dataset
    %     descr = myDataSet.summary();
    %
    %     % Create a summary of the dataset, but only for certain
    %     statistics. This argument should be a string array.
    %     descr = myDataSet.summary(["count", "mean"]);
    %
    % Reference:
    %     https://spark.apache.org/docs/3.1.2/api/java/org/apache/spark/sql/Dataset.html#summary-java.lang.String...-

    % Copyright 2022 MathWorks, Inc.

    if nargin < 2 

        dds = obj.dataset.summary(javaArray('java.lang.String',0));
        ds = matlab.compiler.mlspark.Dataset(dds);

    elseif nargin == 2
    
        % Check that cols is a string array
        dds = obj.dataset.summary(stats);
        ds = matlab.compiler.mlspark.Dataset(dds);

    end
    
end %function
