function [r,s] = buildMatlabSparkUtility(sparkVer)
    % buildMatlabSparkUtility Start a Maven build for the MATLAB Spark Utility
    %
    % This function will start a Maven build of the MATLAB Spark Utility.
    % To run this function, it is necessary to run it on a system with
    % Java and Maven properly configured.
    %
    % It relies on information from matlab.sparkutility.Config, to use the
    % correct information.
    
    % Copyright 2020 MathWorks Inc.
   
    % If the databricks package is available use it to provide a warning
    if isDatabricksEnvironment
        if exist(detectProxy, 'file') == 2
            [tf, proxyUri] = detectProxy();
            if tf
                mvnProxyHelp = "https://maven.apache.org/guides/mini/guide-proxies.html";
                warning("A HTTP proxy has been detected: %s\nEnsure Maven has been configured to use the proxy if necessary: %s", proxyUri.EncodedURI, mvnProxyHelp);
            end
        end
    end

    swRoot = fileparts(getSparkApiRoot());
    sparkUtilityDir = fullfile(swRoot, 'Java', 'SparkUtility');
    
    old = cd(sparkUtilityDir);
    goBack = onCleanup(@() cd(old));
    
    C = matlab.sparkutils.Config.getInMemoryConfig();
    if nargin ~= 0
        C.CurrentVersion = sparkVer;
    end
    
    mvnCmd = C.genMavenBuildCommand();
    fprintf("Running:\n\t%s\n", mvnCmd);
    [r,s] = system(mvnCmd, '-echo');

    if ~isDatabricksEnvironment
        mvnCmd = C.genMavenBuildCommand("Databricks");
        fprintf("Running:\n\t%s\n", mvnCmd);
        [r2,s2] = system(mvnCmd, '-echo');
    end
    
end
