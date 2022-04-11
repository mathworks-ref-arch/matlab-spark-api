function ds = describe(obj, cols)
    % DESCRIBE Return description of Dataset
    %
    % Example:
    %     % Assume myDataSet is a dataset
    %
    %     % Create a description of the dataset
    %     descr = myDataSet.describe();
    %
    %     % Create a description of the dataset, but only for certain
    %     columns. This argument should be a string array.
    %     descr = myDataSet.describe(["xw", "yw"]);
    %
    % Reference:
    %     https://spark.apache.org/docs/3.1.2/api/java/org/apache/spark/sql/Dataset.html#describe-java.lang.String...-

    % Copyright 2022 MathWorks, Inc.

    if nargin < 2 

        dds = obj.dataset.describe(javaArray('java.lang.String',0));
        ds = matlab.compiler.mlspark.Dataset(dds);

    elseif nargin == 2
    
        % Check that cols is a string array
        dds = obj.dataset.describe(cols);
        ds = matlab.compiler.mlspark.Dataset(dds);

    end
    
end %function
