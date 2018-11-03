import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import './base.dart';

import 'package:mime/mime.dart';

import '../dtos/firebase.dart';
import '../shared/result.dart';

class ImageUploadApi extends ApiBase {
  final String token;
  final String baseUrl = 'https://us-central1-flutter-products-43c5c.cloudfunctions.net';

  ImageUploadApi(this.token);

  Future<ApiResult<ImageUploadResponseDto>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse('$baseUrl/storeImage'));

    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));

    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] = 'Bearer $token';

    var streamedResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamedResponse);

    var apiResponse = getResponseAsJson(resp);

    if (!apiResponse.success) {
      return Result.failApi<ImageUploadResponseDto>(
          null, apiResponse.json, apiResponse.message);
    }

    var dto = ImageUploadResponseDto.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }
}
