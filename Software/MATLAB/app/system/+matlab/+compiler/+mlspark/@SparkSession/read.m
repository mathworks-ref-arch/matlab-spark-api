function dataFrameReader = read(obj, varargin)
% READ Method to get the dataframe reader from the current SparkSession
% Returns a DataFrameReader that can be used to read non-streaming data in as a DataFrame.
% 
% Please see SparkSession to create a shared spark context. 
% 
%       % Create a shared SparkSession  
%       spark = SparkSession(conf);
%       
%       % Get the dataframe reader
%       dfreader = spark.read();


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

dataFrameReader = matlab.compiler.mlspark.DataFrameReader(obj.sparkSession.read());

end %function
