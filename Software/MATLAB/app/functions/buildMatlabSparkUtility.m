function [r,s] = buildMatlabSparkUtility(sparkVer)
    % buildMatlabSparkUtility Start a Maven build for the MATLAB Spark Utility
    %
    % This function will start a Maven build of the MATLAB Spark Utility.
    % To run this function, it's also necessary to run it on a system with
    % Java and Maven properly configured.
    %
    % It relies on information from matlab.sparkutility.Config, to use the
    % correct information.
    
    % Copyright 2020 MathWorks Inc.
   
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