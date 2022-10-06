classdef PythonPackageOptions < handle
    % PythonPackageOptions Internal class to handle earlier releases
    %
    %  Please refer to the documentation delivered in this package for
    %  PythonSparkBuilder for usage examples.
    
    % Copyright 2022 MathWorks, Inc.
    
    properties
        FunctionFiles cell
        PackageName char
        SampleGenerationFiles cell
        AdditionalFiles cell
        AutoDetectDataFiles logical = true
        SupportPackages = {'autodetect'}
        Verbose logical = false
        OutputDir char
    end
    methods
        function obj = PythonPackageOptions(files, varargin)
            narginchk(1,2*numel(properties(compiler.build.spark.internal.PythonPackageOptions.empty))-1)
            
            obj.FunctionFiles = argToCellArray(files);
            init(obj, varargin{:});
            
        end
        
    end
    
    methods( Access=private)
        
        function init(obj, varargin)
            N = length(varargin);
            if rem(N,2) ~= 0
                error('SPARKAPI:python_package_options_uneven', ...
                    "Optional arguments can only come in pairs");
            end
            props = properties(obj);
            for k=1:2:N
                prop = varargin{k};
                value = varargin{k+1};
                if ismember(prop, props)
                    if ismember(prop, {'AdditionalFiles'})
                        obj.(prop) = argToCellArray(value);
                    else
                        obj.(prop) = value;
                    end
                else
                    error('SPARKAPI:python_package_options_unknown', ...
                        "The option '%s' is not supported with this class", prop);
                end
            end
        end
    end
    
    
end

function cArray = argToCellArray(argument)
    if ischar(argument)
        cArray = {argument};
    elseif isstring(argument)
        N = numel(argument);
        cArray = cell(1, N);
        for k=1:N
            cArray{k} = char(argument(k));
        end
    elseif iscell(argument)
        cArray = argument;
    else
        error('SPARKAPI:bad_files_type', ...
            "The argument for this property should be a simple string, a cell of character arrays, or a a character array")
    end
    
end
