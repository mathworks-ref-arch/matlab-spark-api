/** This is a class with helper function for marshalling DataFrame data
  * into MATLAB.
  *
  * Copyright 2020-2021 MathWorks, Inc.
  */

package com.mathworks.scala

import org.apache.spark.SparkConf
import org.apache.spark.sql.{Dataset, Row}
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema
import scala.collection.mutable.{WrappedArray, WrappedArray$ofRef}

import java.util.ArrayList
import java.util.List

import scala.annotation.switch
import org.apache.spark.sql.types.StructField
import scala.collection.Map
import scala.collection.immutable.HashMap
import scala.collection.mutable.ArrayBuffer
import org.apache.spark.sql.types.StructType
import org.apache.spark.sql.Encoder

object SparkUtilityHelper {
//// MATLAB Data frame
//  case class MatlabDataFrame(
//      VariableNames: Array[String],
//      VariableTypes: Array[String],
//      VariableValues: Array[Object]
//  )

  def sparkStructToMatlab(row: GenericRowWithSchema): MatlabData = {
    val fields = row.schema.fields
    val numFields = fields.length;
    val fieldNames = row.schema.fieldNames
    val typeNames = row.schema.fields.map(f => f.dataType.typeName)
    val values = new ArrayList[Object]
    for (idx <- 0 to (numFields - 1)) {
      val value = typeNames(idx) match {
        case "struct" =>
          sparkStructToMatlab(row.get(idx).asInstanceOf[GenericRowWithSchema])
        case _ => row.get(idx).asInstanceOf[Object]
      }
      values.add(value.asInstanceOf[Object])
    }
    new MatlabDataStruct(fieldNames, typeNames, values.toArray())
  }

  def columnToArray[T](
      rows: List[Row],
      colIdx: Int,
      typeName: String,
      arr: Array[T]
  ): MatlabData = {
    val numRows = rows.size()
    for (rowIndex <- 0 to (numRows - 1)) {
      val row = rows.get(rowIndex)
      val rowCandidate: Row = (row: @switch) match {
        case r: Row => row
        case other =>
          org.apache.spark.sql.RowFactory.create(row.asInstanceOf[Object]);
      }
      if (rowCandidate != null) {
        // arr.add(rowCandidate.get(colIdx).asInstanceOf[T])
        arr(rowIndex) = rowCandidate.get(colIdx).asInstanceOf[T]
      }
    }
    // new MatlabDataArray[T](numRows, arr.toArray().asInstanceOf[Array[T]])
    new MatlabDataArray[T](numRows, arr)
  }

  def mapColumnToArray(
      rows: List[Row],
      colIdx: Int,
      colSchema: StructField
  ): MatlabData = {
    val mapType = colSchema.dataType.asInstanceOf[org.apache.spark.sql.types.MapType]
    val keyType = mapType.keyType
    val valType = mapType.valueType
    val numRows = rows.size()

    val arr = new ArrayList[MatlabData](numRows)

    val valIsStruct = valType.typeName == "struct"
    
    var rowIndex: Int = 0
    while (rowIndex < numRows) {

      val row = rows.get(rowIndex).asInstanceOf[GenericRowWithSchema]
      val map = row.getMap(colIdx)
        .asInstanceOf[Map[Object,Object]]
      
      val mapSize = map.size
      val keyArr = new ArrayList[Object](mapSize)
      
      if (valIsStruct) {
        val valueArr = new ArrayList[GenericRowWithSchema](mapSize)
			  for ( (k,v) <- map ) {
				  keyArr.add(k)
				  valueArr.add(v.asInstanceOf[GenericRowWithSchema])
			  }

    	  arr.add(
    			  new MatlabDataMap[Object, Object](
    					  keyArr.toArray(),
    					  valueArr.toArray()
    					  ))
      } else {
    	  val valueArr = new ArrayList[Object](mapSize)

			  for ( (k,v) <- map ) {
				  keyArr.add(k)
				  valueArr.add(v)
			  }

    	  arr.add(
    			  new MatlabDataMap[Object, Object](
    					  keyArr.toArray(),
    					  valueArr.toArray()
    					  ))
      }
//      
      
      rowIndex += 1
    }
    val mdArr = arr.toArray()
    new MatlabDataArray[Object](numRows, mdArr)

  }

  def structColumnToArray(
      rows: List[Row],
      colIdx: Int
  ): MatlabData = {
    val numRows = rows.size()
    val arr = new ArrayList[MatlabData](numRows)
    for (rowIndex <- 0 to (numRows - 1)) {
      val row = rows.get(rowIndex)
      val rowCandidate: Row = row match {
        case r: Row => row
        case other =>
          org.apache.spark.sql.RowFactory.create(row.asInstanceOf[Object]);
      }
      arr.add(
        sparkStructToMatlab(
          rowCandidate.get(colIdx).asInstanceOf[GenericRowWithSchema]
        )
      )
    }
    val mdArr = arr.toArray()
    new MatlabDataArray[Object](numRows, mdArr)
  }

