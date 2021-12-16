classdef Catalog < handle
    % CATALOG Class wrapping the Java Catalog object
    
    % Copyright 2020 The MathWorks, Inc.

    properties(Access=public, Hidden=true)
       catalog 
    end
    
    methods
        function obj = Catalog(catalogObject)
            obj.catalog = catalogObject;
        end
    end
end
