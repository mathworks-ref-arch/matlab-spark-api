function addSerializable(srcFolder)
    % addSerializable Adds Serializable to Java files in the srcFolder
    %
    % This is an internal function, and not part of the API.
    
    % Copyright 2021 MathWorks, Inc.
    
    generatedJavaFiles = findFileRecursively(srcFolder, ".*.java");
    % We could further reduce this list further, by ignoring files like
    % package-info.java and the .*Remote.java, but they don't contain
    % classes.
    % Search for public class entries.
    rx = "(public\s+class\s+[^\r\n]+)";
    serializeable = " implements java.io.Serializable";
    for k=1:length(generatedJavaFiles)
        curFile = generatedJavaFiles(k);
        compiler.build.spark.internal.changeLineInFile( ...
            curFile, rx, "append", serializeable);
    end
    
end


