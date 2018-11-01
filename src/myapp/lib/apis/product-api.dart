import 'package:http/http.dart' as http;
import 'dart:convert';

import './api-response.dart';
import '../models/product.dart';

class ProductApi {
  final String baseUrl = 'https://flutter-products-43c5c.firebaseio.com';

    Future<ApiResponse<List<Product>>> fetchAll() async {    
    var resp = await http.get(baseUrl + '/products.json');
        
    var apiResponse = _getResponseData(resp);

    if(!apiResponse.success)
    {
      return ApiResponse<List<Product>>(false, apiResponse.body, null);
    }

    final List<Product> list = [];

    if(apiResponse.data != null)
    {
      apiResponse.data.forEach((String id, dynamic item){
            final Product newProduct = Product(
            id : id, 
            title:item['title'], 
            description:item['description'], 
            image:item['image'], 
            price: item['price'],  
            userEmail: item['userEmail'], 
            userId: item['userId']);
            list.add(newProduct);
        });
    }

    return ApiResponse<List<Product>>(true, "", list);
  }

  Future<ApiResponse<Map<String, dynamic>>> add(String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.post(baseUrl + '/products.json', body: _getRequestData(payload));

    var apiResponse = _getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResponse<Map<String, dynamic>>> update(String id, String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.put(baseUrl + '/products/$id.json', body: _getRequestData(payload));

    var apiResponse = _getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete(baseUrl + '/products/$id.json');

    var apiResponse = _getResponseData(resp);

   return apiResponse;
  }

  String _getRequestData(Object payload) {
    return json.encode(payload);
  }

  ApiResponse<Map<String, dynamic>> _getResponseData(http.Response response) {
     if(response.statusCode != 200 && response.statusCode != 201)
    {
      return ApiResponse(false, response.body, null);
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    return ApiResponse(true,  response.body, responseData);
  }
}