  def arrayColumnToArray(
      rows: List[Row],
      colIdx: Int
  ): MatlabData = {
    val numRows = rows.size()
    val arr = new ArrayList[Object](numRows)

    for (rowIndex <- 0 to (numRows - 1)) {
      val row = rows.get(rowIndex)
      val rowCandidate: Row = row match {
        case r: Row => row
        case other =>
          org.apache.spark.sql.RowFactory.create(row.asInstanceOf[Object])
      }

      val value = WrappedArrayRefToArray(
        rowCandidate.get(colIdx).asInstanceOf[WrappedArray[AnyRef]]
      )
      arr.add(value.asInstanceOf[Object])

    }
    val mdArr = arr.toArray()
    new MatlabDataArray[Object](numRows, mdArr)

  }

  def convertRowToData(row: Row): MatlabData = {
    val rows = new java.util.ArrayList[org.apache.spark.sql.Row](1)
    rows.add(row)
    convertRowsToData(rows)
  }
  
  def convertDatasetToData(ds: Dataset[Row]): MatlabData = {
//    val rows = ds.collectAsList.asInstanceOf[List[GenericRowWithSchema]]
    val rows = ds.collectAsList
    convertRowsToData(rows)
  }

  def convertRowsToData(rows: List[Row]): MatlabData = {
//    val rows = ds.collectAsList()
    val r0 = rows.get(0).asInstanceOf[GenericRowWithSchema]
    val schema = r0.schema
    val fields = schema.fields
    val numRows = rows.size();
    val numFields = fields.length;
    val fieldNames = schema.fieldNames
    val typeNames = fields.map(f => f.dataType.typeName)
    val schemaList = schema.toList
    val columns = new ArrayList[MatlabData]()
    val columnClasses = new Array[AnyRef](numFields)
    // Allocate space for return data
    for (i <- 0 to (numFields - 1)) {
//      columnToArray[T](rows: List[Row], colIdx: Int, typeName: String): MatlabData
      (typeNames(i): @switch) match {
        case "string" =>
          columns.add(
            columnToArray[String](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[String] }
            )
          )
        case "timestamp" =>
          columns.add(
            columnToArray[java.sql.Timestamp](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[java.sql.Timestamp] }
            )
          )
        case "date" =>
          columns.add(
            columnToArray[java.sql.Date](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[java.sql.Date] }
            )
          )
        case "float" =>
          columns.add(
            columnToArray[Float](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Float] }
            )
          )
        case "integer" =>
          columns.add(
            columnToArray[Integer](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Integer] }
            )
          )
        case "boolean" =>
          columns.add(
            columnToArray[Boolean](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Boolean] }
            )
          )
        case "double" =>
          columns.add(
            columnToArray[Double](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Double] }
            )
          )
        case "long" =>
          columns.add(
            columnToArray[Long](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Long] }
            )
          )
        case "binary" =>
          columns.add(
            columnToArray[Array[Byte]](
              rows,
              i,
              typeNames(i),
              Array.fill(numRows) { null.asInstanceOf[Array[Byte]] }
            )
          )
        case "struct" =>
          columns.add(structColumnToArray(rows, i))
        case "array" =>
          columns.add(arrayColumnToArray(rows, i))
        case "map" =>
          columns.add(mapColumnToArray(rows, i, fields(i)))

        case _ =>
          throw new RuntimeException(
            "Type " + typeNames(i) + " is not yet implemented.\n" +
              "Found for field '" + fieldNames(i) + "'"
          );
      }

    }
    new MatlabDataTable(fieldNames, typeNames, columns, numRows, schema)
  }

//  def isWrappedArray(x: Any): Boolean = x match {
//    case _ if x.isInstanceOf[WrappedArray[_]] => true
//    case _ => false
//  }
  def isWrappedArray(x: Any): Boolean = x.isInstanceOf[WrappedArray[_]]
  
//
  
