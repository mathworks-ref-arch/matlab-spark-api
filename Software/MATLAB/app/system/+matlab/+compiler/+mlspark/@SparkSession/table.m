function datasetObj = table(obj, tableString, varargin)
% TABLE Method to returns the specified table/view as a DataFrame
% Executes a SQL query using Spark, returning the result as a DataFrame. 
% 
%   spark = matlab.compiler.mlspark.SparkSession(sparkConf)
%   tblF = spark.table('test.TestTable');

%                 Copyright 2020 MathWorks, Inc.
%                 $Id$

datasetObj = matlab.compiler.mlspark.Dataset(obj.sparkSession.table(tableString));


end %function
