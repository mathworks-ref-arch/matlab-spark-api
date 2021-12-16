function datasetObj = sql(obj, sqlString)
% SQL Method to invoke a SQL Query
% Executes a SQL query using Spark, returning the result as a DataFrame. 
% 
% For example: 
% 
%   spark = matlab.compiler.mlspark.SparkSession(sparkConf)
%   tblF = spark.sql('SELECT col from test.TestTable limit 10');

%                 Copyright 2020 MathWorks, Inc.
%                 $Id$

datasetObj = matlab.compiler.mlspark.Dataset(obj.sparkSession.sql(sqlString));

end %function
