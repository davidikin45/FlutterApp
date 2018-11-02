import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../dtos/firebase.dart';

class AuthApi extends ApiBase {
  final String apiKey = 'AIzaSyBezaAajSgJS53o2YnVH72MYKA8rW1QNR0';
  final String baseUrl = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  Future<ApiResult<AuthenticationResponseDto>> signup(String email, String password) async {
    final payload = AuthenticationRequestDto (
      email: email,
      password: password,
      returnSecureToken: true
    );

    var resp = await http.post('$baseUrl/signupNewUser?key=$apiKey', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

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

    var resp = await http.post('$baseUrl/verifyPassword?key=$apiKey', body: getRequestBody(payload));

    var apiResponse = getResponseData(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<AuthenticationResponseDto>(null, apiResponse.json, apiResponse.message);
    }

    var dto = AuthenticationResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }
}