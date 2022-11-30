/*
 * MWEncoders.scala
 * This file contains some utilities used by SparkBuilder, in order to create encoders more easily
 * in Java code.
 *
 * Copyright 2022-2022 The MathWorks, Inc.
 */

package com.mathworks.spark.sql.encoders
import org.apache.spark.sql.Encoder
import org.apache.spark.sql.catalyst.encoders.{
  encoderFor,
  ExpressionEncoder => MWExprEncoder
}

object MWEncoders {

  /** An encoder for 1-ary tuples.
    */
  def tuple[T1](e1: Encoder[T1]): Encoder[(T1)] = {
    val x1 = encoderFor(e1)
    MWExprEncoder.tuple(Seq(x1)).asInstanceOf[MWExprEncoder[(T1)]]
  }

  /** An encoder for 2-ary tuples.
    */
  def tuple[T1, T2](e1: Encoder[T1], e2: Encoder[T2]): Encoder[(T1, T2)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    MWExprEncoder.tuple(Seq(x1, x2)).asInstanceOf[MWExprEncoder[(T1, T2)]]
  }

  /** An encoder for 3-ary tuples.
    */
  def tuple[T1, T2, T3](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3]
  ): Encoder[(T1, T2, T3)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3)]]
  }

  /** An encoder for 4-ary tuples.
    */
  def tuple[T1, T2, T3, T4](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4]
  ): Encoder[(T1, T2, T3, T4)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4)]]
  }

  /** An encoder for 5-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5]
  ): Encoder[(T1, T2, T3, T4, T5)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5)]]
  }

  /** An encoder for 6-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6]
  ): Encoder[(T1, T2, T3, T4, T5, T6)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5, T6)]]
  }

  /** An encoder for 7-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5, T6, T7)]]
  }

  /** An encoder for 8-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5, T6, T7, T8)]]
  }

  /** An encoder for 9-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9)]]
  }

  /** An encoder for 10-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10))
      .asInstanceOf[MWExprEncoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)]]
  }

  /** An encoder for 11-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11))
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11)
      ]]
  }

  /** An encoder for 12-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12))
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12)
      ]]
  }

  /** An encoder for 13-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13))
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13)
      ]]
  }

  /** An encoder for 14-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14]
  ): Encoder[(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    MWExprEncoder
      .tuple(Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14))
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14)
      ]]
  }

  /** An encoder for 15-ary tuples.
    */
  def tuple[T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15]
  ): Encoder[
    (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    MWExprEncoder
      .tuple(
        Seq(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15)
      )
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15)
      ]]
  }

  /** An encoder for 16-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16]
  ): Encoder[
    (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16
        )
      )
      .asInstanceOf[MWExprEncoder[
        (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16)
      ]]
  }

  /** An encoder for 17-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17]
  ): Encoder[
    (T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T15, T16, T17)
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17
        )
      ]]
  }

  /** An encoder for 18-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17,
      T18
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17],
      e18: Encoder[T18]
  ): Encoder[
    (
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        T8,
        T9,
        T10,
        T11,
        T12,
        T13,
        T14,
        T15,
        T16,
        T17,
        T18
    )
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    val x18 = encoderFor(e18)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17,
          x18
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17,
            T18
        )
      ]]
  }

  /** An encoder for 19-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17,
      T18,
      T19
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17],
      e18: Encoder[T18],
      e19: Encoder[T19]
  ): Encoder[
    (
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        T8,
        T9,
        T10,
        T11,
        T12,
        T13,
        T14,
        T15,
        T16,
        T17,
        T18,
        T19
    )
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    val x18 = encoderFor(e18)
    val x19 = encoderFor(e19)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17,
          x18,
          x19
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17,
            T18,
            T19
        )
      ]]
  }

  /** An encoder for 20-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17,
      T18,
      T19,
      T20
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17],
      e18: Encoder[T18],
      e19: Encoder[T19],
      e20: Encoder[T20]
  ): Encoder[
    (
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        T8,
        T9,
        T10,
        T11,
        T12,
        T13,
        T14,
        T15,
        T16,
        T17,
        T18,
        T19,
        T20
    )
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    val x18 = encoderFor(e18)
    val x19 = encoderFor(e19)
    val x20 = encoderFor(e20)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17,
          x18,
          x19,
          x20
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17,
            T18,
            T19,
            T20
        )
      ]]
  }

  /** An encoder for 21-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17,
      T18,
      T19,
      T20,
      T21
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17],
      e18: Encoder[T18],
      e19: Encoder[T19],
      e20: Encoder[T20],
      e21: Encoder[T21]
  ): Encoder[
    (
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        T8,
        T9,
        T10,
        T11,
        T12,
        T13,
        T14,
        T15,
        T16,
        T17,
        T18,
        T19,
        T20,
        T21
    )
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    val x18 = encoderFor(e18)
    val x19 = encoderFor(e19)
    val x20 = encoderFor(e20)
    val x21 = encoderFor(e21)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17,
          x18,
          x19,
          x20,
          x21
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17,
            T18,
            T19,
            T20,
            T21
        )
      ]]
  }

  /** An encoder for 22-ary tuples.
    */
  def tuple[
      T1,
      T2,
      T3,
      T4,
      T5,
      T6,
      T7,
      T8,
      T9,
      T10,
      T11,
      T12,
      T13,
      T14,
      T15,
      T16,
      T17,
      T18,
      T19,
      T20,
      T21,
      T22
  ](
      e1: Encoder[T1],
      e2: Encoder[T2],
      e3: Encoder[T3],
      e4: Encoder[T4],
      e5: Encoder[T5],
      e6: Encoder[T6],
      e7: Encoder[T7],
      e8: Encoder[T8],
      e9: Encoder[T9],
      e10: Encoder[T10],
      e11: Encoder[T11],
      e12: Encoder[T12],
      e13: Encoder[T13],
      e14: Encoder[T14],
      e15: Encoder[T15],
      e16: Encoder[T16],
      e17: Encoder[T17],
      e18: Encoder[T18],
      e19: Encoder[T19],
      e20: Encoder[T20],
      e21: Encoder[T21],
      e22: Encoder[T22]
  ): Encoder[
    (
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        T8,
        T9,
        T10,
        T11,
        T12,
        T13,
        T14,
        T15,
        T16,
        T17,
        T18,
        T19,
        T20,
        T21,
        T22
    )
  ] = {
    val x1 = encoderFor(e1)
    val x2 = encoderFor(e2)
    val x3 = encoderFor(e3)
    val x4 = encoderFor(e4)
    val x5 = encoderFor(e5)
    val x6 = encoderFor(e6)
    val x7 = encoderFor(e7)
    val x8 = encoderFor(e8)
    val x9 = encoderFor(e9)
    val x10 = encoderFor(e10)
    val x11 = encoderFor(e11)
    val x12 = encoderFor(e12)
    val x13 = encoderFor(e13)
    val x14 = encoderFor(e14)
    val x15 = encoderFor(e15)
    val x16 = encoderFor(e16)
    val x17 = encoderFor(e17)
    val x18 = encoderFor(e18)
    val x19 = encoderFor(e19)
    val x20 = encoderFor(e20)
    val x21 = encoderFor(e21)
    val x22 = encoderFor(e22)
    MWExprEncoder
      .tuple(
        Seq(
          x1,
          x2,
          x3,
          x4,
          x5,
          x6,
          x7,
          x8,
          x9,
          x10,
          x11,
          x12,
          x13,
          x14,
          x15,
          x16,
          x17,
          x18,
          x19,
          x20,
          x21,
          x22
        )
      )
      .asInstanceOf[MWExprEncoder[
        (
            T1,
            T2,
            T3,
            T4,
            T5,
            T6,
            T7,
            T8,
            T9,
            T10,
            T11,
            T12,
            T13,
            T14,
            T15,
            T16,
            T17,
            T18,
            T19,
            T20,
            T21,
            T22
        )
      ]]
  }

}
