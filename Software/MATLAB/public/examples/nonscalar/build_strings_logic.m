function SB = build_strings_logic
    % build_strings_logic Example using SparkBuilder

    % Copyright 2021 The MathWorks, Inc.
    
    SB = compiler.build.spark.SparkBuilder('./outFolder', 'com.mw.signals');
    
    JC = compiler.build.spark.JavaClass('TypeTest');
    
    func_1 = compiler.build.spark.File(getSparkApiRoot('test', 'fixtures', 'diffArgsFunc.m'), ...
        {{"string", [1, inf]}, {"logical", [1, inf]}, "string", "logical", {"int16", [1, inf]}}, ...
        {{"string", [1, inf]}, {"logical", [1, inf]}, "string", "logical", {"int16", [1, inf]}} ...
        );
    func_fft = compiler.build.spark.File("myfft", {{"double", [1, inf]}}, {{"double", [1, inf]}});

    dabd = compiler.build.spark.File("deltaArrivalByDistance", {"int32", "int32", "int32"}, {"double"}); %#ok<STRSCALR,CLARRSTR>
    
    sam = compiler.build.spark.File("sumandmul", {"double", "double"}, {"double", "double"}); %#ok<STRSCALR,CLARRSTR>
    posf = compiler.build.spark.File("ispos", {"double"}, {"logical"}); %#ok<STRSCALR,CLARRSTR>

    se1 = compiler.build.spark.File("sideEffect", {"string"}, {}); %#ok<STRSCALR,CLARRSTR>
    se2 = compiler.build.spark.File("sideEffectTwo", {"double", "int32", "string"}, {}); %#ok<STRSCALR,CLARRSTR>
    JC.addBuildFile(func_1);
    JC.addBuildFile(func_fft);
    JC.addBuildFile(dabd);
    JC.addBuildFile(sam);
    JC.addBuildFile(posf);
    JC.addBuildFile(se1);
    JC.addBuildFile(se2);
    
    SB.addClass(JC);
    
    
end