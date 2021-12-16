function DS = listTables(obj)
    % LISTTABLES List database tables in a Spark session
    %
    % Returns a Dataset with the information.
    % 
    % 
    % Example:
    %
    %     tDS = catalog.listTables();
    %    
    
    % Copyright 2020 MathWorks, Inc.
    
    DS = matlab.compiler.mlspark.Dataset(obj.catalog.listTables());
    
end %function
