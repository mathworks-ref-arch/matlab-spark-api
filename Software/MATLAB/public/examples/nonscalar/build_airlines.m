function SB = build_airlines()
    % build_airlines Build functions for testing performance

    % Copyright 2021 The MathWorks, Inc.

    % This is the Builder object, which takes care of the build process
    SB = compiler.build.spark.SparkBuilder('outFolder', 'com.mw.airlines');
    SB.Verbose = true;

    % We need at least one Java class to associate our files with
    JC1 = compiler.build.spark.JavaClass("Airline");

    % We then create the File objects for the files we want compiled
    % For the first  one, we add arguments describing the input and output
    % types of the function
    dabd = compiler.build.spark.File("deltaArrivalByDistance", {"int32", "int32", "int32"}, {"double"}); %#ok<STRSCALR,CLARRSTR>

    sam = compiler.build.spark.File("sumandmul", {"double", "double"}, {"double", "double"}); %#ok<STRSCALR,CLARRSTR>


    % When we have the files, we add them to the JavaClass object we created
    JC1.addBuildFile(dabd);
    JC1.addBuildFile(sam);

    % Finally, we add the JavaClass to the Builder object.
    SB.addClass(JC1);

    % The object returned from this function can now be used to make a build
    % SB.build

end
