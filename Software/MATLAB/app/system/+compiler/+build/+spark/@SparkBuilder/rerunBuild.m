function rerunBuild(obj)
    % rerunBuild Runs the build steps after modification

    % Copyright 2021-2022 The MathWorks, Inc.

    % First remove old Jars
    delete(fullfile(obj.outputFolder, '*.jar'));

    % Add these small Jars inline, to make deployment easier
    fprintf('Add matlab-spark-utility classes\n');
    sparkUtility = matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true, 'shaded', false);
    addExistingJar(obj, sparkUtility);

    fprintf('Add matlab-encoders classes\n');
    encoderUtility = matlab.sparkutils.getSparkMATLABEncodersFullName();
    addExistingJar(obj, encoderUtility);
   
    fprintf('Compile: \n');
    [rc,sc] = obj.runCommand(adaptCompileCmd(obj));

    fprintf('Jar: \n');
    [rj,sj] = obj.runCommand(obj.jarCmd);

    fprintf('Doc: \n');
    [rd,sd] = obj.runCommand(obj.extendJavaClassPath(obj.docCmd));

    setInfo(obj);
end

function addExistingJar(obj, jarFile)
    classDir = fullfile(obj.outputFolder, 'classes');
    unzip(jarFile, classDir)

end
