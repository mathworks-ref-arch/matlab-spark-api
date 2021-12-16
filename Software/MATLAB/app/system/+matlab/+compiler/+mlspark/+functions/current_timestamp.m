function col = current_timestamp()
    % CURRENT_TIMESTAMP Create a current_timestamp column
    %
    % Example:
    %
    %     mc = current_timestamp()
    
    % Copyright 2020 MathWorks, Inc.
    
    col = matlab.compiler.mlspark.Column(...
        org.apache.spark.sql.functions.current_timestamp() ...
        );
    
end %function
