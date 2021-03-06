function generateSparkShellHelper(obj)
    % generateSparkShellHelper Generate a shell script for interactive test
    
    % Copyright 2021 The MathWorks, Inc.
    
    old = cd(obj.outputFolder);
    goBack = onCleanup(@() cd(old));
    
    jarFile = dir(fullfile('.', '*.jar'));
    
    fileName = genFile(obj, jarFile);
    if isunix
        [r, s] = system(sprintf("chmod +x %s", fileName));
    end
end

function fileName = genFile(obj, jarFile)
    fileName = fullfile('.', 'runSparkShell.sh');
    SW = matlab.sparkutils.StringWriter(fileName);
    
    
    SW.pf("#!//bin/bash\n\n");
    
    SW.pf("set -xeuo pipefail\n\n");
    
    SW.pf("echo ""This script requires that the variable SPARK_HOME is set and pointing to a valid Spark installation""\n");
    SW.pf("echo ""Starting Spark shell from $SPARK_HOME""\n\n");
    
    SW.pf("SCRIPT_DIR=""$( cd ""$( dirname ""${BASH_SOURCE[0]}"" )"" >/dev/null 2>&1 && pwd )""\n");
    SW.pf("JB=""%s""\n", ...
        fullfile(matlabroot, "toolbox", "javabuilder", "jar", "javabuilder.jar"));
    SW.pf("MSU=""%s""\n", ...
        matlab.sparkutils.getMatlabSparkUtilityFullName('fullpath', true, 'shaded', false));
    SW.pf("APP=""${SCRIPT_DIR}/%s""\n", jarFile.name);
    SW.pf("JARS=""$JB,$APP,$MSU""\n\n");
    
    SW.pf("# Get some starting code into the clipboard\n");
    SW.pf("cat > somefile <<- END_OF_CODE\n");
    % SW.pf("import org.apache.spark.sql.Encoders\n");
    % SW.pf("import org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema\n");
    SW.pf("import com.mathworks.toolbox.javabuilder._\n");
    for k=1:length(obj.javaClasses)
        JC = obj.javaClasses(k);
        SW.pf("import %s.%s\n", obj.package, JC.WrapperName);
    end
    for k=1:length(obj.javaClasses)
        JC = obj.javaClasses(k);
        SW.pf("%s.initEncoders(spark)\n", JC.WrapperName);
    end
    SW.pf("val DS = spark.range(1, 5000)\n");
    SW.pf("val DD1 = DS.toDF.withColumnRenamed(""id"", ""col_long"")\n")
    SW.pf("val DD2 = DD1.withColumn(""col_string1"", lit(""abcxzy"")).withColumn(""col_string2"", DD1.col(""col_long"").cast(""string""))\n")
    SW.pf("val DD3 = DD2.withColumn(""col_int"", DD2.col(""col_long"").cast(""int""))\n")
    SW.pf("val DD4 = DD3.withColumn(""col_short"", DD3.col(""col_int"").cast(""short""))\n");
    SW.pf("val DD5 = DD4.withColumn(""col_bool1"", DD4.col(""col_long"") %% 2 === 0)\n");
    SW.pf("val DD6 = DD5.withColumn(""col_bool2"", DD5.col(""col_long"") %% 3 === 0)\n");
    SW.pf("val DD7 = DD6.withColumn(""col_double"", DD6.col(""col_long"").cast(""double""))\n");

    SW.pf("DD7.printSchema\n")
    SW.pf("DD7.show(10, false)\n")
    
    %     SW.pf('val bdoy = spark.read.format("parquet").load("./bdoy.parquet")\n');
    %     SW.pf('val rows = bdoy.collectAsList\n');
    %     SW.pf('val rowIt = rows.iterator\n');
    %     SW.pf('val mwcell = TablesWrapper.rowIteratorToMWCell_normalizeStuff(rowIt)\n');
    %     SW.pf("val instance = TablesWrapper.getBaseClass\n");
    %     SW.pf("val OR = instance.normalizeStuff_partition(1, mwcell)\n");

    SW.pf("END_OF_CODE\n\n");
    SW.pf("xclip -i somefile\n");
    SW.pf("rm somefile\n\n");
    SW.pf("# Prepend with SPARK_SUBMIT_OPTS for debugging\n");
    SW.pf("# SPARK_SUBMIT_OPTS=""-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005""\n");
    SW.pf("$SPARK_HOME/bin/spark-shell --jars $JARS\n\n");
    SW.pf("# End of file\n\n");
        
end