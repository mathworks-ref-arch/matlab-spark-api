function SB = build_fft()
    % build_fft Example using SparkBuilder

    % Copyright 2021 The MathWorks, Inc.

    SB = compiler.build.spark.SparkBuilder('outFolder', 'com.mw.signals');
    SB.Verbose = true;

    JC = compiler.build.spark.JavaClass('SigProc');

    func_fft = compiler.build.spark.File("myfft", {{"double", [1, inf]}}, {{"double", [1, inf]}});
    func_twoarray = compiler.build.spark.File("twoArrays", {{"double", [1, inf]}, {"int32", [1, inf]}}, {{"double", [1, inf]}, {"int32", [1, inf]}});
    func_scalars =  compiler.build.spark.File("myscalars", ...
        ["double", "single", "int64", "int32", "int16"], ...
        ["double", "single", "int64", "int32", "int16"]);
    JC.addBuildFile(func_fft);
    JC.addBuildFile(func_twoarray);
    JC.addBuildFile(func_scalars);


    SB.addClass(JC);

end