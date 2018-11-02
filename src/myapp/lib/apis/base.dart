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
        return Result.failApi(responseData, responseData, 'Response statusCode ${response.statusCode.toString()}');
    }

    return Result.okApi(responseData, responseData);
  }
}

abstract class FirebaseApi extends ApiBase {
  final String tableName = 'products';
  final String baseUrl;
  final String token;

  FirebaseApi(this.baseUrl, this.token);

  Future<ApiResult<Map<String, dynamic>>> fetchAll() async {
    var resp = await http.get('$baseUrl/$tableName.json?auth=$token');

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> add(Map<String, dynamic> payload) async {

    var resp = await http.post('$baseUrl/$tableName.json?auth=$token',
        body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> update(
      String id,
      Map<String, dynamic> payload) async {

    var resp = await http.put('$baseUrl/$tableName/$id.json?auth=$token',
        body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete('$baseUrl/$tableName/$id.json?auth=$token');

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }
}
