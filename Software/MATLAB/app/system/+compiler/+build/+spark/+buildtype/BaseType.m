classdef BaseType < handle
    % BaseType Base type for Spark Build types
    
    % Copyright 2021 The MathWorks, Inc.
   
    properties
        SB % SparkBuilder reference
    end
    
    methods (Abstract)
       opts = mccOpts(obj)
       str = getBuildTarget(obj)
       str = getLinkArgument(obj)
       str = getClassBuild(obj)
    end
    
    methods
        function log(obj, varargin)
           obj.SB.log(varargin{:}); 
        end
    end
end