function dataFrameWriter = write(obj, varargin)
% WRITE Method to get the dataframe writer from the current SparkSession
% Returns a DataFrameWriter that can be used to write data through a DataFrame.
% 
% Please see SparkSession to create a shared spark context. 
% 
%       % Create a shared SparkSession  
%       spark = SparkSession(conf);
%       
%       % Get the dataframe writer
%       dfwriter = spark.write();


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

dataFrameWriter = matlab.compiler.mlspark.DataFrameReader(obj.sparkSession.write());

end %function
