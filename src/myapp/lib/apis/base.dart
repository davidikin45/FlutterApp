import 'package:http/http.dart' as http;
import '../shared/result.dart';
import 'dart:convert';

abstract class ApiBase {
  String getRequestBody(Object payload) {
    return json.encode(payload);
  }

  ApiResult<Map<String, dynamic>> getResponseData(http.Response response) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    
    if (response.statusCode != 200 && response.statusCode != 201) {
        return Result.failApi(responseData, 'Response statusCode ${response.statusCode.toString()}', response.body);
    }

    return Result.okApi(responseData, response.body);
  }
}
