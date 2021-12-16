classdef DataFrameReader < handle % < databricks.Object
% DATAFRAMEREADER Interface used to load a Dataset from external storage systems 
% This object can be used to read from external storage systems such as 
% file systems, key-value stores, etc. 
% 
% Use SparkSession.read() to access this.

 
%                 Copyright 2019 MathWorks, Inc. 
%                 $Id$

properties(Hidden)
    dataFrameReader;
end

methods
	%% Constructor 
	function obj = DataFrameReader(varargin)
        % Store the handle if provided
        if nargin==1
            obj.dataFrameReader = varargin{1};
        end
	end
end

end %class