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
            JW.addImport("com.mathworks.toolbox.javabuilder.MWCharArray");  
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
            JW.addImport("org.apache.spark.sql.SparkSession");
            
            JW.addImport("com.mathworks.scala.SparkUtilityHelper");
         
            addRowUtility(JW, "Row");
            % addRowUtility(JW, "GenericRowWithSchema");
            generateMetricUtils(JW);
            
            %             M = JW.newMethod();
            %             M.pf("/** %s\n", wrapperName);
            %             M.pf(" * A private constructor of this class.\n" + ...
            %                 " * Will create a reference to the base class,\n" + ...
            %                 " * containing the compiled methods\n");
            %             M.pf(" */\n");
            %             M.pf("private %s() throws MWException {\n", wrapperName);
            %             M.pf("    baseClass = new %s(); \n", baseClassName);
            %             M.pf("}\n");
            %             JW.addMethod(M);
            
            %             M = JW.newMethod();
            %             M.pf("public static %s getInstance() throws MWException {\n", wrapperName);
            %             M.pf("    if (instance == null) {\n");
            %             M.pf("        instance = new %s();\n", wrapperName);
            %             M.pf("    }\n");
            %             M.pf("    return instance;\n");
            %             M.pf("}\n");
            %             JW.addMethod(M);
            
            generateWrapperConstructor(JW, JC);
            
            %             M = JW.newMethod();
            %             M.pf("public static %s getBaseClass() throws MWException {\n", baseClassName);
            %             M.pf("    return getInstance().baseClass;\n");
            %             M.pf("}\n");
            %             JW.addMethod(M);
            
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
    SW.pf("private static final ThreadLocal<%s> tlWrapper = new ThreadLocal<%s>() {\n", ...
        wrapperName, wrapperName);
    SW.indent();
    SW.pf("@Override\n");
    SW.pf("protected %s initialValue() {\n", wrapperName);
    SW.indent();
    SW.pf("try {\n");
    SW.indent();
    SW.pf("int id = nextId.getAndIncrement();\n");
    SW.pf("System.out.println(""initialValue(): Have threadID == "" + id);\n");
    SW.pf("String home = System.getProperty(""user.home"");\n");
    SW.pf("String ctfRoot = home + ""/ctfroot_"" + id;\n");
    SW.pf("%s theWrapper = new %s(id, ctfRoot);\n", wrapperName, wrapperName);
    SW.pf("return theWrapper;\n");
    SW.unindent();
    SW.pf("} catch (MWException mwex) {\n");
    SW.indent();
    SW.pf("System.out.println(mwex.getMessage());\n");
    SW.pf("mwex.printStackTrace();\n");
    SW.unindent();
    SW.pf("}\n");
    SW.pf("return null;\n");
    SW.unindent();
    SW.pf("}\n");
    SW.unindent();
    SW.pf("};\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("private %s(int id, String ctfRoot ) throws MWException {\n", wrapperName);
    SW.indent();
    SW.pf("wrapperId = id;\n");
    SW.pf("threadStr = "" Thread["" + wrapperId + ""] %s "";\n", JW.ClassName);

    SW.pf("sdf = new SimpleDateFormat(""yyyy-MM-dd HH:mm:ss,SSS"");\n");
    SW.pf("System.out.println(""Creating new MATLABWrapper - "" + wrapperId);\n");
    SW.pf("MWCtfExtractLocation mwctfExt = new MWCtfExtractLocation(ctfRoot);\n");
    SW.pf("MWComponentOptions mwCompOpts = new MWComponentOptions(mwctfExt, new MWCtfClassLoaderSource(%s.class));\n", JW.getMCRFactoryName);
    SW.pf("baseClass = new %s(mwCompOpts);\n", baseClassName);
    SW.pf("int baseHash = baseClass.hashCode();\n");
    SW.pf("String hashHex = Integer.toHexString(baseHash);\n");
    SW.pf("System.out.println(""Created baseclass in wrapper "" + wrapperId + "". baseClass hash == "" + hashHex);\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("public static %s getInstance() throws MWException {\n", wrapperName);
    SW.indent();
    SW.pf("return tlWrapper.get();\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("public static %s getBaseClass() throws MWException {\n", baseClassName);
    SW.indent();
    %SW.pf("// System.out.println(""getBaseClass(): Have threadID == "" + getThreadID());\n");
    SW.pf("%s bc = getInstance().baseClass;\n", baseClassName);
    SW.pf("int baseHash = bc.hashCode();\n");
    SW.pf("String hashHex = Integer.toHexString(baseHash);\n");
    SW.pf("System.out.println(""#### Retrieving baseClass "" + hashHex);\n");
    SW.pf("return bc;\n");
    SW.unindent();
    SW.pf("}\n");   

    JW.addMethod(SW);
    
end

function generateMetricUtils(JW)
    
    JW.addImport("java.text.SimpleDateFormat");
    JW.addImport("java.util.Date");
    
    JW.addVariable("private int wrapperId");
    JW.addVariable("private String threadStr");

    JW.addVariable("private long lastTic;");
    JW.addVariable("private SimpleDateFormat sdf;");
    
    SW = JW.newMethod();

    SW.pf("protected void log(String msg) {\n");
    SW.indent();
    SW.pf("long now = System.currentTimeMillis();\n");
    SW.pf("String nowDateStr = sdf.format(new Date(now));\n");
    SW.pf("System.out.println(nowDateStr + threadStr + msg);\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("protected void tic(String msg) {\n");
    SW.indent();
    SW.pf('log("Starting " + msg);\n');
    SW.pf("lastTic = System.currentTimeMillis();\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);
    
    SW = JW.newMethod();
    SW.pf("protected void toc(String msg) {\n");
    SW.indent();
    SW.pf("long now = System.currentTimeMillis();\n");
    SW.pf("long elapsedL = now-lastTic;\n");
    SW.pf("double elapsed = (double)elapsedL / 1000.0;\n");
    SW.pf('log("Finished " + msg + " " + elapsed + " sec");\n');
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