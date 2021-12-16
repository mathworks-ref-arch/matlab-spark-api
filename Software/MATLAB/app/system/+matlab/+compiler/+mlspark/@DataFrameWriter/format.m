function obj = format(obj, varargin)
% FORMAT Method to specify the output data source format
% The format method can be used to configure the DataFrameWriter to use an
% appropriate source format. 
% 
% Built-in options include:
%   json
%   csv
%   parquet
% etc.
%
% For example:
% 
%     myDataSet.write.format('parquet')...
%         .save(outputLocation);


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

obj.dataFrameWriter.format(varargin{:});

end %function
