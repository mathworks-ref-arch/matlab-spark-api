function B = dropGlobalTempView(obj, viewName)
    % DROPGLOBALTEMPVIEW Drop a global temporary view from a Spark session
    %
    % Returns true if the view is dropped successfully, false otherwise.
    % 
    % 
    % Example:
    %
    %     B = catalog.dropGlobalTempView('MyTempTable');
    %    
    
    % Copyright 2020 MathWorks, Inc.
    
    B = obj.catalog.dropGlobalTempView(viewName);
    
end %function