//  def WrappedArrayToList(wa: WrappedArray[AnyRef]) = {
//    WrappedArrayRefToList(wa.asInstanceOf[WrappedArray$ofRef]);
//  }

  def WrappedArrayToList(
//  def WrappedArrayRefToList(
      wa: WrappedArray[AnyRef]
  ): java.util.List[java.lang.Object] = {
    val L = new ArrayList[java.lang.Object]()
    val wa0 = wa(0)
    if (wa0.isInstanceOf[WrappedArray[_]]) {
      wa.foreach(elem =>
        L.add(WrappedArrayToList(elem.asInstanceOf[WrappedArray[AnyRef]]))
      )
    } else {
      wa.foreach(elem => L.add(elem.asInstanceOf[java.lang.Object]))
    }
    L
  }

  def WrappedArrayRefToArray(W: Any): java.util.List[java.lang.Object] = {
    WrappedArrayRefToArray(W.asInstanceOf[WrappedArray[AnyRef]])
  }

  def WrappedArrayRefToArray(
      wa: WrappedArray[AnyRef]
  ): java.util.List[java.lang.Object] = {
    val L = new ArrayList[java.lang.Object]()
    val wa0 = wa(0)
    if (wa0.isInstanceOf[WrappedArray[_]]) {
      wa.foreach(elem =>
        L.add(WrappedArrayToList(elem.asInstanceOf[WrappedArray[AnyRef]]))
      )
    } else {
      wa.foreach(elem => L.add(elem.asInstanceOf[java.lang.Object]))
    }
    L
  }

  /** createScalaHashMap
   * Helper function for creating a HashMap, as it is difficult to do this from within MATLAB.
   * Take the keys and values from the MATLAB Map (containers.Map), and creates a Scala HashMap.
   * The contents of the MATLAB values should already have been converted to Java objects.
   */
  def createScalaHashMap[K,V](keys: Array[K], values: Array[V]): HashMap[K,V] = {
    var HM = new HashMap[K,V]()

    val N = keys.length

    for (i <- 0 to (N - 1)) {
      val tup = (keys(i), values(i))
      HM = HM + tup
    }

    return HM
  }

  def rowToJavaList(row: GenericRowWithSchema) : java.util.List[Object] = {
    import scala.collection.JavaConversions.seqAsJavaList
    seqAsJavaList(row.toSeq.asInstanceOf[Seq[Object]])
  }
  
  def rowToJavaList(row: Row) : java.util.List[Object] = {
    import scala.collection.JavaConversions.seqAsJavaList
    seqAsJavaList(row.toSeq.asInstanceOf[Seq[Object]])
  }
  
  def javaObjectArrayToRow(arr: Array[Any], schema: StructType) : GenericRowWithSchema 
  = {
    val row = new org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema( arr, schema)
    row
  }

  def doubleArrayEncoder(spark: SparkSession) : Encoder[Array[Double]] = {
    import spark.implicits.newDoubleArrayEncoder
    return newDoubleArrayEncoder;
  }
  def floatArrayEncoder(spark: SparkSession) : Encoder[Array[Float]] = {
    import spark.implicits.newFloatArrayEncoder
    return newFloatArrayEncoder;
  }
  def shortArrayEncoder(spark: SparkSession) : Encoder[Array[Short]] = {
    import spark.implicits.newShortArrayEncoder
    return newShortArrayEncoder;
  }
  def intArrayEncoder(spark: SparkSession) : Encoder[Array[Int]] = {
    import spark.implicits.newIntArrayEncoder
    return newIntArrayEncoder;
  }
  def longArrayEncoder(spark: SparkSession) : Encoder[Array[Long]] = {
    import spark.implicits.newLongArrayEncoder
    return newLongArrayEncoder;
  }
  def booleanArrayEncoder(spark: SparkSession) : Encoder[Array[Boolean]] = {
    import spark.implicits.newBooleanArrayEncoder
    return newBooleanArrayEncoder;
  }
  def stringArrayEncoder(spark: SparkSession) : Encoder[Array[String]] = {
    import spark.implicits.newStringArrayEncoder
    return newStringArrayEncoder;
  }
  def byteArrayEncoder(spark: SparkSession) : Encoder[Array[Byte]] = {
    import spark.implicits.newByteArrayEncoder
    return newByteArrayEncoder;
  }

  // implicit def newIntArrayEncoder: Encoder[Array[Int]] = ExpressionEncoder()
  // implicit def newLongArrayEncoder: Encoder[Array[Long]] = ExpressionEncoder()
  // implicit def newDoubleArrayEncoder: Encoder[Array[Double]] = ExpressionEncoder()
  // implicit def newFloatArrayEncoder: Encoder[Array[Float]] = ExpressionEncoder()
  // implicit def newByteArrayEncoder: Encoder[Array[Byte]] = Encoders.BINARY
  // implicit def newShortArrayEncoder: Encoder[Array[Short]] = ExpressionEncoder()
  // implicit def newBooleanArrayEncoder: Encoder[Array[Boolean]] = ExpressionEncoder()
  // implicit def newStringArrayEncoder: Encoder[Array[String]] = ExpressionEncoder()
  // implicit def newProductArrayEncoder[A <: Product : TypeTag]: Encoder[Array[A]] = ExpressionEncoder()
  
}
