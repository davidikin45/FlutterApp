import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../dtos/product.dart';

class ProductApi extends ApiBase {
  final String tableName = 'products';
  final String baseUrl = 'https://flutter-products-43c5c.firebaseio.com';
  final String token;

  ProductApi(this.token);

  Future<ApiResult<List<ProductDto>>> fetchAll() async {
    var resp = await http.get('$baseUrl/$tableName.json?auth=$token');

    var apiResponse = getResponseAsJson(resp);

    if (!apiResponse.success) {
      return Result.failApi<List<ProductDto>>(
          null, apiResponse.json, apiResponse.message);
    }

    final List<ProductDto> list = [];

    if (apiResponse.data != null) {
      apiResponse.data.forEach((String id, dynamic item) {
        final ProductDto newProduct = ProductDto.fromDynamic(id, item);
        list.add(newProduct);
      });
    }

    return Result.okApi(list, apiResponse.json);
  }

  Future<ApiResult<String>> add(ProductDto payload) async {

    var resp = await http.post('$baseUrl/$tableName.json?auth=$token',
        body: getRequestBody(payload));

    var apiResponse = getResponseAsJson(resp);

    if (!apiResponse.success) {
      return Result.failApi<String>(
          null, apiResponse.json, apiResponse.message);
    }

    String id = apiResponse.json['name'];
    return Result.okApi(id, apiResponse.json);
  }

  Future<ApiResult<Map<String, dynamic>>> update(
      String id,
      ProductDto payload) async {

    var resp = await http.put('$baseUrl/$tableName/$id.json?auth=$token',
        body: getRequestBody(payload));

    var apiResponse = getResponseAsJson(resp);

    return apiResponse;
  }

  Future<ApiResult<bool>> setAsFavourite(String id, String userId) async {
    //firebase put returns whatever you send
    var resp = await http.put('$baseUrl/$tableName/$id/wishListUsers/$userId.json?auth=$token', body: getRequestBody(true));

    var apiResponse = getResponseAsBoolean(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> removeAsFavourite(String id, String userId) async {

    var resp = await http.delete('$baseUrl/$tableName/$id/wishListUsers/$userId.json?auth=$token');

    var apiResponse = getResponseAsJson(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete('$baseUrl/$tableName/$id.json?auth=$token');

    var apiResponse = getResponseAsJson(resp);

    return apiResponse;
  }
}
