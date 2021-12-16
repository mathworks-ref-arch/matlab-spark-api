/**
 * This file contains classes for packaging data, that should be marshalled into MATLAB.
 *
 * Copyright Copyright 2020 MathWorks, Inc.
 */

 package com.mathworks.scala

import org.apache.spark.sql.Dataset
import org.apache.spark.sql.Row
import java.util.ArrayList

trait MatlabData {
  val typeName: String
}

class MatlabDataTable(
    val fieldNames: Array[String],
    val typeNames: Array[String],
    val values: ArrayList[MatlabData],
    val numRows: Int,
    val schema: org.apache.spark.sql.types.StructType
) extends MatlabData {
  val typeName = "table"
}

class MatlabDataStruct(
    val fieldNames: Array[String],
    val typeNames: Array[String],
    var values: Array[Object]
) extends MatlabData {
  val typeName = "struct"
}

class MatlabDataArray[T](val length: Int, val data: Array[T])
    extends MatlabData {
  val typeName = "array"
//  var dataType = data(0).getClass().getName()
}

class MatlabDataScalar[T](val data: T) extends MatlabData {
  val typeName = "scalar"
  val dataType = data.getClass().getName()
}

class MatlabDataMap[KT, VT](
    val keys: Array[KT],
    val data: Array[VT]
) extends MatlabData {
  val typeName = "map"
  val keyType = keys(0).getClass().getName()
  val valType = data(0).getClass().getName()
}
