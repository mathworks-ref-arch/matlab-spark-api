///**
// * This is a class with helper function for marshalling DataFrame data
// * into MATLAB.
// *
// * Copyright 2020 MathWorks, Inc.
// */
//package com.mathworks;
//
//// Imports
//import java.util.List;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Date;
//import java.util.TimeZone;
//import java.util.Calendar;
//
//import org.apache.spark.sql.Dataset;
//import org.apache.spark.sql.Row;
//import org.apache.spark.sql.types.StructField;
//
//import scala.collection.JavaConversions;
//import scala.collection.mutable.ArrayBuffer;
//import scala.collection.mutable.WrappedArray;
//import com.mathworks.scala.SparkUtilityHelper;
//import com.mathworks.scala.MatlabData;
//import com.mathworks.scala.MatlabDataTable;
//
//
//class SparkUtility {
//    // Datetime support
//    public static UtcDateComponents getDateComponents(Date[] dates) {
//        UtcDateComponents dateComponents = new UtcDateComponents();
//        int numDates = dates.length;
//        dateComponents.Year = new int[numDates];
//        dateComponents.Month = new int[numDates];
//        dateComponents.Day = new int[numDates];
//        dateComponents.Hours = new int[numDates];
//        dateComponents.Minutes = new int[numDates];
//        dateComponents.Seconds = new int[numDates];
//        dateComponents.Milliseconds = new int[numDates];
//        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
//        for (int dateIndex = 0; dateIndex < numDates; dateIndex++) {
//            calendar.setTime(dates[dateIndex]);
//            dateComponents.Year[dateIndex] = calendar.get(Calendar.YEAR);
//            dateComponents.Month[dateIndex] = calendar.get(Calendar.MONTH) + 1;
//            dateComponents.Day[dateIndex] = calendar.get(Calendar.DAY_OF_MONTH);
//            dateComponents.Hours[dateIndex] = calendar.get(Calendar.HOUR_OF_DAY);
//            dateComponents.Minutes[dateIndex] = calendar.get(Calendar.MINUTE);
//            dateComponents.Seconds[dateIndex] = calendar.get(Calendar.SECOND);
//            dateComponents.Milliseconds[dateIndex] = calendar.get(Calendar.MILLISECOND);
//        }
//        return dateComponents;
//    }
//
//    // Ability to get the MATLAB dataframe
//    public static MatlabDataframe getMatlabDataframe(Dataset<Row> dataSet) {
//        // Get the schema
//        StructField[] fields = dataSet.schema().fields();
//        // Now, get the data
//        List<Row> rows = dataSet.collectAsList();
//        // Cast
//        return getMatlabDataframe(rows, fields);
//    }
//
//    // Marshaling code
//    // public static MatlabData getMatlabData(List<Row> rows, StructField[] fields) {
//    //     // Find out how many rows there are
//    //     int numRows = (int) rows.size();
//    //     // Create the columns
//    //     int numFields = fields.length;
//    //     String[] variableTypes = new String[numFields];
//    //     String[] variableNames = new String[numFields];
//    //     List<List> columns = new ArrayList<List>();
//    //     for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//    //         String typeName = fields[columnIndex].dataType().typeName();
//    //         variableTypes[columnIndex] = typeName;
//    //         variableNames[columnIndex] = fields[columnIndex].name();
//    //         if (typeName.equals("string")) {
//    //             columns.add(new ArrayList<String>());
//    //         } else if (typeName.equals("timestamp")) {
//    //             columns.add(new ArrayList<java.sql.Timestamp>());
//    //         } else if (typeName.equals("date")) {
//    //             columns.add(new ArrayList<java.sql.Date>());
//    //         } else if (typeName.equals("float")) {
//    //             columns.add(new ArrayList<Float>());
//    //         } else if (typeName.equals("integer")) {
//    //             columns.add(new ArrayList<Integer>());
//    //         } else if (typeName.equals("boolean")) {
//    //             columns.add(new ArrayList<Boolean>());
//    //         } else if (typeName.equals("double")) {
//    //             columns.add(new ArrayList<Double>());
//    //         } else if (typeName.equals("long")) {
//    //             columns.add(new ArrayList<Long>());
//    //         } else if (typeName.equals("binary")) {
//    //             columns.add(new ArrayList<java.lang.Byte[]>());
//    //         } else if (typeName.equals("array")) {
//    //             columns.add(new ArrayList<WrappedArray[]>());
//    //         } else if (typeName.equals("struct")) {
//    //             columns.add(new ArrayList<Object>());
//    //         } else {
//    //             throw new RuntimeException("Type " + typeName + " is not yet implemented.\n" + "Found for field '"
//    //                     + fields[columnIndex].name() + "'");
//    //         }
//    //     }
//    //     // Now, get the data, and populate the lists
//    //     for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
//    //         // Process each rows
//    //         Object candidate = rows.get(rowIndex);
//
//    //         // Check for optimized return values
//    //         // When the input has only an id - the return type is a Long instead of
//    //         // GenericRowWithSchema
//    //         // The next section of code will cast it into a Row for further marshaling.
//    //         Row rowCandidate;
//    //         if (candidate.getClass() == Long.class) {
//    //             // The input is Long (possibly ID)
//    //             rowCandidate = org.apache.spark.sql.RowFactory.create(candidate);
//
//    //         } else {
//    //             // Cast as a GenericRowWithSchema
//    //             rowCandidate = (Row) candidate;
//    //         }
//
//    //         for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//    //             // Process each cell
//    //             columns.get(columnIndex).add(rowCandidate.getAs(columnIndex));
//    //         }
//    //     }
//    //     // Finally, cast the lists to arrays
//    //     ArrayList columnArrays = new ArrayList();
//    //     for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//    //         String typeName = fields[columnIndex].dataType().typeName();
//    //         if (typeName.equals("string")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new String[numRows]));
//    //         } else if (typeName.equals("timestamp")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new java.sql.Timestamp[numRows]));
//    //         } else if (typeName.equals("date")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new java.sql.Date[numRows]));
//    //         } else if (typeName.equals("float")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Float[numRows]));
//    //         } else if (typeName.equals("integer")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Integer[numRows]));
//    //         } else if (typeName.equals("boolean")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Boolean[numRows]));
//    //         } else if (typeName.equals("double")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Double[numRows]));
//    //         } else if (typeName.equals("long")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Long[numRows]));
//    //         } else if (typeName.equals("binary")) {
//    //             List byteList = columns.get(columnIndex);
//    //             columnArrays.add(byteList);
//    //         } else if (typeName.equals("array")) {
//    //             List c = columns.get(columnIndex);
//    //             List retList = new ArrayList<>();
//    //             for (int arrayIdx = 0; arrayIdx < c.size(); arrayIdx++) {
//    //                 WrappedArray wa0 = (WrappedArray) c.get(arrayIdx);
//    //                 String baseClass = wa0.apply(0).getClass().getName();
//    //                 retList.add(SparkUtilityHelper.WrappedArrayToList(wa0));
//    //             }
//    //             columnArrays.add(retList);
//    //         } else if (typeName.equals("struct")) {
//    //             columnArrays.add(columns.get(columnIndex).toArray(new Object[numRows]));
//    //         } else {
//    //             throw new RuntimeException("Type " + typeName + " is not yet implemented");
//    //         }
//    //     }
//        
//    //     return new MatlabDataTable(variableNames, variableTypes, columnArrays, numRows);
//        
//    // }
//    
//    // Marshaling code
//    public static MatlabDataframe getMatlabDataframe(List<Row> rows, StructField[] fields) {
//        // Find out how many rows there are
//        int numRows = (int) rows.size();
//        // Create the columns
//        int numFields = fields.length;
//        String[] variableTypes = new String[numFields];
//        String[] variableNames = new String[numFields];
//        List<List> columns = new ArrayList<List>();
//        for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//            String typeName = fields[columnIndex].dataType().typeName();
//            variableTypes[columnIndex] = typeName;
//            variableNames[columnIndex] = fields[columnIndex].name();
//            if (typeName.equals("string")) {
//                columns.add(new ArrayList<String>());
//            } else if (typeName.equals("timestamp")) {
//                columns.add(new ArrayList<java.sql.Timestamp>());
//            } else if (typeName.equals("date")) {
//                columns.add(new ArrayList<java.sql.Date>());
//            } else if (typeName.equals("float")) {
//                columns.add(new ArrayList<Float>());
//            } else if (typeName.equals("integer")) {
//                columns.add(new ArrayList<Integer>());
//            } else if (typeName.equals("boolean")) {
//                columns.add(new ArrayList<Boolean>());
//            } else if (typeName.equals("double")) {
//                columns.add(new ArrayList<Double>());
//            } else if (typeName.equals("long")) {
//                columns.add(new ArrayList<Long>());
//            } else if (typeName.equals("binary")) {
//                columns.add(new ArrayList<java.lang.Byte[]>());
//            } else if (typeName.equals("array")) {
//                columns.add(new ArrayList<WrappedArray[]>());
//            } else if (typeName.equals("struct")) {
//                columns.add(new ArrayList<Object>());
//            } else {
//                throw new RuntimeException("Type " + typeName + " is not yet implemented.\n" + "Found for field '"
//                        + fields[columnIndex].name() + "'");
//            }
//        }
//        // Now, get the data, and populate the lists
//        for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
//            // Process each rows
//            Object candidate = rows.get(rowIndex);
//
//            // Check for optimized return values
//            // When the input has only an id - the return type is a Long instead of
//            // GenericRowWithSchema
//            // The next section of code will cast it into a Row for further marshaling.
//            Row rowCandidate;
//            if (candidate.getClass() == Long.class) {
//                // The input is Long (possibly ID)
//                rowCandidate = org.apache.spark.sql.RowFactory.create(candidate);
//
//            } else {
//                // Cast as a GenericRowWithSchema
//                rowCandidate = (Row) candidate;
//            }
//
//            for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//                // Process each cell
//                columns.get(columnIndex).add(rowCandidate.getAs(columnIndex));
//            }
//        }
//        // Finally, cast the lists to arrays
//        List columnArrays = new ArrayList();
//        for (int columnIndex = 0; columnIndex < numFields; columnIndex++) {
//            String typeName = fields[columnIndex].dataType().typeName();
//            if (typeName.equals("string")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new String[numRows]));
//            } else if (typeName.equals("timestamp")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new java.sql.Timestamp[numRows]));
//            } else if (typeName.equals("date")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new java.sql.Date[numRows]));
//            } else if (typeName.equals("float")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Float[numRows]));
//            } else if (typeName.equals("integer")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Integer[numRows]));
//            } else if (typeName.equals("boolean")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Boolean[numRows]));
//            } else if (typeName.equals("double")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Double[numRows]));
//            } else if (typeName.equals("long")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Long[numRows]));
//            } else if (typeName.equals("binary")) {
//                List byteList = columns.get(columnIndex);
//                columnArrays.add(byteList);
//            } else if (typeName.equals("array")) {
//                List c = columns.get(columnIndex);
//                List retList = new ArrayList<>();
//                for (int arrayIdx = 0; arrayIdx < c.size(); arrayIdx++) {
//                    WrappedArray wa0 = (WrappedArray) c.get(arrayIdx);
//                    String baseClass = wa0.apply(0).getClass().getName();
//                    retList.add(SparkUtilityHelper.WrappedArrayToList(wa0));
//                }
//                columnArrays.add(retList);
//            } else if (typeName.equals("struct")) {
//                columnArrays.add(columns.get(columnIndex).toArray(new Object[numRows]));
//            } else {
//                throw new RuntimeException("Type " + typeName + " is not yet implemented");
//            }
//        }
//        MatlabDataframe df = new MatlabDataframe();
//        df.VariableNames = variableNames;
//        df.VariableTypes = variableTypes;
//        df.VariableValues = columnArrays;
//        return df;
//    }
//
//    protected static <T> List<T> getWrappedArray(WrappedArray<T> data) {
//        List<T> tList = JavaConversions.seqAsJavaList(data.toList());
//        return tList;
//    }
//
//    protected static <T> List<T> getDoublyWrappedArray(WrappedArray<WrappedArray<T>> data) {
//        List<T> tList = new ArrayList<T>();        
//            // String baseClass = data.apply(0).getClass().getName();
//        // switch (baseClass) {
//        // case "scala.collection.mutable.WrappedArray$ofRef":
//        for (int i = 0; i < data.size(); i++) {
//            tList.addAll(JavaConversions.seqAsJavaList(data.apply(i)));
//        }
//        // break;
//        // default:
//        // tList.add(JavaConversions.seqAsJavaList(data));
//        // break;
//        return tList;
//    }
//
//    protected static List wrappedArrayToList(WrappedArray data) {
//
//        String baseClass = data.apply(0).getClass().getName();
//        List<Object> tList = new ArrayList<Object>();
//        switch (baseClass) {
//            case "scala.collection.mutable.WrappedArray$ofRef": {
//                // List<List> tList = new ArrayList<List>();
//                for (int i = 0; i < data.size(); i++) {
//                    WrappedArray wai = (WrappedArray) data.apply(i);
//                    List tmp = wrappedArrayToList(wai);
//                    tmp.forEach(entry -> tList.add(entry));
//                }
//
//                break;
//            }
//            default: {
//                // scala.collection.mutable.Buffer buf = data.toList().toBuffer();
//                List tmp = JavaConversions.bufferAsJavaList(data.toList().toBuffer());
//                List AList = Arrays.asList(tmp);
//                AList.forEach(entry -> tList.add(entry));
//                // List<Object> tList = new ArrayList<Object>();
//
//                // return tList;
//                break;
//            }
//        }
//        return tList;
//
//    }
//
//}
//
//// MATLAB Data frame
//class MatlabDataframe {
//
//    public String[] VariableNames;
//    public String[] VariableTypes;
//    public List VariableValues;
//
//}
//
//// Datetime support
//class UtcDateComponents {
//
//    public int[] Year;
//    public int[] Month;
//    public int[] Day;
//    public int[] Hours;
//    public int[] Minutes;
//    public int[] Seconds;
//    public int[] Milliseconds;
//
//}
