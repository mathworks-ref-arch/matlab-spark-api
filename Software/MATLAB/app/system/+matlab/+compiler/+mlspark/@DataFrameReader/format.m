function obj = format(obj, varargin)
% FORMAT Method to specify the input data source format
% The format method can be used to configure the DataFrameReader to use an
% appropriate source format. 
% 
% Supported data formats include:
%   json
%   csv
%   parquet
%   orc
%   text
%   jdbc
%   libsvm
%   delta
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

obj.dataFrameReader.format(varargin{:});

end %function
