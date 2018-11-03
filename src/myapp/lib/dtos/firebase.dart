import 'package:flutter/material.dart';

class AuthenticationRequestDto {
  final String email;
  final String password;
  final bool returnSecureToken;

  AuthenticationRequestDto(
      {@required this.email,
      @required this.password,
      this.returnSecureToken = true});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'returnSecureToken': returnSecureToken
      };
}

class AuthenticationResponseDto {
  final String kind;
  final String idToken;
  final String email;
  final String refreshToken;
  final String expiresIn;
  final String localId;

  AuthenticationResponseDto(
      {@required this.kind,
      @required this.idToken,
      @required this.email,
      @required this.refreshToken,
      @required this.expiresIn,
      @required this.localId});

  factory AuthenticationResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponseDto(
        kind: json['kind'],
        idToken: json['idToken'],
        email: json['email'],
        refreshToken: json['refreshToken'],
        expiresIn: json['expiresIn'],
        localId: json['localId']);
  }
}

class ImageUploadResponseDto {
  final String imagePath;
  final String imageUrl;

  ImageUploadResponseDto(
      {@required this.imagePath,
      @required this.imageUrl});

  factory ImageUploadResponseDto.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponseDto(
        imagePath: json['imagePath'],
        imageUrl: json['imageUrl']);
  }
}