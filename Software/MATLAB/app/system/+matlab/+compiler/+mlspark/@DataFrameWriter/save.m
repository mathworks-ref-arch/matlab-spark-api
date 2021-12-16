function save(obj, varargin)
% SAVE Method to save the dataset to external storage systems
% Use this method to save the object to storage in the specified format.
% 
% For example:
% 
%   outputLocation = '/delta/sampletable';
%   sparkDataSet...
%     .write.format("delta")...
%     .save(outputLocation);
% 


%                 Copyright 2019 MathWorks, Inc.
%                 $Id$

obj.dataFrameWriter.save(varargin{:});

end %function
