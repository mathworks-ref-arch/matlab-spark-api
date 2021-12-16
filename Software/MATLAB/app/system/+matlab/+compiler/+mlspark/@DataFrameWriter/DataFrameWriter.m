classdef DataFrameWriter  
% DATAFRAMEWRITER Interface to write datasets to external storage systems
%  This object can be used to write to external storage systems such as 
% file systems, key-value stores, etc. 
% 
% Use SparkSession.write() to access this.

 
%                 Copyright 2020 MathWorks, Inc. 
%                 $Id$

properties(Hidden)
    dataFrameWriter;
end

methods
	%% Constructor 
	function obj = DataFrameWriter(varargin)
        % Store the handle if provided
        if nargin==1
            obj.dataFrameWriter = varargin{1};
        end
	end
end
end %class