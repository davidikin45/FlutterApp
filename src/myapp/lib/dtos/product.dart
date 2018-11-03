import 'package:flutter/material.dart';

//immutable
class ProductDto {
  final String id;
  final String title;
  final String description;
  final double price;

  final String imagePath;
  final String imageUrl;

  final String userEmail;
  final String userId;
  final Map<String, dynamic> wishListUsers;

  final String locAddress;
  final double locLat;
  final double locLng;

  ProductDto(
      {this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imagePath,
      @required this.imageUrl,
      @required this.userEmail,
      @required this.userId,
      @required this.locAddress,
      @required this.locLat,
      @required this.locLng,
      this.wishListUsers});

  factory ProductDto.fromDynamic(String id, dynamic json) {
    return ProductDto(
      id: id,
      title: json['title'],
      description: json['description'],
      price: json['price'],
      imagePath: json['imagePath'],
      imageUrl: json['imageUrl'],
      userEmail: json['userEmail'],
      userId: json['userId'],
      locAddress: json['loc_address'],
      locLat: json['loc_lat'],
      locLng: json['loc_lng'],
      wishListUsers: json['wishListUsers'] == null ?  Map<String, dynamic>() : (json['wishListUsers'] as Map<String, dynamic>)
    );
  }

   Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'imagePath': imagePath,
        'imageUrl': imageUrl,
        'userEmail': userEmail,
        'userId': userId,
        'loc_address': locAddress,
        'loc_lng': locLng,
        'loc_lat': locLat,
      };
}
