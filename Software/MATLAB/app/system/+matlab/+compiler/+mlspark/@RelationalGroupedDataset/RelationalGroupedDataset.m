classdef RelationalGroupedDataset < handle
    % RelationalGroupedDataset Special dataset, returned by methods like groupBy.
    %
    
    % Copyright 2020 The MathWorks, Inc.
    
    
    properties(Access=public, Hidden=true)
        % these properties are used internally
        
        % RelationalGroupedDataset
        rgDataset;
        
   end
    
    methods
        function obj = RelationalGroupedDataset(rgds)
            
            obj.rgDataset = rgds;
        end
    end
end
