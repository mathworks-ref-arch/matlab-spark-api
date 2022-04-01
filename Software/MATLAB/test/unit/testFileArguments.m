classdef testFileArguments < matlab.unittest.TestCase
    % testFileArguments Unit tests for the File class
    
    % Copyright 2022 MathWorks, Inc.
    
    properties
        fNoTables = "f_in2_out3.m"
        fTinTout = "f_inT1_outT1.m"
        fTinOut2 = "f_inT1_out2.m"
        fTin2Tout = "f_inT2_outT1.m"
        fTin_2_Tout = "f_inT1_2_outT1.m"
        fIn1TOutT = "f_in_1_T1_outT1.m"
    end

    methods (TestClassSetup)
        function setupClass(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
            
       end
    end
    
    methods (Test)
        function testNoTables(testCase)

            [~,newFile] = fileparts(testCase.fNoTables);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fNoTables), '.');
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {1,2});

            DT = jsondecode(fileread(jsonName));
            testCase.assertClass(DT, "struct");
            testCase.assertTrue(isfield(DT, "InTypes"));
            testCase.assertTrue(isfield(DT, "OutTypes"));

            F = compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.assertClass(F, "compiler.build.spark.File");
            testCase.verifyFalse(F.TableInterface);
            testCase.verifyFalse(F.ScopedTables);

        end

        function testTinTout(testCase)

            [~,newFile] = fileparts(testCase.fTinTout);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fTinTout), '.');
            x = rand(10,1);
            y = rand(10,1);
            T = table(x,y);
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {T});

            DT = jsondecode(fileread(jsonName));
            F = compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.assertClass(F, "compiler.build.spark.File");
            testCase.assertClass(F, "compiler.build.spark.File");
            testCase.verifyTrue(F.TableInterface);
            testCase.verifyFalse(F.ScopedTables);

        end

        function testTinOut2(testCase)

            [~,newFile] = fileparts(testCase.fTinOut2);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fTinOut2), '.');
            x = rand(10,1);
            y = rand(10,1);
            T = table(x,y);
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {T});

            DT = jsondecode(fileread(jsonName));
            fF = @() compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.verifyError(fF, 'MATLAB_SPARK_API:bad_table_arguments')

        end

        function testTin2Tout(testCase)

            [~,newFile] = fileparts(testCase.fTin2Tout);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fTin2Tout), '.');
            x = rand(10,1);
            y = rand(10,1);
            T = table(x,y);
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {T, T});

            DT = jsondecode(fileread(jsonName));
            fF = @() compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.verifyError(fF, 'MATLAB_SPARK_API:bad_table_arguments')

        end

        function testTin_2_Tout(testCase)

            [~,newFile] = fileparts(testCase.fTin_2_Tout);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fTin_2_Tout), '.');
            x = rand(10,1);
            y = rand(10,1);
            T = table(x,y);
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {T,2,3});

            DT = jsondecode(fileread(jsonName));
            F = compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.assertClass(F, "compiler.build.spark.File");
            testCase.verifyTrue(F.TableInterface);
            testCase.verifyTrue(F.ScopedTables);

        end

        function testIn1TOutT(testCase)

            [~,newFile] = fileparts(testCase.fIn1TOutT);
            copyfile(getSparkApiRoot('test', 'fixtures', testCase.fIn1TOutT), '.');
            x = rand(10,1);
            y = rand(10,1);
            T = table(x,y);
            jsonName = compiler.build.spark.types.generateFunctionSignature(newFile, {3, T});

            DT = jsondecode(fileread(jsonName));
            fF = @() compiler.build.spark.File(newFile, DT.InTypes, DT.OutTypes);
            testCase.verifyError(fF, 'MATLAB_SPARK_API:bad_table_arguments')

        end

    end
end

