function build(obj, options)
    % build Start the build
    %
    % The build method takes a few optional arguments. In almost all cases,
    % they can (and should) be left at their default values.
    %
    %  clean - remove previous build (default: true)
    %  genHelpers - Generate the partition helpers (default: true)
    %  genWrappers - Generate the wrapper file (default: true)
    %  createWheel - Create the wheel file (default: true)

    % Copyright 2022 The MathWorks, Inc.

    arguments
        obj (1,1) compiler.build.spark.PythonSparkBuilder
        options.clean (1,1) logical = true
        options.genHelpers (1,1) logical = true
        options.genWrappers (1,1) logical = true
        options.createWheel (1,1) logical = true
    end

    if options.clean
        obj.clean();
    end

    if options.genHelpers
        obj.genPartitionHelpers();
    end

    buildOpts = addHelperFilesToBuild(obj);

    if compiler.build.spark.internal.hasShippingPythonPackage()
        obj.BuildResults = compiler.build.pythonPackage(buildOpts);
    else
        obj.BuildResults = compiler.build.spark.internal.pythonPackage(buildOpts);
    end
    
    % Overwrite the original setup.py file, to comply with things like
    % bdist_wheel
    obj.genPythonSetup();

    if options.genWrappers
        % Generate a wrapper file, that creates Spark friendly interfaces
        obj.generateWrapper();
    end

    
    % Now package all the functions in a wheel
    if options.createWheel
        obj.createWheel();

        % Create a shell-file for easy testing in local Spark
        obj.generateSparkShellHelper();

        % Generate example files
        obj.generatePythonExample();

    end


end
