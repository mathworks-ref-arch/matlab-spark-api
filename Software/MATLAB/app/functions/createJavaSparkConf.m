function conf = createJavaSparkConf(varargin)
    % createJavaSparkConf Create a Java sparkConf object
    %
    % It takes the following, optional key/value argument pairs
    %
    %  Master - The name of the Spark Master, e.g 'local' or
    %    'spark://myhost:7077'
    %  AppName - The name of the application
    %  ExecutorEnv - A containers.Map with ExecutorEnv values, where both
    %     keys and values are of char type.
    %  SparkProperties - A containers.Map with SparkProperties values,
    %     where both keys and values are of char type.
    %
    % The returned value is an instance of org.apache.spark.SparkConf, i.e.
    % a Java object.
    
    % Copyright 2021 The MathWorks, Inc.
    
    p = inputParser;
    defaultAppName = ['matlab-spark-', datestr(now,30)];
    defaultMaster = 'local';
    defaultSparkProperties = getDefaultSparkProperties();
    defaultExecutorEnv = containers.Map('KeyType','char','ValueType','char');
    addParameter(p, 'AppName', defaultAppName, ...
        @(x)validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'Master', defaultMaster, ...
        @(x)validateattributes(x, {'char', 'string'}, {'scalartext'}));
    addParameter(p, 'ExecutorEnv', defaultExecutorEnv, ...
        @(x)isa(x,'containers.Map') && strcmp(x.KeyType,'char') && strcmp(x.ValueType,'char'));
    addParameter(p, 'SparkProperties',defaultSparkProperties, ...
        @(x)isa(x,'containers.Map') && strcmp(x.KeyType,'char') && strcmp(x.ValueType,'char'));
    
    parse(p, varargin{:});
    
    conf = org.apache.spark.SparkConf;
    conf.setMaster(p.Results.Master);
    conf.setAppName(p.Results.AppName);
    
    if (~isempty(p.Results.ExecutorEnv))
        listOfPropNames = p.Results.ExecutorEnv.keys;
        for i = 1:length(listOfPropNames)
            conf.setExecutorEnv( listOfPropNames{i}, p.Results.ExecutorEnv(listOfPropNames{1}));
        end
    end
    
    if (~isempty(p.Results.SparkProperties))
        listOfPropNames = p.Results.SparkProperties.keys;
        for i = 1:length(listOfPropNames)
            conf.set( listOfPropNames{i}, p.Results.SparkProperties(listOfPropNames{i}));
        end
    end
    
end

