function result = buildSparkJarTask(filePath, varargin)
    % buildSparkJarTask Builds a Spark Jar Task Jar
    %
    % This is a helper function for building a SparkJarTask. In its
    % simplest form, it takes 1 argument, the name of the file to compile.
    %
    % buildResults = buildSparkJarTask('myDeployment');
    %
    % The return value is a struct containing information about the Jar
    % built, with the name of the Jar, the output folder and the full class
    % name.
    %
    % The function takes these optional arguments, always in name/value
    % pairs.
    % 
    % ClassName -    The name of the class to be built (without package
    %                name), default value 'JarTask' 
    % Package -      The Java package to put this class in, default value
    %               'com.mathworks.spark.example' 
    % BuildFolder - The name of the output folder, default value
    %               'buildFolder'
    %    
    % Please see:
    % https://www.mathworks.com/help/compiler/spark/example-on-deploying-applications-to-spark-using-the-matlab-api-for-spark.html
    % Returns a non empty jar file path on success
    
    % Copyright 2021 MathWorks, Inc.

    validString = @(x) ischar(x) || isStringScalar(x);
    
    p = inputParser;
    p.addRequired('filePath', validString);
    p.addParameter('ClassName', 'JarTask', validString);
    p.addParameter('Package', 'com.mathworks.spark.example', validString);
    p.addParameter('BuildFolder', 'buildFolder', validString);
    
    % Parse and setup the parameters
    p.parse(filePath, varargin{:});

    filePath = char(p.Results.filePath);
    ClassName = p.Results.ClassName;
    Package = p.Results.Package;
    BuildFolder = p.Results.BuildFolder;
    
    checkPlatformCompatibility();
    
    if exist(filePath, 'file') ~= 2
        error(['File not found: ', filePath]);
    end
    
    SB = compiler.build.spark.SparkBuilder(BuildFolder, Package);
    SB.BuildType = "SparkTall";
    SB.Verbose = true;
    
    % We need at least one Java class to associate our files with
    JC = compiler.build.spark.JavaClass(ClassName);
    
    % We then create the File objects for the files we want compiled
    % For the first  one, we add arguments describing the input and output
    % types of the function
    dpt = compiler.build.spark.File(filePath);
    dpt.ExcludeFromWrapper = true;
    
    
    % When we have the files, we add them to the JavaClass object we created
    JC.addBuildFile(dpt);
    
    % Finally, we add the JavaClass to the Builder object.
    SB.addClass(JC);
    
    SB.build

    jarFile = dir(fullfile(BuildFolder, '*.jar'));
    result = struct( ...
        'BuildFolder', BuildFolder, ...
        'JarFile', jarFile.name, ...
        'FullJarFile', fullfile(jarFile.folder, jarFile.name), ...
        'ClassName', SB.package + "." + SB.javaClasses(1).name ...
        );
    
end

function checkPlatformCompatibility()
        if ispc || ismac
        if verLessThan('matlab','9.8') % 9.8 is R2020a
            error('On non Linux platforms only MATLAB release 2020a and later support compilation for deployment to Databricks Linux nodes');
        end
        if exist([matlabroot, filesep, 'toolbox', filesep, 'compiler_sdk'], 'dir') ~= 7
            error('Compiler SDK toolbox directory not found, Compiler SDK is required for the build process, check installed toolboxes using the ver command');
        end
        if verLessThan('compiler_sdk','6.8') % 6.8 is the R2020a version
            error('Compiler SDK version 6.8 or later is required, use the ver command to check installed version');
        end
        if exist([matlabroot, filesep, 'toolbox', filesep, 'compiler', filesep, 'mlspark', filesep, 'jars', filesep, '2.x', filesep, 'mlsubmit.jar'], 'file') ~= 2
            error('MATLAB installation must be patched to add mlsubmit.jar support to allow compilation for Linux Spark nodes, see Documentation/FAQ.md');
        end
    elseif isunix
        if verLessThan('matlab','9.7') % 9.7 is R2019b
            error('On Linux platforms only MATLAB release 2019b and later support compilation for deployment to Databricks Linux nodes');
        end
        if exist([matlabroot, filesep, 'toolbox', filesep, 'compiler_sdk'], 'dir') ~= 7
            error('Compiler SDK toolbox directory not found, Compiler SDK is required for the build process, check installed toolboxes using the ver command');
        end
        if verLessThan('compiler_sdk','6.7')
            error('Compiler SDK version 6.7 or later is required, use the ver command to check installed version');
        end
    else
        error('Unsupported platform');
    end
end