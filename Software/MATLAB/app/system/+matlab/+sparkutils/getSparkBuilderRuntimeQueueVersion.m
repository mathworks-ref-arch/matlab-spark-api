function v = getSparkBuilderRuntimeQueueVersion()
    % getSparkBuilderRuntimeQueueVersion Retrieve version from pom-file
    
    % Copyright 2022 The MathWorks, Inc.
   
    swRoot = fileparts(getSparkApiRoot());
    pomFile = fullfile(swRoot, 'Java', 'RuntimeQueue', 'pom.xml');
    
    X = xmlread(pomFile);
    
    projNode = X.getElementsByTagName('project').item(0);
    versionElement = projNode.getElementsByTagName('version').item(0);
    templateVersion = versionElement.getTextContent();
    
    v = string(templateVersion);
    
end