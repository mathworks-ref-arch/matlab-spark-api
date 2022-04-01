classdef DataFrameNaFunctions < handle
    % DataFrameNaFunctions A class with certain operations on Datasets
    %
    
    % Copyright 2022 MathWorks, Inc.
    
    properties (Hidden)
        na
    end
    
    methods
        %% Constructor
        function obj = DataFrameNaFunctions(naObj)
                obj.na = naObj;
        end

    end
    
end %class