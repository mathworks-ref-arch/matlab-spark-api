function B = dropTempView(obj, viewName)
    % DROPTEMPVIEW Drop a temporary view from a Spark session
    %
    % Returns true if the view is dropped successfully, false otherwise.
    % 
    % 
    % Example:
    %
    %     B = catalog.dropTempView('MyTempTable');
    %    
    
    % Copyright 2020 MathWorks, Inc.
    
    B = obj.catalog.dropTempView(viewName);
    
end %function
