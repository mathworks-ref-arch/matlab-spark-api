function [r,s] = buildMatlabSparkUtility(sparkVer)
    % buildMatlabSparkUtility Start a Maven build for the MATLAB Spark Utility
    %
    % This function will start a Maven build of the MATLAB Spark Utility.
    % To run this function, it is necessary to run it on a system with
    % Java and Maven properly configured.
    %
    % It relies on information from matlab.sparkutility.Config, to use the
    % correct information.
    
    % Copyright 2020-2022 MathWorks Inc.
   
    warning('SPARKAPI:buildmatlabsparkutility_moved', ...
            "This function has been deprecated and will be removed in a future release.\n" + ...
            "Please use matlab.sparkutils.buildMatlabSparkUtility instead.\n");

    if nargin == 0
        [r,s] = matlab.sparkutils.buildMatlabSparkUtility();
    else
        [r,s] = matlab.sparkutils.buildMatlabSparkUtility('sparkVersion', sparkVer);
    end

end