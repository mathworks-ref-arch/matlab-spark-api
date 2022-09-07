function build(obj)
    % build - Build method for the SparkBuilder Class 
    %
    % This method will go through the different build stages, i.e.
    %   * Cleanup
    %   * Directory creation
    %   * Helper function generation
    %   * MCC compilation
    %   * Wrapper generation
    %   * Rebuild (after wrapper generation)
    %   * Jar name adaptation
    %   * Spark helper generation

    % Copyright 2021-2022 The MathWorks, Inc.

    if exist(obj.outputFolder, 'dir')
        obj.log("Deleting old output folder '%s'", obj.outputFolder);
        rmdir(obj.outputFolder, 's');
    end
    obj.log("Create output folder '%s'", obj.outputFolder);
    mkdir(obj.outputFolder);

    genPartitionHelpers(obj);

    mccStr = mccCommand(obj);
    obj.log('Executing build command:\n%s\n', mccStr);

    t0 = tic;
    mccOutput = evalc(mccStr);
    obj.log("Time for mcc: %.1f\n", toc(t0));

    if obj.needsPostProcessing
        parseCommands(obj, mccOutput);

        % Fix serialization issue, if needed.
        fixSerializable(obj.javaClasses(1));

        obj.log("Generating wrapper file(s)\n");
        obj.generateWrapperFile();

        obj.rerunBuild();

        obj.fixJarName();

        obj.generateSparkShellHelper();
    end

    setInfo(obj);

end

