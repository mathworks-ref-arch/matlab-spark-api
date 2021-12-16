function df = jdbc(obj, url, tableName, connProps, varargin)
% JDBC Method to Construct a dataframe representing a database table
% Construct a DataFrame representing the database table accessible via JDBC URL url named table and connection properties.
% 
% To read from a MySQL database:
% 
%     %% Imports
%     import java.util.Properties;
%                 
%     % Create properties for the connection
%     connectionProperties = Properties();
% 
%     % Please consider using secretes to store this info
%     connectionProperties.put("user", "ahosagra@mysql-test");
%     connectionProperties.put("password", "DummyPassword#");
% 
%     %% Create a Spark configuration and shared Spark session
%     import matlab.compiler.mlspark.*;
% 
%     % Set the location for temporary files
%     sparkProperties = containers.Map({'spark.executorEnv.MCR_CACHE_ROOT'},{'/tmp/matlabapp'});
% 
%     % Setup configuration to run locally
%     conf = SparkConf( ...
%         'Master','local',...
%         'AppName','DBConnectDemo', ...
%         'SparkProperties',sparkProperties, ...
%         "SparkVersion", "2" ...
%         );
% 
%     % This will create a singleton SparkSession using the getOrCreate() method
%     spark = SparkSession(conf);
%
% Finally, a dataset can be created using:
%     dbConnString = 'jdbc:mysql://mysql-test.mwlab.io:3306/test_database?useSSL=true&requireSSL=false';   
%     df = spark.read.jdbc(dbConnString,...
%         'test_binary',...
%         connectionProperties);
% 
%     % Spark Dataset
%     df = matlab.compiler.mlspark.Dataset(dfj);
% 
%     % Marshal to a table
%     mlTable = table(df);

%       Copyright 2020 MathWorks, Inc.

df = matlab.compiler.mlspark.Dataset(obj.dataFrameReader.jdbc(url, tableName, connProps));

end %function
