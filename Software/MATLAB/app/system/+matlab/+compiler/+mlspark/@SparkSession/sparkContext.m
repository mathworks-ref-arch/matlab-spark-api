function sc = sparkContext(obj, varargin)
% SPARKCONTEXT Method to return the sparkContext from the SparkSession
% The spark context for a given SparkSession object is returned as a handle
% to the user.

%  Copyright 2020 MathWorks, Inc.

% Fetch the runtime configuration
runConf = obj.sparkSession.conf();
confHash = runConf.getAll;

% Iterate and create the containers.map
kIter = confHash.iterator;

key={};
val={};
while (kIter.hasNext())
    pair = kIter.next();
    key{end+1} = javaMethod('_1',pair);
    val{end+1} = javaMethod('_2',pair);
end

% Create sanitized map
appNameIdx = strcmp(key,'spark.app.name');
masterIdx = strcmp(key,'spark.master');

% Create a mask and populate the sparkProperties
kMask = ones(numel(key),1);
kMask(appNameIdx) = 0;
kMask(masterIdx) = 0;

sparkProperties = containers.Map(key(logical(kMask)),val(logical(kMask)));

% Setup configuration object
mlConf = matlab.compiler.mlspark.SparkConf( ...
    'Master',char(val(masterIdx)),...
    'AppName',char(val(appNameIdx)), ...
    'SparkProperties',sparkProperties, ...
    "SparkVersion", "2" ...
    );

% Return the spark configuration
sc = matlab.compiler.mlspark.SparkContext(mlConf);

end %function
