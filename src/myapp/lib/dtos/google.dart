class GeocodingResult
{
  final String address;
  final double latitude;
  final double longitude;

  GeocodingResult({this.address, this.latitude, this.longitude});

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
        address: json['results'][0]['formatted_address'],
        latitude: json['results'][0]['geometry']['location']['lat'],
        longitude: json['results'][0]['geometry']['location']['lng']);
  }
}