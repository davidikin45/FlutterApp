import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';

class AuthApi extends ApiBase {
  final String apiKey = 'AIzaSyBezaAajSgJS53o2YnVH72MYKA8rW1QNR0';
  final String baseUrl = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  Future<ApiResult<Map<String, dynamic>>> signup(String email, String password) async {
    final Map<String, dynamic> payload = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    var resp = await http.post('$baseUrl/signupNewUser?key=$apiKey', body: getRequestBody(payload), headers: {'Content-Type:': 'application/json'});

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> login(String email, String password) async {
     final Map<String, dynamic> payload = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    var resp = await http.post('$baseUrl/verifyPassword?key=$apiKey', body: getRequestBody(payload), headers: {'Content-Type:': 'application/json'});

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }
}