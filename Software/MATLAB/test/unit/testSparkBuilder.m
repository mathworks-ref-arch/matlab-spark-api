classdef testSparkBuilder < matlab.unittest.TestCase
    % testSparkBuilder Unit tests for the SparkBuilder class
    
    % Copyright 2021 MathWorks, Inc.
    
    properties
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
        end
        
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        
        function testSimpleBuild(testCase)
            SB = compiler.build.spark.SparkBuilder('mySimple', 'my.pkg');
            
            JC = compiler.build.spark.JavaClass('Time');
            bf1 = compiler.build.spark.File('datenum', ...
                {"double", "double", "double", "double", "double", "double"}, ... % Inputs
                {"double"}); %#ok<STRSCALR,CLARRSTR> % Outputs
            JC.addBuildFile(bf1);
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'my', 'pkg', 'Time.java');
            TFW = fullfile(SB.outputFolder, 'my', 'pkg', 'TimeWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
        end
        
        function testVararginBuild(testCase)
            SB = compiler.build.spark.SparkBuilder('myVarargin', 'my.pkg');
            
            JC = compiler.build.spark.JavaClass('Time');
            bf1 = compiler.build.spark.File('datenum', ...
                {"double", "double", "double", "double", "double", "double"}, ... % Inputs
                {"double"}); %#ok<STRSCALR,CLARRSTR> % Outputs
            bf2 = compiler.build.spark.File('datestr', ...
                {"double"}, ... % Inputs
                {"string"}); %#ok<STRSCALR,CLARRSTR> % Outputs
            JC.addBuildFile(bf1);
            JC.addBuildFile(bf2);
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'my', 'pkg', 'Time.java');
            TFW = fullfile(SB.outputFolder, 'my', 'pkg', 'TimeWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
        end
        
        function testNonScalars(testCase)
            SB = compiler.build.spark.SparkBuilder('outFolder', 'com.mw.signals');
            
            JC = compiler.build.spark.JavaClass('SigProc');
            
            func_fft = compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'myfft.m'), {{"double", [1, inf]}}, {{"double", [1, inf]}});
            func_twoarray = compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'twoArrays.m'), {{"double", [1, inf]}, {"int32", [1, inf]}}, {{"double", [1, inf]}, {"int32", [1, inf]}});
            func_scalars =  compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'myscalars.m'), ...
                ["double", "single", "int64", "int32", "int16"], ...
                ["double", "single", "int64", "int32", "int16"]);
            JC.addBuildFile(func_fft);
            JC.addBuildFile(func_twoarray);
            JC.addBuildFile(func_scalars);
            
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'SigProc.java');
            TFW = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'SigProcWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
            
        end
        
        function testAbsPath(testCase)
            here = pwd;
            buildFolder = fullfile(here, 'a', 'b', 'c');
            SB = compiler.build.spark.SparkBuilder(buildFolder, 'com.mw.signals');
            
            JC = compiler.build.spark.JavaClass('SigProc');
            
            func_fft = compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'myfft.m'), {{"double", [1, inf]}}, {{"double", [1, inf]}});
            func_twoarray = compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'twoArrays.m'), {{"double", [1, inf]}, {"int32", [1, inf]}}, {{"double", [1, inf]}, {"int32", [1, inf]}});
            func_scalars =  compiler.build.spark.File(getSparkApiRoot('public', 'examples', 'nonscalar', 'myscalars.m'), ...
                ["double", "single", "int64", "int32", "int16"], ...
                ["double", "single", "int64", "int32", "int16"]);
            JC.addBuildFile(func_fft);
            JC.addBuildFile(func_twoarray);
            JC.addBuildFile(func_scalars);
            
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'SigProc.java');
            TFW = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'SigProcWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
            
        end
        
        
        function testTypes1(testCase)
            SB = compiler.build.spark.SparkBuilder('./outFolder', 'com.mw.signals');
            
            JC = compiler.build.spark.JavaClass('TypeTest');
            
            func_1 = compiler.build.spark.File(getSparkApiRoot('test', 'fixtures', 'diffArgsFunc.m'), ...
                ["double", "single", "int64", "int32", "int16"], ...
                ["double", "single", "int64", "int32", "int16"] ...
                );
            
            JC.addBuildFile(func_1);
            
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTest.java');
            TFW = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTestWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
            
        end
        
        function testTypes2(testCase)
            SB = compiler.build.spark.SparkBuilder('./outFolder', 'com.mw.signals');
            
            JC = compiler.build.spark.JavaClass('TypeTest');
            
            func_1 = compiler.build.spark.File(getSparkApiRoot('test', 'fixtures', 'diffArgsFunc.m'), ...
                {"string", "logical", {"int64", [1, inf]}, {"int32", [1, inf]}, {"int16", [1, inf]}}, ...
                {"string", "logical", {"int64", [1, inf]}, {"int32", [1, inf]}, {"int16", [1, inf]}} ...
                );
            
            JC.addBuildFile(func_1);
            
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTest.java');
            TFW = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTestWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
            
        end

        function testTypes3(testCase)
            if ~compiler.build.spark.internal.hasMWStringArray
                % String array only supported starting in MATLAB R2020b for
                % Java interface
                return;
            end
            SB = compiler.build.spark.SparkBuilder('./outFolder', 'com.mw.signals');
            
            JC = compiler.build.spark.JavaClass('TypeTest');
            
            func_1 = compiler.build.spark.File(getSparkApiRoot('test', 'fixtures', 'diffArgsFunc.m'), ...
                {{"string", [1, inf]}, {"logical", [1, inf]}, {"int64", [1, inf]}, {"int32", [1, inf]}, {"int16", [1, inf]}}, ...
                {{"string", [1, inf]}, {"logical", [1, inf]}, {"int64", [1, inf]}, {"int32", [1, inf]}, {"int16", [1, inf]}} ...
                );
            
            JC.addBuildFile(func_1);
            
            SB.addClass(JC);
            
            SB.build();
            
            testCase.verifyTrue(isfolder(SB.outputFolder));
            TF = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTest.java');
            TFW = fullfile(SB.outputFolder, 'com', 'mw', 'signals', 'TypeTestWrapper.java');
            testCase.verifyTrue(isfile(TF));
            testCase.verifyTrue(isfile(TFW));
            
            jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            testCase.verifyLength(jarFiles, 1);
            
        end
        
        function testJavaClassConstructors1(testCase)
            J = compiler.build.spark.JavaClass("ClassName", {"datenum", "addFileProtocol"}); %#ok<CLARRSTR>
            testCase.verifyEqual(J.name, "ClassName");
            testCase.verifyLength(J.files, 2);
        end
        
        function testJavaClassConstructors2(testCase)
            J = compiler.build.spark.JavaClass("ClassName", ["datenum", "addFileProtocol"]);
            testCase.verifyEqual(J.name, "ClassName");
            testCase.verifyLength(J.files, 2);
            
            J = compiler.build.spark.JavaClass("ClassName", "datenum");
            testCase.verifyEqual(J.name, "ClassName");
            testCase.verifyLength(J.files, 1);
        end
        
        function testJavaClassConstructors3(testCase)
            J = compiler.build.spark.JavaClass("ClassName", {{"addFileProtocol", "string", "string"}}); %#ok<CLARRSTR>
            testCase.verifyLength(J.files, 1);
            testCase.verifyEqual(J.files.InTypes.MATLABType, "string");
            testCase.verifyEqual(J.files.OutTypes.MATLABType, "string");
        end
        
        function testJavaClassConstructors4(testCase)
            J = compiler.build.spark.JavaClass("ClassName", {{"addFileProtocol", "string", "string"}, "datenum"}); %#ok<CLARRSTR>
            testCase.verifyLength(J.files, 2);
            testCase.verifyEqual(J.files(1).InTypes.MATLABType, "string");
            testCase.verifyEqual(J.files(1).OutTypes.MATLABType, "string");
            testCase.verifyEqual(J.files(2).InTypes(1).MATLABType, "double");
            testCase.verifyEqual(J.files(2).OutTypes.MATLABType, "double");
        end
        
        function testFileConstructor1(testCase)
            F = compiler.build.spark.File("datenum");
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 6);
            testCase.verifyEqual(F.nArgOut, 1);
        end
        
        function testFileConstructor2(testCase)
            testCase.verifyError(@() compiler.build.spark.File("datenumDOESNOTEXIST"), ...
                'MATLAB:narginout:notValidMfile');
        end
        
        function testFileConstructor3(testCase)
            % Test the different forms of inarg/outarg variants
            F = compiler.build.spark.File("addFileProtocol", {"string"}, {"string"}); %#ok<STRSCALR>
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 1);
            testCase.verifyEqual(F.nArgOut, 1);
            
            F = compiler.build.spark.File("addFileProtocol", ["string"], ["string"]);
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 1);
            testCase.verifyEqual(F.nArgOut, 1);
            
            F = compiler.build.spark.File("addFileProtocol", "string", "string");
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 1);
            testCase.verifyEqual(F.nArgOut, 1);
        end
        
        function testFileConstructor4(testCase)
            % Test the different forms of inarg/outarg variants
            F = compiler.build.spark.File("addFileProtocol", {{"string", [1,1]}}, {{"string", [1,1]}});
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 1);
            testCase.verifyEqual(F.nArgOut, 1);
            testCase.verifyEqual(F.InTypes.MATLABType, "string");
            testCase.verifyEqual(F.OutTypes.MATLABType, "string");
            testCase.verifyEqual(F.InTypes.Size, [1, 1]);
            testCase.verifyEqual(F.OutTypes.Size, [1, 1]);
        end
        
        function testFileConstructor5(testCase)
            % Test the different forms of inarg/outarg variants
            F = compiler.build.spark.File("addFileProtocol", {{"string", [1,1]}}, "string");
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 1);
            testCase.verifyEqual(F.nArgOut, 1);
            testCase.verifyEqual(F.InTypes.MATLABType, "string");
            testCase.verifyEqual(F.OutTypes.MATLABType, "string");
            testCase.verifyEqual(F.InTypes.Size, [1, 1]);
            testCase.verifyEqual(F.OutTypes.Size, [1, 1]);
        end
        
        function testFileConstructon6(testCase)
            % Test the different forms of inarg/outarg variants
            F = compiler.build.spark.File("findFileRecursively", {{"string", [1,1]}, "string"}, "string");
            testCase.verifyClass(F, 'compiler.build.spark.File');
            testCase.verifyEqual(F.nArgIn, 2);
            testCase.verifyEqual(F.nArgOut, 1);
            testCase.verifyEqual(F.InTypes(1).MATLABType, "string");
            testCase.verifyEqual(F.InTypes(2).MATLABType, "string");
            testCase.verifyEqual(F.OutTypes.MATLABType, "string");
            testCase.verifyEqual(F.InTypes(1).Size, [1, 1]);
            testCase.verifyEqual(F.InTypes(2).Size, [1, 1]);
            testCase.verifyEqual(F.OutTypes.Size, [1, 1]);
        end
        
        function testFileConstructon7(testCase)
            F1 = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, "double"}, {"int64"}); %#ok<STRSCALR>
            F2 = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, {"double", [1,1]}}, {{"int64", [1,1]}});
            F3 = compiler.build.spark.File("somefun.m", {{"int64", [1,10]}, {"double", [1,1]}}, "int64");
            
            compareTwoFiles(testCase, F1, F2);
            compareTwoFiles(testCase, F1, F3);
            compareTwoFiles(testCase, F2, F3);
            
        end
    end
end

function compareTwoFiles(testCase, F, G)
    testCase.assertEqual(F.nArgIn, G.nArgIn);
    testCase.assertEqual(F.nArgOut, G.nArgOut);
    for k=1:F.nArgIn
        testCase.verifyEqual(F.InTypes(k).MATLABType, G.InTypes(k).MATLABType);
        testCase.verifyEqual(F.InTypes(k).Size, G.InTypes(k).Size);
    end
    for k=1:F.nArgOut
        testCase.verifyEqual(F.OutTypes(k).MATLABType, G.OutTypes(k).MATLABType);
        testCase.verifyEqual(F.OutTypes(k).Size, G.OutTypes(k).Size);
    end
end
