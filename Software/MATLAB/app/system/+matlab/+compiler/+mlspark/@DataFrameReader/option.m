function obj = option(obj, varargin)
% OPTION Method to specify input options for the underlying data source
% The configuration of the underlying input options control how the data
% source is handled.
% 
% For example, to indicate that the input CSV has a header lines and is
% clean enough to infer the schema:
% 
%     myDataSet = spark...
%         .read.format('csv')...
%         .option('header','true')...
%         .option('inferSchema','true')...
%         .load(inputLocation);


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

obj.dataFrameReader.option(varargin{:});

end %function
