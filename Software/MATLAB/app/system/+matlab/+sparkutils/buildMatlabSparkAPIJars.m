function tf = buildMatlabSparkAPIJars(options)
    % buildMatlabSparkAPIJars High-level wrapper file to build Jar files used by matlab-spark-api
    % Returns true if all builds succeed.

    % Copyright 2022 MathWorks Inc.

    arguments
        options.sparkVersion (1,1) string = ""
    end

    disp(newline);
    disp('======================');
    disp('Building Spark Utility');
    disp('======================');
    disp(newline);
    if strlength(options.sparkVersion) > 0
        [r,s] = matlab.sparkutils.buildMatlabSparkUtility('sparkVersion', options.sparkVersion);
    else
        [r,s] = matlab.sparkutils.buildMatlabSparkUtility();
    end
    if r ~= 0
        warning('MATLABSparkAPI:buildMatlabSparkAPIJars',...
            'Error building SparkUtility: %s', s);
        suTf = false;
    else
        suTf = true;
    end


    disp(newline);
    disp('======================');
    disp('Building Runtime Queue');
    disp('======================');
    disp(newline);
    [r,s] = matlab.sparkutils.buildRuntimeQueueJar();
    if r ~= 0
        warning('MATLABSparkAPI:buildMatlabSparkAPIJars',...
            'Error building RuntimeQueue: %s', s);
        rtqTf = false;
    else
        rtqTf = true;
    end


    disp(newline);
    disp('===============');
    disp('Builds Complete');
    disp('===============');
    disp(newline);

    tf = suTf && rtqTf;
end
