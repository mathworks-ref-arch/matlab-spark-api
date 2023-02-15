classdef testPythonSparkBuilder < matlab.unittest.TestCase
    % testPythonSparkBuilder Unit tests for the PythonSparkBuilder class
    
    % Copyright 2022 MathWorks, Inc.
    
    properties
        Funcs (:, 2) cell
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));

            x = rand(10,1);
            y = rand(10,1);
            T1 = table(x,y);
            testCase.Funcs{1,1} = "f_in2_out3.m";
            testCase.Funcs{1,2} = {2, 3};
            testCase.Funcs{2,1} = "f_inT1_outT1.m";
            testCase.Funcs{2,2} = {T1};
            testCase.Funcs{3,1} = "f_inT1_2_outT1.m";
            testCase.Funcs{3,2} = {T1, 2, 3};
            
            
            for k=1:size(testCase.Funcs, 1)
                fileName = testCase.Funcs{k,1};
                [~,funcName] = fileparts(fileName);
                args = testCase.Funcs{k,2};
                copyfile(getSparkApiRoot('test', 'fixtures', fileName), '.');
                compiler.build.spark.types.generateFunctionSignature(funcName, args);
            end
        end
        
    end
    
    methods (TestMethodSetup)
        function testMethodSetup(testCase)
        end
    end

    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        
        function testSimpleBuild(testCase)

            opts = compiler.build.PythonPackageOptions(...
                testCase.Funcs(:,1), ...
                "OutputDir", "build_1", ...
                "PackageName", "unit.test1" ...
                );

            PSB = compiler.build.spark.PythonSparkBuilder(opts);

            PSB.build();
            
            testCase.verifyTrue(isfolder(PSB.OutputDir));
            % TF = fullfile(SB.outputFolder, 'my', 'pkg', 'Time.java');
            % TFW = fullfile(SB.outputFolder, 'my', 'pkg', 'TimeWrapper.java');
            % testCase.verifyTrue(isfile(TF));
            % testCase.verifyTrue(isfile(TFW));
            %
            % jarFiles = dir(fullfile(SB.outputFolder, '*.jar'));
            % testCase.verifyLength(jarFiles, 1);
        end
        
    end
end

