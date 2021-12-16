function dataSet = load(obj, varargin)
% LOAD Method to load the input in as a Dataframe / Dataset
% The input datasource in as a dataframe / dataset.
% 
% For example:
% 
%     myDataSet = spark...
%         .read.format('csv')...
%         .option('header','true')...
%         .option('inferSchema','true')...
%         .load(inputLocation);


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

jDataset = obj.dataFrameReader.load(varargin{:});
dataSet = matlab.compiler.mlspark.Dataset(jDataset);

end %function
