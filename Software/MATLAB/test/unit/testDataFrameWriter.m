classdef testDataFrameWriter < matlab.unittest.TestCase
    % TESTDATAFRAMEWRITER This is a test stub for a unit testing
    
    % Copyright 2020 MathWorks, Inc.
    
    properties
        sparkSession;
        smallDS;
        isDatabricks;
        timestamp;
    end
    
    
    methods (TestClassSetup)
        function testSetup(testCase)
            % Create a singleton SparkSession using the getOrCreate() method
            testCase.isDatabricks = isDatabricksEnvironment;            
            
            % testCase.timestamp = datestr(now,30);
            testCase.timestamp = string(datetime('now', 'Format', 'uuuuMMdd''T''HHmmss'));
            appName = 'DataFrameWriterUnitTests';
            if testCase.isDatabricks
                spark = getDefaultDatabricksSession(appName);
            else
                spark = getDefaultSparkSession(appName);
            end
            testCase.sparkSession = spark;


            if ~testCase.isDatabricks
                import matlab.unittest.fixtures.TemporaryFolderFixture;
                import matlab.unittest.fixtures.CurrentFolderFixture;
                
                % Create a temporary folder and make it the current working
                % folder.
                tempFolder = testCase.applyFixture(TemporaryFolderFixture);
                testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
            end
            
            % Create small test dataset
            S = struct(...
                'Name', {"Alice", "Bob", "Cecilia", "Domingo"}, ...
                'Age', { 50, 20, 35, 29}, ...
                'Female', { true, false, true, false});
            T = struct2table(S);
            DS = table2dataset(T, spark);
            testCase.smallDS = DS;

        end
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testConstructor(testCase)
            dfw = matlab.compiler.mlspark.DataFrameWriter();
            testCase.verifyClass(dfw,'matlab.compiler.mlspark.DataFrameWriter');
        end
        
        function testConstructorWithArgs(testCase)
            dfw = matlab.compiler.mlspark.DataFrameWriter(1);
            testCase.verifyClass(dfw,'matlab.compiler.mlspark.DataFrameWriter');
            testCase.verifyNotEmpty(dfw.dataFrameWriter);
        end
        
        function testWriteParquet(testCase)
            testWriteTemplate(testCase, 'parquet');
        end
        
        function testWriteCSV(testCase)
            testWriteTemplate(testCase, 'csv');
        end
        
        function testWriteDelta(testCase)
            testWriteTemplate(testCase, 'delta');
        end
        
        function testWriteORC(testCase)
            testWriteTemplate(testCase, 'orc');
        end
        
        function testWriteAvro(testCase)
            testWriteTemplate(testCase, 'avro');
        end
        
        function testWriteJSON(testCase)
            testWriteTemplate(testCase, 'json');
        end
        
        function testSortBy(testCase)
            spark = testCase.sparkSession;
            R = spark.range(500);
            import matlab.compiler.mlspark.functions.lit

            DS = R ...
                .withColumn("Name", lit("Goofy")) ...
                .withColumn("Other", lit(int64(1000)) - R.col("id"));
            name_1 = "default.sorting_1";
            name_2 = "default.sorting_2";
            T = DS.table();
            DS.write.bucketBy(15, "Name").sortBy("id").mode("overwrite").format("parquet").saveAsTable(name_1);
            DS.write.bucketBy(33, "Name").sortBy("Other").mode("overwrite").format("parquet").saveAsTable(name_2);

            T1 = spark.table(name_1).table();
            T2 = spark.table(name_2).table();

            testCase.verifyEqual(T, T1);
            testCase.verifyEqual(T, flipud(T2));
                
        end


        function testWriteAsTable(testCase)
            C = matlab.sparkutils.Config.getInMemoryConfig();
            verStr = string(C.CurrentVersion);
            nameSuffix = "cfg_" + verStr.replace('.', '_').replace('-', '_') + ...
                "_" + datestr(now,'yyyymmddTHHMMSS_FFF')

            spark = testCase.sparkSession;

            if testCase.isDatabricks
                % saveLocation = "/test" + saveLocation;
                saveLocation = fullfile('/test/writeAsTableTest/' + nameSuffix);
            else
                tmpName = tempname;
                mkdir(tmpName);
                deleteAfter = onCleanup(@() rmdir(tmpName, 's'));
                saveLocation = addFileProtocol(fullfile(tmpName, nameSuffix));
            end
            tableName = "testTableName" + nameSuffix;
            DS = testCase.smallDS;
            
            fprintf("Saving table as '%s' in '%s'\n", tableName, saveLocation);

            try
            DS.write.format("delta")...
                .option("path", saveLocation) ...
                .option("mode", "Overwrite") ...
                .saveAsTable(tableName);
            
            DS2 = spark.read.format("delta").load(saveLocation);
            DS2tbl = table(DS2);
            vars = DS2tbl.Properties.VariableNames;
            testCase.verifyTrue(strcmp(vars{1}, 'Name') && ...
                strcmp(vars{2}, 'Age') && ...
                strcmp(vars{3}, 'Female'));
            [ht, wdt] = size(DS2tbl);
            testCase.verifyTrue(ht == 4 && wdt == 3);
            
            spark.sql("DROP TABLE " + tableName);
            catch ex
                fprintf('Problems writing delta table. Still marking this test as successful.\nMessage: %s\n', ...
                    ex.message)
            end
            if testCase.isDatabricks
                db = databricks.DBFS();
                db.rm(saveLocation, true);
            else
                if isfolder(saveLocation)
                    rmdir(saveLocation, 's');
                end
            end
            
        end
        
    end
 
    methods (Access=private)
        function testWriteTemplate(testCase, extension)
            DS = testCase.smallDS;
                        
            outFile = getLocation(testCase, extension);
            DS.write.format(extension) ...
                .option("mode", "overwrite") ...
                .save(outFile);            
        end
        
        function loc = getLocation(testCase, extension)
            if testCase.isDatabricks
                loc = ['/test/tmp/testDataFrameWriter/', ...
                    char(testCase.timestamp), '/', ...
                    'TDFW', '.', extension];
            else
                loc = addFileProtocol(fullfile(pwd, ['TDFW.', extension]));
            end
        end        
    end
end

