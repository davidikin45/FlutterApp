import 'package:flutter/material.dart';

//immutable
class ProductDto {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;

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
      @required this.image,
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
      image: json['image'],
      userEmail: json['userEmail'],
      userId: json['userId'],
      locAddress: json['loc_addres'],
      locLat: json['loc_lat'],
      locLng: json['loc_lat'],
      wishListUsers: json['wishListUsers'] == null ?  Map<String, dynamic>() : (json['wishListUsers'] as Map<String, dynamic>)
    );
  }

   Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'price': price,
        'image': image,
        'userEmail': userEmail,
        'userId': userId,
        'loc_address': locAddress,
        'loc_lng': locLng,
        'loc_lat': locLat,
      };
}
