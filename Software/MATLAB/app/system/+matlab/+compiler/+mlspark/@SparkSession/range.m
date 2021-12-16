function datasetObj = range(obj, varargin)
% RANGE Method to create a dataset with a single long column
% Creates a single column dataset, returning the result as a DataFrame. 
% 
% The method accepts the start, end (exclusive) and defaults to a step size
% of 1. It is also possible to specify the number of partitions.
% 
% Example:
% 
%   % Create a range of 10 long integers
%   myDS = spark.range(0,10);
%   
%   % Create a range of 20 long integers with a step size of 2
%   myDS = spark.range(0, 20, 2);
% 
%   % Create a range with a specific number of partitions (5 in this case)
%   myDS = spark.range(0, 20, 2, 5);
% 


%                 Copyright 2020 MathWorks, Inc.
%                 $Id$


datasetObj = matlab.compiler.mlspark.Dataset(obj.sparkSession.range(varargin{:}));

end %function
