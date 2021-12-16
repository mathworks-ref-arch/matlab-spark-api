function sparkMajorVersion = getSparkMajorVersion()
    % GETSPARKMAJORVERSION Retrieve Spark major version used.
    %
    
    % Copyright 2021 MathWorks, Inc.

    persistent SMV
    if isempty(SMV)
        C = matlab.sparkutils.Config.getInMemoryConfig();
        SMV = C.getSparkMajorVersion();
    end
    sparkMajorVersion = SMV;
    
end
