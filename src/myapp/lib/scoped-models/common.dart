import 'dart:io';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rxdart/subjects.dart';

import '../models/auth.dart';
import '../models/user.dart';
import '../models/product.dart';

import '../apis/image_upload.dart';
import '../apis/auth.dart';
import '../apis/product.dart';
import '../shared/result.dart';
import '../dtos/product.dart';
import '../dtos/firebase.dart';
import '../dtos/google.dart';

class CommonModel extends Model {
  String _selProductId;
  List<Product> _products = [];
  User _authenticatedUser;
  bool _isLoading = false;

  void triggerRender() {
    notifyListeners(); //triggers rerender like setState does
  }

  void showSpinner() {
    _isLoading = true;
    triggerRender();
  }

  void hideSpinner() {
    _isLoading = false;
    triggerRender();
  }
}

class UtilityModel extends CommonModel {
  bool get isLoading {
    return _isLoading;
  }
}

class UserModel extends CommonModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Result> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    showSpinner();

    try {
      ApiResult<AuthenticationResponseDto> resp;
      if (mode == AuthMode.Login) {
        resp = await AuthApi().login(email, password);
      } else {
        resp = await AuthApi().signup(email, password);
      }

      if (!resp.success) {
        hideSpinner();
        var errorMessage = resp.json['error']['message'];

        if (errorMessage == 'EMAIL_EXISTS') {
          return Result.fail('This email already exists.');
        } else if (errorMessage == 'EMAIL_NOT_FOUND' ||
            errorMessage == 'INVALID_PASSWORD') {
          return Result.fail('Invalid credentials.');
        }

        return Result.fail('Invalid credentials.');
      }

      setAuthTimeout(int.parse(resp.data.expiresIn));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(resp.data.expiresIn)));
      _authenticatedUser =
          User(id: resp.data.localId, email: email, token: resp.data.idToken);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _authenticatedUser.token);
      prefs.setString('userEmail', _authenticatedUser.email);
      prefs.setString('userId', _authenticatedUser.id);
      prefs.setString('expiryTime', expiryTime.toIso8601String());

      hideSpinner();
      return Result.ok('Authentication succeeded');
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        triggerRender();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);
      triggerRender();
    }
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selProductId = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }
}

class ProductsModel extends CommonModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return List.from(_products.where((p) => p.isFavourite).toList());
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere((p) => p.id == _selProductId);
  }

  bool get displayFavouritesOnly {
    return _showFavourites;
  }

  int get selectedProductIndex {
    return _products.indexWhere((p) => p.id == _selProductId);
  }

  Future<Null> fetchProducts({bool onlyForUser = false, clearExisting = false}) async {
    showSpinner();
    if(clearExisting)
    {
      _products = [];
    }
    try {
      var resp = await ProductApi(_authenticatedUser.token).fetchAll();
      if (!resp.success) {
        hideSpinner();
        return;
      }

      final List<Product> list = [];
      resp.data.where((p) {
        return !onlyForUser || p.userId == _authenticatedUser.id;
      }).forEach((p) {
        list.add(Product(
            id: p.id,
            title: p.title,
            description: p.description,
            price: p.price,
            imagePath: p.imagePath,
            imageUrl: p.imageUrl,
            userEmail: p.userEmail,
            userId: p.userId,
            isFavourite: p.wishListUsers.containsKey(_authenticatedUser.id),
            locAddress: p.locAddress,
            locLat: p.locLat,
            locLng: p.locLng));
      });

      _products = list;
      hideSpinner();
      _selProductId = null;
      return;
    } catch (err) {
      hideSpinner();
      return;
    }
  }

  Future<Result> addProduct(String title, String description, File image,
      double price, GeocodingResult location) async {
    showSpinner();
    try {
      var imageResp =
          await ImageUploadApi(_authenticatedUser.token).uploadImage(image);
      if (!imageResp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final payload = ProductDto(
          title: title,
          description: description,
          imagePath: imageResp.data.imagePath,
          imageUrl: imageResp.data.imageUrl,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id,
          locAddress: location.address,
          locLat: location.latitude,
          locLng: location.longitude);

      var resp = await ProductApi(_authenticatedUser.token).add(payload);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final Product newProduct = Product(
          id: resp.data,
          title: title,
          description: description,
          imagePath: imageResp.data.imagePath,
          imageUrl: imageResp.data.imageUrl,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id,
          locAddress: location.address,
          locLat: location.latitude,
          locLng: location.longitude);
      _products.add(newProduct);

      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  Future<Result> updateProduct(String title, String description, File image,
      double price, GeocodingResult location) async {
    showSpinner();
    try {

      String imageUrl = selectedProduct.imageUrl;
      String imagePath = selectedProduct.imagePath;
      if (image != null) {

        var imageResp =
            await ImageUploadApi(_authenticatedUser.token).uploadImage(image);

        if (!imageResp.success) {
          hideSpinner();
          return Result.fail('Please try again!');
        }

        imageUrl = imageResp.data.imageUrl;
        imagePath = imageResp.data.imagePath;
      }

      final payload = ProductDto(
          title: title,
          description: description,
          imagePath: imagePath,
          imageUrl: imageUrl,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          locAddress: location.address,
          locLat: location.latitude,
          locLng: location.longitude);

      var resp = await ProductApi(_authenticatedUser.token)
          .update(selectedProduct.id, payload);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          imagePath: imagePath,
          imageUrl: imageUrl,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          locAddress: location.address,
          locLat: location.latitude,
          locLng: location.longitude);

      _products[selectedProductIndex] = updatedProduct;
      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  Future<Result> deleteProduct() async {
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;
    showSpinner();
    try {
      var resp =
          await ProductApi(_authenticatedUser.token).delete(deletedProductId);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }
      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  void toggleProductFavouriteStatus() async {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    bool error = false;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        imagePath: selectedProduct.imagePath,
        imageUrl: selectedProduct.imageUrl,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus,
        locAddress: selectedProduct.locAddress,
        locLat: selectedProduct.locLat,
        locLng: selectedProduct.locLng);
    _products[selectedProductIndex] = updatedProduct;
    triggerRender();

    if (newFavouriteStatus) {
      try {
        var resp = await ProductApi(_authenticatedUser.token)
            .setAsFavourite(selectedProduct.id, _authenticatedUser.id);
        error = !resp.success;
      } catch (err) {
        error = true;
      }
    } else {
      try {
        var resp = await ProductApi(_authenticatedUser.token)
            .removeAsFavourite(selectedProduct.id, _authenticatedUser.id);
        error = !resp.success;
      } catch (err) {
        error = true;
      }
    }

    if (error) {
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          imagePath: selectedProduct.imagePath,
          imageUrl: selectedProduct.imageUrl,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavourite: !newFavouriteStatus,
          locAddress: selectedProduct.locAddress,
          locLat: selectedProduct.locLat,
          locLng: selectedProduct.locLng);

      _products[selectedProductIndex] = updatedProduct;
      triggerRender();
    }

    _selProductId = null;
  }

  void selectProduct(String id) {
    _selProductId = id;
    if (id != null) {
      triggerRender();
    }
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    triggerRender();
  }
}
