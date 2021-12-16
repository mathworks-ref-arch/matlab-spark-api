function isDB = isDatabricksEnvironment()
    % isDatabricksEnvironment Check if this is run in Databricks context
    %
    % Spark can be used in either 'Apache Spark' or 'Databricks'
    % environment. This function will return either true if this is a
    % Databricks environment.
    
    % Copyright 2021 MathWorks Inc.
    
    isDB = exist('databricksRoot', 'file') == 2;

end

