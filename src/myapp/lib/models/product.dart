import 'package:flutter/material.dart';

//immutable
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imagePath;
  final String imageUrl;
  final bool isFavourite;

  final String userEmail;
  final String userId;

  final String locAddress;
  final double locLat;
  final double locLng;

  Product({
    @required this.id, 
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
    this.isFavourite = false});
}