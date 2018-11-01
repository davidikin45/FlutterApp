import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../models/product.dart';

class ProductApi extends ApiBase {
  final String baseUrl = 'https://flutter-products-43c5c.firebaseio.com';

    Future<ApiResult<List<Product>>> fetchAll() async {    
    var resp = await http.get('$baseUrl/products.json');
        
    var apiResponse = getResponseData(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<List<Product>>(null, apiResponse.message, apiResponse.body);
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

   return Result.okApi(list, apiResponse.body);
  }

  Future<ApiResult<Map<String, dynamic>>> add(String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.post('$baseUrl/products.json', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> update(String id, String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.put('$baseUrl/products/$id.json', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete('$baseUrl/products/$id.json');

    var apiResponse = getResponseData(resp);

   return apiResponse;
  }
}