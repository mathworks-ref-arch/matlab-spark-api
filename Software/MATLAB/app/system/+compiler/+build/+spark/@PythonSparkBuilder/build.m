function build(obj, options)
    % build Start the build
    %

    % Copyright 2022 The MathWorks, Inc.

    arguments
        obj (1,1) compiler.build.spark.PythonSparkBuilder
        options.clean (1,1) logical = true
        options.genHelpers (1,1) logical = true
        options.genWrappers (1,1) logical = true
    end

    if options.clean
        obj.clean();
    end

    if options.genHelpers
        obj.genPartitionHelpers();
    end

    buildOpts = addHelperFilesToBuild(obj);

    obj.BuildResults = compiler.build.pythonPackage(buildOpts);

    % Overwrite the original setup.py file, to comply with things like
    % bdist_wheel
    obj.genPythonSetup();

    if options.genWrappers
        % Generate a wrapper file, that creates Spark friendly interfaces
        obj.generateWrapper();
    end

    % Now package all the functions in a wheel
    obj.createWheel();

    % Create a shell-file for easy testing in local Spark
    obj.generateSparkShellHelper();

end
