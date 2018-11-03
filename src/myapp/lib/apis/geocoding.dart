import 'package:http/http.dart' as http;
import './base.dart';

import 'package:location/location.dart' as geoloc;

import '../shared/result.dart';

import '../dtos/google.dart';

class GeocodingApi extends ApiBase {
  final String apiKey;

  GeocodingApi(this.apiKey);

  Future<ApiResult<GeocodingResult>> getCoordinates(String address) async {
      final Uri uri = Uri.https('maps.googleapis.com','/maps/api/geocode/json', {'address': address, 'key': apiKey});

    var resp = await http.get(uri);

    var apiResponse = getResponseAsJson(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<GeocodingResult>(null, apiResponse.json, apiResponse.message);
    }

    var dto = GeocodingResult.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }

  Future<ApiResult<GeocodingResult>> getLocation(double lat, double lng) async {
      final Uri uri = Uri.https('maps.googleapis.com','/maps/api/geocode/json', {'latlng': '${lat.toString()},${lng.toString()}', 'key': apiKey});

    var resp = await http.get(uri);

    var apiResponse = getResponseAsJson(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<GeocodingResult>(null, apiResponse.json, apiResponse.message);
    }

    var dto = GeocodingResult.fromJson(apiResponse.json);

    return Result.okApi(dto, apiResponse.json);
  }

  Future<ApiResult<GeocodingResult>> currentLocation() async {

    final location = geoloc.Location();
    final currentLocation = await location.getLocation();

    double lat = currentLocation['latitude'];
    double lng = currentLocation['longitude'];

    var resp = await getLocation(lat, lng);

    return resp;
  }
}