classdef PythonSparkBuilder < handle
    % PythonSparkBuilder Class for compiling MATLAB files for Spark
    %
    % This class is a wrapper for the build process in different
    % SparkContexts. 
    % The base, and most important use case, is for building Python
    % libraries, with wrappers for making the code more palatable to Spark.
    %
    %  Please refer to the documentation delivered in this package for
    %  usage examples.
    
    % Copyright 2022 The MathWorks, Inc.
    
    properties
    end

    properties (SetAccess = protected)
        BuildResults
        BuildOpts
        PkgName
        PkgFolder
        OutputDir
        SrcDir
        Files compiler.build.spark.File
        GenMatlabDir string
        HelperFiles string
    end

    properties (SetAccess = protected, Hidden)
        PkgNameParts
        WrapperClassName
    end    

    methods
        function obj = PythonSparkBuilder(initArg)
            switch class(initArg)
                case 'compiler.build.PythonPackageOptions'
                    obj.BuildOpts = initArg;
                case 'compiler.build.Results'
                    obj.BuildResults = initArg;
                    obj.BuildOpts = obj.BuildResults.Options;
                otherwise
                    error('SPARK_API:bad_pythonsparkbuilder_arguments', ...
                        'Wrong type of arguments for the PythonSparkBuilder class')
            end
            init(obj);
        end

        function addFile(obj, file)
            if isa(file, 'compiler.build.spark.File')
                F = file;
            else
                if iscell(file)
                    F = compiler.build.spark.File(file{:});
                else
                    [raw, args]  = compiler.build.spark.types.getFileArgumentInfo(file);
                    F = compiler.build.spark.File(file, args{:});
                end
            end

            obj.Files(end+1) = F;
        end

    end

    methods (Access = protected)
        function init(obj)
            obj.PkgName = string(obj.BuildOpts.PackageName);
            obj.PkgNameParts = split(obj.PkgName, ".");

            obj.OutputDir = string(obj.BuildOpts.OutputDir);
            
            parts=split(obj.PkgName, ".");
            N = length(parts);
            srcDir = obj.OutputDir;
            for k=1:N
                srcDir = fullfile(srcDir, parts(k));
            end
            obj.SrcDir = srcDir;

            funcFiles = obj.BuildOpts.FunctionFiles;
            for k=1:length(funcFiles)
                obj.addFile(funcFiles{k});
            end
        end

        function [raw, args]  = getFileArguments(~, file)
            raw = struct.empty;
            args = {};
            helpText = help(file);
            tok=regexp(helpText, '@SB-Start@(.+)@SB-End@', 'tokens', 'once');
            if ~isempty(tok)
                % First try JSON
                try
                    raw = jsondecode(tok{1});
                catch ex
                    % Evidently, this isn't JSON
                end
                if isempty(raw) && hasYAMLParser()
                    try
                        raw = yamldecode('string', tok{1});
                    catch ex
                        % Evidently, this isn't YAML
                    end
                end
                if isfield(raw, 'InTypes') && isfield(raw, 'OutTypes')
                    args = {raw.InTypes, raw.OutTypes};
                end
            end
            if isempty(raw)
                % If datatype information is not in the comments, it may be
                % in an external JSON file 
                jsonFileName = compiler.build.spark.internal.getJSONName(file);
                if isfile(jsonFileName)
                    raw = jsondecode(fileread(jsonFileName));
                    args = {raw.InTypes, raw.OutTypes};
                end

            end

        end

        % Methods defined outside of this function
        generateFunctionWrapper(obj, SW, fileObj)
        genPartitionHelperFiles(obj, F)
        
    end
    
    
end

function ok = hasYAMLParser()
    ok = exist('mx_yaml', 'file') ~= 0;
end
