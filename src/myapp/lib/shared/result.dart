import 'package:flutter/material.dart';

class ApiResult<T> extends DataResult<T>
{
  final String body;

  ApiResult({@required bool success, @required T data, @required this.body, String message = ''}) : super(success:success,data: data, message:message);
}

class DataResult<T> extends Result
{
  final T data;

 DataResult({@required bool success, @required this.data, String message = ''}) : super(success:success,message:message);
}

class Result
{
  final bool success;
  final String message;

  static Result ok([String successMessage = ''])
  {
    return Result(success: true, message: successMessage);
  }

  static Result fail(String errorMessage)
  {
    return Result(success: false, message: errorMessage);
  }

  static DataResult<T> okData<T>(T data, [String successMessage = ''])
  {
    return DataResult<T>(success: true,data: data, message: successMessage);
  }

  static DataResult<T> failData<T>(String errorMessage)
  {
    return DataResult<T>(success: false, data: null, message: errorMessage);
  }

  static ApiResult<T> okApi<T>(T data, String body, [String successMessage = ''])
  {
    return ApiResult<T>(success: true,data: data, body:body, message: null);
  }

  static ApiResult<T> failApi<T>(T data, String body, String errorMessage)
  {
    return ApiResult<T>(success: false, data: data, body:body, message: errorMessage);
  }

  Result({@required this.success, this.message = ''});
}