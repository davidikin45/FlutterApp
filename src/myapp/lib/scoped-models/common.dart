import 'package:scoped_model/scoped_model.dart';

import '../models/auth.dart';
import '../models/user.dart';
import '../models/product.dart';

import '../apis/auth.dart';
import '../apis/product.dart';
import '../shared/result.dart';

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
   Future<Result> authenticate(String email, String password, [AuthMode mode = AuthMode.Login]) async {
     showSpinner();

    try {
      ApiResult<Map<String, dynamic>> resp;
      if(mode == AuthMode.Login)
      {
         resp = await AuthApi().login(email, password);
      }
      else
      {
         resp = await AuthApi().signup(email, password);
      }

      if (!resp.success) {
        hideSpinner();
        var errorMessage = resp.data['error']['message'];

        if (errorMessage == 'EMAIL_EXISTS') {
          return Result.fail('This email already exists.');
        }
        else if (errorMessage == 'EMAIL_NOT_FOUND' || errorMessage == 'INVALID_PASSWORD') {
          return Result.fail('Invalid credentials.');
        }
       
        return Result.fail('Invalid credentials.');
      }

      hideSpinner();
      return Result.ok('Authentication succeeded');
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
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

  Future<Null> fetchProducts() async {
    showSpinner();
    try {
      var resp = await ProductApi().fetchAll();
      if (!resp.success) {
        hideSpinner();
        return;
      }
      _products = resp.data;
      hideSpinner();
      _selProductId = null;
      return;
    } catch (err) {
      hideSpinner();
      return;
    }
  }

  Future<Result> addProduct(
      String title, String description, String image, double price) async {
    showSpinner();
    try {
      var resp = await ProductApi().add(_authenticatedUser.email,
          _authenticatedUser.id, title, description, image, price);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final Product newProduct = Product(
          id: resp.data['name'].toString(),
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);

      hideSpinner();
      return Result.ok();
    } catch (err) {
      hideSpinner();
      return Result.fail('Please try again!');
    }
  }

  Future<Result> updateProduct(
      String title, String description, String image, double price) async {
    showSpinner();
    try {
      var resp = await ProductApi().update(
          selectedProduct.id,
          selectedProduct.userEmail,
          selectedProduct.userId,
          title,
          description,
          image,
          price);
      if (!resp.success) {
        hideSpinner();
        return Result.fail('Please try again!');
      }

      final updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
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
      var resp = await ProductApi().delete(deletedProductId);
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

  void toggleProductFavouriteStatus() {
    final bool isCurrentlyFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isCurrentlyFavourite;
    final Product updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: newFavouriteStatus);
    _products[selectedProductIndex] = updatedProduct;
    triggerRender();
  }

  void selectProduct(String id) {
    _selProductId = id;
    triggerRender();
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    triggerRender();
  }
}
