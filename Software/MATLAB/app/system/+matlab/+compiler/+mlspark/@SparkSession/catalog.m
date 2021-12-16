function C = catalog(obj)
    % CATALOG Return a catalog from a Spark session.
    %
    % This will return a new dataset, sorted by the column names provided
    % Example:
    %
    %     C = spark.catalog();
    %    
    
    % Copyright 2020 MathWorks, Inc.
    
    C = matlab.compiler.mlspark.Catalog(obj.sparkSession.catalog);
    
end %function
