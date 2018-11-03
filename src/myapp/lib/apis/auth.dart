import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../dtos/firebase.dart';

import '../shared/keys.dart' as keys;

class AuthApi extends ApiBase {
  final String baseUrl = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  Future<ApiResult<AuthenticationResponseDto>> signup(String email, String password) async {
    final payload = AuthenticationRequestDto (
      email: email,
      password: password,
      returnSecureToken: true
    );

    var resp = await http.post('$baseUrl/signupNewUser?key=${keys.firebaseApiKey}', body: getRequestBody(payload));

    var apiResponse = getResponseAsJson(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<AuthenticationResponseDto>(null, apiResponse.json, apiResponse.message);
    }

    var dto = AuthenticationResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }

  Future<ApiResult<AuthenticationResponseDto>> login(String email, String password) async {
     final payload = AuthenticationRequestDto (
      email: email,
      password: password,
      returnSecureToken: true
    );

    var resp = await http.post('$baseUrl/verifyPassword?key=${keys.firebaseApiKey}', body: getRequestBody(payload));

    var apiResponse = getResponseAsJson(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<AuthenticationResponseDto>(null, apiResponse.json, apiResponse.message);
    }

    var dto = AuthenticationResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }
}