function generateWrapperFile(obj)
    % generateWrapperFile Generate the wrapper file for the class
    %
    % The generated wrapper class will contain different methods that makes
    % it easier to call compiled MATLAB functions in a Spark context.

    % Copyright 2021 The MathWorks, Inc.

    old = cd(obj.outputFolder);
    goBack = onCleanup(@() cd(old));
    obj.buildFiles = string.empty;

    numClasses = length(obj.javaClasses);
    if numClasses > 0
        for k=1:numClasses
            JC = obj.javaClasses(k);
            baseClassName = JC.name;
            wrapperName = JC.WrapperName;
            JW = matlab.sparkutils.JavaWriter(obj.package, wrapperName);
            JW.addImport("java.io.Serializable");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWException");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWNumericArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWLogicalArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWCellArray");
            % JW.addImport("com.mathworks.extern.java.MWCellArray");

            JW.addImport("com.mathworks.toolbox.javabuilder.MWCharArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWApplication");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWMCROption");

            if compiler.build.spark.internal.hasMWStringArray
                JW.addImport("com.mathworks.toolbox.javabuilder.MWStringArray");
            end
            JW.addImport("com.mathworks.toolbox.javabuilder.MWClassID");
            JW.addImport("java.util.concurrent.atomic.AtomicInteger");

            JW.addVariable("private static final AtomicInteger nextId = new AtomicInteger(0)");
            % JW.addVariable("private static %s instance = null", wrapperName);
            JW.addVariable("private %s baseClass = null", baseClassName);

            % Create row utility
            JW.addImport("java.util.List");
            JW.addImport("java.util.ArrayList");
            JW.addImport("org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema");
            JW.addImport("org.apache.spark.sql.Row");
            JW.addImport("org.apache.spark.sql.Dataset");
            JW.addImport("org.apache.spark.sql.SparkSession");

            JW.addImport("com.mathworks.sparkbuilder.RuntimeQueue");
            JW.addImport("com.mathworks.scala.SparkUtilityHelper");

            addRowUtility(JW, "Row");
            % addRowUtility(JW, "GenericRowWithSchema");
            % if obj.Debug || obj.Metrics
            generateMetricUtils(JW);
            % end

            generateWrapperConstructor(JW, JC);

            genSparkWrappers(JC, JW);

            obj.buildFiles(end+1) = JW.FileName;

            % Explicitly delete JavaWriter, to avoid race condition
            % with delete of goBack.
            clear('JW');
        end
    end


end

function generateWrapperConstructor(JW, JC)
    baseClassName = JC.name;
    wrapperName = JC.WrapperName;

    JW.addImport("com.mathworks.toolbox.javabuilder.MWComponentOptions");
    JW.addImport("com.mathworks.toolbox.javabuilder.MWCtfExtractLocation");
    JW.addImport("com.mathworks.toolbox.javabuilder.MWCtfClassLoaderSource");

    SW = JW.newMethod();
    SW.pf("public static class ClazzArgs {\n");
    SW.indent();
    SW.pf("Class<?> clazz;\n")
    SW.pf("Class<?> factoryClazz;\n")
    SW.pf("public ClazzArgs(Class<?> clazz_, Class<?> factoryClazz_) {\n");
    SW.indent();
    SW.pf("clazz = clazz_;\n");
    SW.pf("factoryClazz = factoryClazz_;\n");
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    JW.addVariable("private static ClazzArgs ARGS = null;\n")

    SW = JW.newMethod();
    SW.pf("public static ClazzArgs getClazzArgs() {\n");
    SW.indent();
    SW.pf("if (%s.ARGS == null) {\n", wrapperName)
    SW.indent();
    SW.pf("try {\n");
    SW.indent();
    SW.pf("Class<?> clazz = Class.forName(""%s"");\n", JC.getFullClassName);
    SW.pf("Class<?> factoryClazz = Class.forName(""%s"");\n", JC.getMCRFactoryName);
    SW.pf("%s.ARGS = new ClazzArgs(clazz, factoryClazz);\n", wrapperName);
    SW.unindent();
    SW.pf("} catch (ClassNotFoundException ex) {\n");
    SW.indent();
    SW.pf("ex.printStackTrace();\n")
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("}\n");
    SW.pf("return %s.ARGS;\n", wrapperName)
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("public static synchronized RuntimeQueue getRuntimeQueue(){\n");
    SW.indent();
    SW.pf("return RuntimeQueue.getSingleton(%s);\n", string(JC.parent.Debug));
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);


    SW = JW.newMethod();
    SW.pf("public static synchronized %s getInstance() throws MWException {\n", baseClassName);
    SW.indent();
    SW.pf("RuntimeQueue queue = RuntimeQueue.getSingleton(%s);\n", string(JC.parent.Debug));
    % TODO: Make these classes static instead.
    SW.pf("ClazzArgs args = %s.getClazzArgs();\n", wrapperName)
