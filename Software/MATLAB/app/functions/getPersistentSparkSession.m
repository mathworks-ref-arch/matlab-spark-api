function spark = getPersistentSparkSession(sparkMaster)
    % getPersistentSparkSession - Get persistent Spark session
    %
    % This function will return a persistent Spark session that is
    % maintained by another class. This makes it easier to reuse an
    % existing Spark session in different parts of an application.
    %
    % Example:
    %     spark = getPersistentSparkSession('local');
    % or
    %     spark = getPersistentSparkSession('spark://my-cluster:7077');
    %
    % If no argument is given, the sparkMaster will be read from the
    % current configuration.
    %
    % See also, matlab.sparkutils.Config
    
    
    % Copyright 2020 MathWorks, Inc.
    
    if nargin < 1
        C = matlab.sparkutils.Config.getInMemoryConfig();
        sparkMaster = C.Master;
    end
    
    spark = matlab.sparkutils.SparkSessionHandler.getSession(sparkMaster);
    
end