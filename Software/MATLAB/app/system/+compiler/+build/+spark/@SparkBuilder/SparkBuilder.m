classdef SparkBuilder < handle
    % SparkBuilder Class for compiling MATLAB files for Spark
    %
    % This class is a wrapper for the build process in different
    % SparkContexts. 
    % The base, and most important use case, is for building a Java
    % libraries, with wrappers for making the code more palatable to Spark.
    %
    %  Please refer to the documentation delivered in this package for
    %  usage examples.
    
    % Copyright 2021 The MathWorks, Inc.
    
    properties
        outputFolder
        package
        Verbose = false
        AddReleaseToName = true
    end
    properties (Dependent=true)
        BuildType
    end
    
    properties (Hidden=true)
        Debug = false
        Metrics = false
        mccOptions = '-vW';
        JavaHome
        JavacOpts = '-J-Xmx196M -verbose'
        JarOpts = '-vcf';
        DocOpts = '';
        GenMatlabDir
    end
    properties (SetAccess=private)
        javaClasses
        Info
    end
    properties (SetAccess=private, Hidden=true)
        buildFiles
        packageDependencies
        compileDependencies
    end
    properties (SetAccess=private, Hidden=true)
        BuildType_
    end
    properties (SetAccess=private, Hidden=true)
        compileCmd
        jarCmd
        docCmd
    end
    
    methods
        function obj = SparkBuilder(outFolder, pkg)
            obj.outputFolder = outFolder;
            obj.package = pkg;
            obj.BuildType = "JavaLib";
            init(obj);
        end
        
        
        function mccStr = mccCommand(obj)
            obj.log("Generating mcc command for build type '%s'", class(obj.BuildType));
            mccStr = ['mcc ', obj.BuildType.mccOpts];
                        
            mccStr = [mccStr, getBuildTarget(obj.BuildType)];
            mccStr = [mccStr, getLinkArgument(obj.BuildType)];
            mccStr = [mccStr, sprintf(' -d %s', obj.outputFolder)];
            mccStr = [mccStr, getClassBuild(obj.BuildType)];
            
            for k=1:length(obj.packageDependencies)
                mccStr = [mccStr, sprintf(' -a %s', obj.packageDependencies(k))];   %#ok<AGROW>
            end
        end
                       
        function addClass(obj, classObj)
            if isempty(obj.javaClasses)
                obj.javaClasses = classObj;
            else
                obj.javaClasses(end+1) = classObj;
            end
            classObj.parent = obj;
        end
               
        function addPackageDependency(obj, dep)
            dep = string(dep);
            if isempty(obj.packageDependencies)
                obj.packageDependencies = dep(:);
            else
                obj.packageDependencies = [obj.packageDependencies; dep(:)];
            end
        end
        
        function addCompileDependency(obj, dep)
            if isempty(obj.compileDependencies)
                obj.compileDependencies = dep(:);
            else
                obj.compileDependencies = [obj.compileDependencies; dep(:)];
            end
        end
        
        function newCmd = adaptCompileCmd(obj)
            %             extraClassPath = join(obj.compileDependencies, ":");
            %             newCmd = regexprep(obj.compileCmd, '-classpath[^"]+"([^"]+)"', ...
            %                 ['-classpath "$1', pathsep, char(extraClassPath), '"']);
            newCmd = obj.extendJavaClassPath(obj.compileCmd);
            %             for j=1:length(obj.javaClasses)
            %                 JC = obj.javaClasses(j);
            %                 for k=1:length(JC.buildFiles)
            %                     JF = JC.buildFiles(k);
            %                     newCmd = [newCmd, sprintf(' "%s"', fullfile(obj.outputFolder, JF))]; %#ok<AGROW>
            %                 end
            %             end
            for j=1:length(obj.buildFiles)
                newCmd = [newCmd, sprintf(' "%s"', fullfile(obj.outputFolder, obj.buildFiles(j)))]; %#ok<AGROW>
            end
            newCmd = strrep(newCmd, '-classpath', '-source 1.8 -target 1.8 -classpath');
        end
        
        function newCmd = extendJavaClassPath(obj, str)
            extraClassPath = join(obj.compileDependencies, pathsep);
            if ispc
                extraClassPath = strrep(extraClassPath, "\", "\\");
            end
            newCmd = regexprep(str, '-classpath[^"]+"([^"]+)"', ...
                ['-classpath "$1', pathsep, char(extraClassPath), '"']);
            
        end
        
        function genPartitionHelpers(obj)
            % if ~isa(obj.BuildType, 'compiler.build.spark.buildtype.JavaLib')
            %     return;
            % end

            obj.GenMatlabDir = fullfile(obj.outputFolder, 'matlab_helpers');
            if ~exist(obj.GenMatlabDir, 'dir')
                mkdir(obj.GenMatlabDir);
            end
            
            for k=1:length(obj.javaClasses)
               JC = obj.javaClasses(k);
               genPartitionHelpers(JC);
            end
        end
    end
    methods (Hidden)
        function genJavaCommands(obj)
            % May make more sense to generate the commands like this,
            % instead of doing text replacement in the parsed ones.
            %  compileCmd: '"/usr/lib/jvm/java-8-openjdk-amd64/bin/javac" -J-Xmx196M -verbose
            %               -classpath "/local/MATLAB/R2021a/toolbox/javabuilder/jar/javabuilder.jar"
            %               -d "bleep/classes" "bleep/pkg/ClassOne.java" "bleep/pkg/ClassTwo.java" "bleep/pkg/PkgMCRFactory.java"
            %               "bleep/pkg/ClassOneRemote.java" "bleep/pkg/ClassTwoRemote.java" "bleep/pkg/package-info.java"'
            %      jarCmd: '"/usr/lib/jvm/java-8-openjdk-amd64/bin/jar" -vcf "bleep/pkg.jar" -C "bleep/classes" .'
            %      docCmd: '"/usr/lib/jvm/java-8-openjdk-amd64/bin/javadoc" -d "bleep/doc/html" -sourcepath "bleep" -classpath "/local/MATLAB/R2021a/toolbox/javabuilder/jar/javabuilder.jar" pkg'
            %
            % adapteCompileCmd: '"/usr/lib/jvm/java-8-openjdk-amd64/bin/javac" -J-Xmx196M -verbose
            %                    -classpath "/local/MATLAB/R2021a/toolbox/javabuilder/jar/javabuilder.jar:/local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/delta-core_2.12-0.7.0.jar:/local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/spark-avro_2.12-3.0.1.jar:/local/EI-DTST/BigData/matlab-apache-spark/Software/MATLAB/sys/modules/matlab-spark-api/Software/MATLAB/lib/jar/matlab-spark-utility-shaded_3.0.1-0.2.7.jar"
            %                    -d "bleep/classes"
            %                    "bleep/pkg/ClassOne.java" "bleep/pkg/ClassTwo.java" "bleep/pkg/PkgMCRFactory.java"
            %                    "bleep/pkg/ClassOneRemote.java" "bleep/pkg/ClassTwoRemote.java" "bleep/pkg/package-info.java"
            %                    "bleep/pkg/ClassOneWrapper.java" "bleep/pkg/ClassTwoWrapper.java"'
            
            % === JAVAC ===
            cc = fullfile(obj.JavaHome, 'bin', 'javac');
            cc = [cc, ' ', obj.JavacOpts];
            cc = [cc, sprintf(' -classpath "%s"', obj.getClassPath(true))];
            cc = [cc, sprintf(' -d "%s"', fullfile(obj.outputFolder, obj.package))];
            jFiles = getJavaFiles(obj);
            cc = [cc, sprintf(' "%s"', jFiles)]
            
            % === JAR ===
            % "/usr/lib/jvm/java-8-openjdk-amd64/bin/jar" -vcf "bleep/pkg.jar" -C "bleep/classes" .'
            jc = fullfile(obj.JavaHome, 'bin', 'jar');
            jc = [jc, sprintf(' %s "%s"', obj.JarOpts, fullfile(obj.outputFolder, [obj.package, '.jar']))];
            %             classP = [obj.getJavaBuilder;obj.packageDependencies];
            %             jc = [jc, sprintf(' -C "%s"', classP.join(pathsep))]
        end

        function setInfo(obj)
            % setInfo Add info about build
            % This only adds some output information to the object, which
            % can be useful when used later.
            jarFile = dir(fullfile(obj.outputFolder, '*.jar'));
            obj.Info.JarFile = jarFile.name;
            obj.Info.FullJarFile = fullfile(jarFile.folder, jarFile.name);
            if obj.needsPostProcessing
                % Import strings and encoder functions are only needed in
                % the case of Spark wrappers
                importStr = string.empty;
                encoderStr = string.empty;
                for k=1:length(obj.javaClasses)
                    wrapperName = obj.javaClasses(k).WrapperName;
                    pkg = obj.package;
                    importStr(k) = "import " + pkg + "." + wrapperName + ";";
                    encoderStr(k) = wrapperName +  ".initEncoders(spark)";
                end
                obj.Info.Imports = importStr;
                obj.Info.EncoderInits = encoderStr;
            end
        end
    end
    
    methods (Access=private)
        function [r,s] = runCommand(obj, cmdStr)


            if ~obj.Verbose
                % It is set to non-verbose
                cmdStr = regexprep(cmdStr, '-verbose', '');
            else

            end
            fprintf('### Executing command:\n%s\n', cmdStr);
            [r,s] = system(cmdStr, '-echo');
            if r~=0
                error('Spark:ERROR', 'Problem executing %s\n', cmdStr)
            end
        end
        
        function init(obj)
            obj.JavaHome = getenv('JAVA_HOME');
            if isempty(obj.JavaHome)
                error('Spark:Error', 'No JAVA_HOME set on environment');
            end
            
            % We should add the correct Jar for compiling the wrapper files
            if isDatabricksEnvironment
                compileJar = databricksConnectJar() + string(pathsep) + ...
                    matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true, 'shaded', false);
            else
                compileJar = matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true, 'shaded', true);
            end
            
            obj.addCompileDependency( compileJar );
            obj.addCompileDependency( matlab.sparkutils.getSparkBuilderRuntimeQueueFullName());
            obj.addCompileDependency(matlab.sparkutils.getSparkMATLABEncodersFullName());
            
            obj.addPackageDependency(...
                matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true, 'shaded', false));
            
        end
        
        function jbPath = getJavaBuilder(~)
            jbPath = fullfile(matlabroot, 'toolbox', 'javabuilder', 'jar', 'javabuilder.jar');
        end
        
        function cp = getClassPath(obj, isCompilation)
            if isCompilation
                cpEntries = [obj.getJavaBuilder;obj.compileDependencies];
            else
                cpEntries = [obj.getJavaBuilder;obj.packageDependencies];
            end
            cp = join(cpEntries, pathsep);
        end
        
        function jFiles = getJavaFiles(obj)
            % Will we need to CD here? Depending on context where it's
            % called from. For now, assume we're calling it from the top level.
            here = cd(obj.outputFolder);
            goBack = onCleanup(@() cd(here));
            jFiles = findFileRecursively(obj.package, '.*.java');
        end
        
    end
    
    methods % Getters and Setters
        function BT = get.BuildType(obj)
            BT = obj.BuildType_;
        end
        
        function set.BuildType(obj, btString)
            switch btString
                case "JavaLib"
                    BT = compiler.build.spark.buildtype.JavaLib(obj);
                case "SparkApi"
                    BT = compiler.build.spark.buildtype.SparkApi(obj);
                case "SparkTall"
                    BT = compiler.build.spark.buildtype.SparkTall(obj);
                otherwise
                    error('SparkAPI:Error', 'Wrong BuildType');
            end
            obj.BuildType_ = BT;
        end
    end
    
    
end
