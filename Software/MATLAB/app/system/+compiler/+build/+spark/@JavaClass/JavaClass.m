classdef JavaClass < handle
    % JAVACLASS Class for generating a Javaclass with MATLAB Compiler SDK
    %
    % This class contains methods for adapting the generated code of the
    % corrsponding Java files.
    
    % Copyright 2021-2022 The MathWorks, Inc.
    
    properties (SetAccess = private)
        name string
        files compiler.build.spark.File
        ephemeralFiles compiler.build.spark.File
        injections = {}
        buildFiles
    end
    
    properties (Hidden = true)
        parent
    end
    
    properties (SetAccess = private, Dependent = true)
        WrapperName
    end
    
    methods
        function obj = JavaClass(name, fileList)
            % TODO type checking
            obj.name = string(name);
            
            if nargin > 1
                % Build files can be add to the class later too.
                if iscell(fileList)
                    for k=1:length(fileList)
                        obj.addBuildFile(fileList{k})
                    end
                else
                    for k=1:length(fileList)
                        obj.addBuildFile(fileList(k))
                    end
                end
            end
        end
        
        function addBuildFile(obj, file, ephemeral)
            if nargin < 3
                ephemeral = false;
            end
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
            if ephemeral
                obj.ephemeralFiles(end+1) = F;
            else
                obj.files(end+1) = F;
            end
        end
        
        function buildTgt = getBuildTarget(obj, pkg)
            buildTgt = sprintf(' ''java:%s,%s''', pkg, obj.name);
        end
        
        function build = getClassBuild(obj)
            fn = getFileNames(obj);
            efn = getEphemeralFileNames(obj);
            build = sprintf(' class{%s:%s}', ...
                obj.name, ...
                join([fn(:);efn(:)], ","));
        end
        
        function addInjection(obj, func)
            obj.injections{end+1} = func;
        end
        
        function fileNames = getFileNames(obj)
            fileNames = [obj.files.name];
        end
        
        function fileNames = getEphemeralFileNames(obj)
            fileNames = [obj.ephemeralFiles.name];
        end
        
        function runInjections(obj, package)
            obj.buildFiles = string.empty;
            N = numel(obj.injections);
            fprintf("%s\n", obj.name);
            fprintf("Running %d injections ...\n", N);
            
            for k=1:N
                injection = obj.injections{k};
                fprintf("Running #%d/%d - %s ...\n", k, N, char(injection));
                injection(obj, package)
                % feval(injection, obj, package);
            end
        end
        function genPartitionHelpers(obj)
            % First, remove any ephemeral files
            obj.ephemeralFiles(1:end) = [];
            
            fileNames = getFileNames(obj);
            for k = 1:length(obj.files)
                F = obj.files(k);
                if F.ExcludeFromWrapper
                    continue
                end
                
                if F.TableInterface
                    partitionName = F.funcName + "_table";
                    if ismember(partitionName, fileNames)
                        % This has already been generated
                        continue;
                    end
                    outName = genPartitionTableFile(obj, F, partitionName);
                else
                    partitionName = F.funcName + "_partition";
                    if ismember(partitionName, fileNames)
                        % This has already been generated
                        continue;
                    end
                    outName = genPartitionFile(obj, F, partitionName);
                end
                newFile = compiler.build.spark.File(outName, {'double'}, {'double'});
                
                newFile.ExcludeFromWrapper = true;
                obj.addBuildFile(newFile, true);
            end
        end
        
        function outName = genPartitionFile(obj, F, partitionName)
            mlDir = obj.parent.GenMatlabDir;
            outName = fullfile(mlDir, partitionName + ".m");
            
            SW = matlab.sparkutils.StringWriter(outName);
           if F.nArgOut == 0
               SW.pf("function %s(rows)\n", partitionName);
           else
               SW.pf("function RESULT = %s(rows)\n", partitionName);
           end

            SW.indent();
            SW.pf("%% %s Generated function for use with mapPartition method\n", partitionName);
            SW.pf("\n");
            SW.pf("N = size(rows, 1);\n");
            if F.nArgOut > 0
                SW.pf("RESULT = cell(N,1);\n");
            end
            SW.pf("for k=1:N\n");
            SW.indent();
            if F.nArgOut == 0
                SW.pf("%s(rows{k, :});\n", F.funcName);
            elseif F.nArgOut == 1
                SW.pf("RESULT{k} = %s(rows{k,:});\n", F.funcName);
            else
                argNames = F.getArgArray("out", "Y");
                argsJoined = argNames.join(", ");
                SW.pf("[%s] = %s(rows{k, :});\n",argsJoined, F.funcName);
                SW.pf("RESULT{k} = {%s};\n", argsJoined);
            end
            SW.unindent();
            SW.pf("end\n");
            SW.unindent();
            SW.pf("end\n\n");
            SW.pf("%% End of file: %s\n\n", partitionName);
        end
        
        function outName = genPartitionTableFile(obj, F, partitionName)
            mlDir = obj.parent.GenMatlabDir;
            outName = fullfile(mlDir, partitionName + ".m");
            
            SW = matlab.sparkutils.StringWriter(outName);
            
            SW.pf("function RESULT = %s(%s)\n", partitionName, F.generateJavaTableHelperArgs("cellTable"));
            SW.indent();
            SW.pf('%% %s Generated function for use with mapPartition method\n', partitionName);
            SW.pf('%%\n');
            SW.pf('%% This version takes a cell as input and returns a cell as output.\n');
            SW.pf('%% It assumes the underlying function takes a table and returns a table.\n\n');
            SW.pf('T_IN = cell2table(cellTable, ...\n');
            SW.indent();
            inputNames = F.InTypes(1).names;
            inputString = arrayfun(@(x) sprintf("""%s""", x), inputNames).join(", ");
            SW.pf('"VariableNames", [%s]);\n\n', inputString);
            SW.unindent();
            if F.TableAggregate
                SW.pf("%% Run the actual algorithm\n");

                SW.pf("OUT_C = cell(1, %d);\n", F.nArgOut);
                SW.pf("[OUT_C{:}] = %s(%s);\n\n", F.funcName, F.generateJavaTableHelperArgs("T_IN"));

                SW.pf("RESULT = OUT_C;\n")
            else
                SW.pf('T_OUT = %s(%s);\n\n', F.funcName, ...
                    F.generateJavaTableHelperArgs("T_IN"));
                SW.pf('RESULT = table2cell(T_OUT);\n\n');
            end
            SW.unindent();
            SW.pf("end\n\n");
            SW.pf("%% End of file: %s\n\n", partitionName);
            
        end

        function fullName = getFullClassName(obj)
            fullName = string(obj.parent.package) + "." + string(obj.name);
        end

        function name = getMCRFactoryName(obj)
            pkg = obj.parent.package;
            pkgParts = split(string(pkg), ".");
            name = char(pkgParts(end));
            name(1) = upper(name(1));
            name = [pkg, '.', name, 'MCRFactory'];
        end

    end
    
    methods % Set/Get methods
        function WN = get.WrapperName(obj)
            WN = obj.name + "Wrapper";
        end
    end
    
end