%     SW.pf("Class<?> clazz = Class.forName(""%s"");\n", JC.getFullClassName());
%     SW.pf("Class<?> factoryClazz = Class.forName(""%s"");\n", JW.getMCRFactoryName());
    SW.pf("%s inst = (%s) queue.getInstance(args.clazz, args.factoryClazz);\n", baseClassName, baseClassName);
    SW.pf("return inst;\n");
    SW.unindent();
    SW.pf("}\n");

    SW.pf("public static synchronized void releaseInstance(%s inst) {\n", baseClassName);
    SW.indent();
    SW.pf("RuntimeQueue queue = RuntimeQueue.getSingleton(true);\n");
    SW.pf("ClazzArgs args = %s.getClazzArgs();\n", wrapperName)
%     SW.pf("Class<?> clazz = Class.forName(""%s"");\n", JC.getFullClassName());
    SW.pf("getRuntimeQueue().releaseInstance(inst, args.clazz);\n");
    SW.unindent();
    SW.pf("}\n");

    JW.addMethod(SW);

    %     SW = JW.newMethod();
    %     SW.pf("public static %s getBaseClass() throws MWException {\n", baseClassName);
    %     SW.indent();
    %     %SW.pf("// System.out.println(""getBaseClass(): Have threadID == "" + getThreadID());\n");
    %     SW.pf("%s bc = getInstance().baseClass;\n", baseClassName);
    %     SW.pf("int baseHash = bc.hashCode();\n");
    %     SW.pf("String hashHex = Integer.toHexString(baseHash);\n");
    %     SW.pf("System.out.println(""#### Retrieving baseClass "" + hashHex);\n");
    %     SW.pf("return bc;\n");
    %     SW.unindent();
    %     SW.pf("}\n");
    %
    %     JW.addMethod(SW);

end

function generateMetricUtils(JW)

    JW.addImport("java.text.SimpleDateFormat");
    JW.addImport("java.util.Date");

    % JW.addVariable("private int wrapperId");
    % JW.addVariable("private String threadStr");

    % JW.addVariable("private long lastTic;");
    JW.addVariable('private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS")');

    SW = JW.newMethod();

    SW.pf("public static void log(String msg) {\n");
    SW.indent();
    SW.pf("RuntimeQueue.log(msg);\n");
    %     SW.pf("long now = System.currentTimeMillis();\n");
    %     SW.pf("String nowDateStr = sdf.format(new Date(now));\n");
    %     SW.pf("String hostInfo;\n")
    %     SW.pf("try {\n");
    %     SW.indent();
    %     SW.pf("hostInfo = java.net.InetAddress.getLocalHost().toString();\n")
    %     SW.unindent();
    %     SW.pf("} catch (java.net.UnknownHostException uhex) {\n");
    %     SW.indent();
    %     SW.pf('hostInfo = "UNKNOWN_HOST_ISSUE";\n');
    %     SW.unindent();
    %     SW.pf('}\n');
    %     SW.pf('System.out.println(nowDateStr + " " + hostInfo + " " + msg);\n');
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

    SW = JW.newMethod();
    SW.pf("public static long tic(String msg) {\n");
    SW.indent();
    SW.pf("return RuntimeQueue.tic(msg);\n");
%     SW.pf('log("Starting " + msg);\n');
%     SW.pf("long lastTic = System.currentTimeMillis();\n");
%     SW.pf("return lastTic;\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

    SW = JW.newMethod();
    SW.pf("public static void toc(String msg, long lastTic) {\n");
    SW.indent();
    SW.pf("RuntimeQueue.toc(msg, lastTic);\n");
%     SW.pf("long now = System.currentTimeMillis();\n");
%     SW.pf("long elapsedL = now-lastTic;\n");
%     SW.pf("double elapsed = (double)elapsedL / 1000.0;\n");
%     SW.pf('log("Finished " + msg + " " + elapsed + " sec");\n');
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

end

function addRowUtility(JW, typeName)
    SW = JW.newMethod();
    SW.pf("public static List<Object> rowToJavaList(%s row)  {\n", typeName);
    SW.indent();
    SW.pf("int N = row.size();\n");
    SW.pf("ArrayList<Object> list = new ArrayList<Object>(N);\n");
    SW.pf("for (int k=0; k<N; k++) {\n");
    SW.pf("list.add(row.get(k));\n");
    SW.pf("}\n");
    SW.pf("return list;\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

end
