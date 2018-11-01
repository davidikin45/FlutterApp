# Getting Started with Flutter

## Install Flutter
* [Setup Instructions](https://flutter.io/setup-windows/)
1. Install [Flutter](https://flutter.io/get-started/install/) to C:\src\flutter
2. Open C:\src\flutter\packages\flutter_tools\gradle\flutter.gradle
3. Add google() to buildscript
```
buildscript {
    repositories {
		google()
        jcenter()
        maven {
            url 'https://dl.google.com/dl/android/maven2'
        }
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:3.1.2'
    }
}
```
4. Add C:\src\flutter to the user "Path" variable
5. Install [Android Studio](https://developer.android.com/studio/)
6. File > Settings > Plugins < Browse repositories
7. Type "Flutter" and install
8. Type "Android WiFi Connect" and install
9. Open VS Code
10. Extensions 
11. Type "Flutter" and install
12. Type "Material Icon Theme", Install and activate
13. Run the following command
```
flutter doctor
```

## Setting up a new project
1. Open VS Code
2. View > Command Palette
3. Type “flutter”, and select the Flutter: New Project action
4. Enter a project name (such as myapp), and press Enter
5. Create or select the parent directory for the new project folder
6. Wait for project creation to complete and the main.dart file to appear
7. Can also use the following command:
```
flutter create flutter_course
```
8. Open Android Studio and open myapp\android
9. Tools > AVD Manager > Create new Virtual Device with latest SDK version.
10. Create the following folders
```
assets
fonts
pages
widgets
models
scoped-models
```
11. In VS Code Press F5 to launch or type
```
flutter run
```

## Useful notes
* [Learn Dart](https://www.dartlang.org/)
* Ctrl+Shift+F5 = Hot Reload
* Ctrl+F5 = Hot Restart
* @override is optional
* prefix with _ for private fields.
* State widgets call build when loaded and when internal data changes.
* Stateless widgets call build when loaded and when external data changes.
* Wrap code in setState(){} which modifies state
```
 setState(() {
	_products.add('Advanved Food Tester');
});
```
* Access widget properties in state by using widget.property. No need to call setState in initState.
```
 @override
    void initState() {
      _products.add(widget.startingProduct);
      super.initState();
    }
```
* Named constructor params and optional params
```
ProductManager({this.startingProduct = 'Sweets Tester'})
```
* Optional params only
```
Products([this.products = const []])
```
* Pass functions (delegates)
```
final Function addProduct;
```
* build()  must not return null but can return container()

## Firebase
1. Create a new project using [Firebase](https://firebase.google.com/)
2. Database > Create Realtime Database
3. Start in test mode
4. Authentication > Set up sign-in method
5. Email/Password
6. [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth/)
7. Authentication > Web setup > apiKey
8. Signup
```
https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=[API_KEY]
```
9. Login
```
https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=[API_KEY]
```
10. Database > Rules to enable authentication
```
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```


## Http Requests
* (flutter http)[https://pub.dartlang.org/packages/http]
1. Modify pubspec.yml
```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  http: ^0.11.3
```
2. Run the following command
```
flutter packages get
```

## /shared/result.dart
```
import 'package:flutter/material.dart';

class ApiResult<T> extends DataResult<T>
{
  final String body;

  ApiResult({@required bool success, @required T data, @required this.body, String message = ''}) : super(success:success,data: data, message:message);
}

class DataResult<T> extends Result
{
  final T data;

 DataResult({@required bool success, @required this.data, String message = ''}) : super(success:success,message:message);
}

class Result
{
  final bool success;
  final String message;

  static Result ok([String successMessage = ''])
  {
    return Result(success: true, message: successMessage);
  }

  static Result fail(String errorMessage)
  {
    return Result(success: false, message: errorMessage);
  }

  static DataResult<T> okData<T>(T data, [String successMessage = ''])
  {
    return DataResult<T>(success: true,data: data, message: successMessage);
  }

  static DataResult<T> failData<T>(String errorMessage)
  {
    return DataResult<T>(success: false, data: null, message: errorMessage);
  }

  static ApiResult<T> okApi<T>(T data, String body, [String successMessage = ''])
  {
    return ApiResult<T>(success: true,data: data, body:body, message: null);
  }

  static ApiResult<T> failApi<T>(T data, String body, String errorMessage)
  {
    return ApiResult<T>(success: false, data: data, body:body, message: errorMessage);
  }

  Result({@required this.success, this.message = ''});
}
```

## /apis/base.dart
```
import 'package:http/http.dart' as http;
import '../shared/result.dart';
import 'dart:convert';

abstract class ApiBase {
  String getRequestData(Object payload) {
    return json.encode(payload);
  }

  ApiResult<Map<String, dynamic>> getResponseData(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      return Result.failApi(
          'Response statusCode ${response.statusCode.toString()}',
          response.body);
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    return Result.okApi(responseData, response.body);
  }
}
```

## /apis/product.dart
```
import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';
import '../models/product.dart';

class ProductApi extends ApiBase {
  final String baseUrl = 'https://flutter-products-43c5c.firebaseio.com';

    Future<ApiResult<List<Product>>> fetchAll() async {    
    var resp = await http.get(baseUrl + '/products.json');
        
    var apiResponse = getResponseData(resp);

    if(!apiResponse.success)
    {
      return Result.failApi<List<Product>>(apiResponse.errorMessage, apiResponse.body);
    }

    final List<Product> list = [];

    if(apiResponse.data != null)
    {
      apiResponse.data.forEach((String id, dynamic item){
            final Product newProduct = Product(
            id : id, 
            title:item['title'], 
            description:item['description'], 
            image:item['image'], 
            price: item['price'],  
            userEmail: item['userEmail'], 
            userId: item['userId']);
            list.add(newProduct);
        });
    }

   return Result.okApi(list, apiResponse.body);
  }

  Future<ApiResult<Map<String, dynamic>>> add(String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.post(baseUrl + '/products.json', body: getRequestData(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> update(String id, String userEmail, String userId, String title, String description, String image, double price) async {
    final Map<String, dynamic> payload = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    var resp = await http.put(baseUrl + '/products/$id.json', body: getRequestData(payload));

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> delete(String id) async {
    var resp = await http.delete(baseUrl + '/products/$id.json');

    var apiResponse = getResponseData(resp);

   return apiResponse;
  }
}
```
## /apis/auth.dart
```
import 'package:http/http.dart' as http;
import './base.dart';

import '../shared/result.dart';

class AuthApi extends ApiBase {
  final String apiKey = 'AIzaSyBezaAajSgJS53o2YnVH72MYKA8rW1QNR0';
  final String baseUrl = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty';

  Future<ApiResult<Map<String, dynamic>>> signup(String email, String password) async {
    final Map<String, dynamic> payload = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    var resp = await http.post('$baseUrl/signupNewUser?key=$apiKey', body: getRequestBody(payload), headers: {'Content-Type:': 'application/json'});

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }

  Future<ApiResult<Map<String, dynamic>>> login(String email, String password) async {
     final Map<String, dynamic> payload = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    var resp = await http.post('$baseUrl/verifyPassword?key=$apiKey', body: getRequestBody(payload), headers: {'Content-Type:': 'application/json'});

    var apiResponse = getResponseData(resp);

    return apiResponse;
  }
}
```

## App State
* (scoped model)https://pub.dartlang.org/packages/scoped_model
1. Modify pubspec.yml
```
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  scoped_model: ^0.3.0
```
2. Run the following command
```
flutter packages get
```
3. Use the following syntax to access state
```
ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
return ...
})
```

## models\auth.dart
```
enum AuthMode{
  Signup,
  Login
}
```

## models\product.dart
```
import 'package:flutter/material.dart';

//immutable
class Product {
  final String title;
  final String description;
  final double price;
  final String image;
  final bool isFavourite;

  final String userEmail;
  final String userId;

  Product({
    @required this.title, 
    @required this.description, 
    @required this.price, 
    @required this.image,
    @required this.userEmail,
    @required this.userId,
    this.isFavourite = false});
}
```

## scoped-models\main.dart
```
import 'package:scoped_model/scoped_model.dart';

import './common.dart';
import './products.dart';
import './user.dart';

class MainModel extends Model with UserModel, ProductsModel {
   
}
```

## scoped-models\common.dart
```
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

```

## main.dart with state and named routes
* Wrap MaterialApp with ScopedModel<MainModel>
```
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

import './scoped-models/main.dart';

void main() {
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintPointersEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  dynamic staticRoutes() {
    return {
      '/': (BuildContext context) => AuthPage(),
      '/products': (BuildContext context) => ProductsPage(),
      '/admin': (BuildContext context) =>
          ProductsAdminPage()
    };
  }

  Route<bool> dynamicRouteHandler(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '') {
      return null;
    }
    if (pathElements[1] == 'product') {
      final int index = int.parse(pathElements[2]);
      return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProductPage(index),);
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ProductsPage());
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      //one instance of model
      model: MainModel(),
      child: MaterialApp(
        //debugShowMaterialGrid: true,
        theme: ThemeData(
            //fontFamily: 'Oswald',
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        //home: AuthPage(),
        routes: staticRoutes(),
        onGenerateRoute: dynamicRouteHandler,
        onUnknownRoute: unknownRouteHandler));
  }
}
```

## pages\product_edit.dart
```
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import '../shared/result.dart';

import '../models/product.dart';
import '../scoped-models/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title',
      ),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return "Title is required and should be 5+ characters long.";
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Description',
      ),
      initialValue: product == null ? '' : product.description,
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return "Description is required and should be 10+ characters long.";
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
      maxLines: 4,
    );
  }

  Widget _buildProductPriceTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Price',
      ),
      initialValue: product == null ? '' : product.price.toString(),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return "Price is required and should be a number.";
        }
      },
      onSaved: (String value) {
        //No need to call setState unless you want to rerender
        // setState(() {
        //   _priceValue = double.parse(value);
        // });
        _formData['price'] = double.parse(value);
      },
      keyboardType: TextInputType.number,
    );
  }

  void _showErrorMessage(String errorMessage)
  {
    showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(errorMessage),
                  content: Text('Please try again!'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay'))
                  ],
                );
              });
  }

  void _submitFormHandler(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(_formData['title'], _formData['description'],
              _formData['image'], _formData['price'])
          .then((Result result) {
        if (result.success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          _showErrorMessage(result.errorMessage);
        }
      });
    } else {
      updateProduct(_formData['title'], _formData['description'],
              _formData['image'], _formData['price'])
        .then((Result result) {
        if (result.success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          _showErrorMessage(result.errorMessage);
        }
      });
    }
  }

  Widget _buildSaveButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('Save'),
              textColor: Colors.white,
              onPressed: () => _submitFormHandler(
                  model.addProduct,
                  model.updateProduct,
                  model.selectProduct,
                  model.selectedProductIndex));
    });
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
        onTap: () {
          //closes form when clicking somewhere
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
                  children: <Widget>[
                    _buildTitleTextField(product),
                    _buildDescriptionTextField(product),
                    _buildProductPriceTextField(product),
                    SizedBox(height: 10.0),
                    _buildSaveButton()
                  ],
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);

      return model.selectedProductIndex == -1
          ? pageContent
          : Scaffold(
              appBar: AppBar(title: Text('Edit Product')), body: pageContent);
    });
  }
}

```

## Stateless Widget
* Create build methods to keep the build() method clean.
```
import 'package:flutter/material.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow()
  {
    return ...
  }

  Widget _buildActionButtons(BuildContext context)
  {
    return ...
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
        child: Column(children: <Widget>[
      Image.asset(product['image']),
      _buildTitlePriceRow(),
      AddressTag('Union Square, San Francisco'),
      _buildActionButtons(context)
    ]));
  }
}
```

## Material Components Widgets
[Material Components Widgets](https://flutter.io/widgets/material/)

## Image widget
1. Create a new folder named assets
2. Copy images into  assets
3. Edit pubspec.yaml
4. Add image to assets:
```
  assets:
    - assets/food.jpg
```
5. Use the image with the following syntax
```
Image.asset('assets/food.jpg')
AssetImage(product.image)
Image.network('https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg')
NetworkImage(product.image)

 FadeInImage(
        image: NetworkImage(product.image), 
        height: 300.0,
        fit: BoxFit.cover,
      placeholder: AssetImage('assets/food.jpg'))
```

## Fonts
1. Create a new folder named fonts
2. Copy .ttf fonts into  assets
3. Edit pubspec.yaml
4. Add font to assets:
```
  fonts:
    - family: Oswald
      fonts:
         - asset: fonts/Oswald-Bold.ttf
           weight: 700
```
5. Use the font with the following syntax
```
Text(products[index]['title'], style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, fontFamily: 'Oswald'))
```

## Loading Indicator
```
Center(child: CircularProgressIndicator())
```

## Pull Down Refresh
* Ensure the onRefresh method returns a Future
```
RefreshIndicator(onRefresh:(){model.fetchProducts();}, child: content);
```

## List View
1. This method will render all items
```
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]){
    print('[Products Widget] Constructor');
  }

 //Using a ListView will by default RENDER all items
  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build');
    return ListView(
        children: products
            .map((product) => Card(
                  child: Column(children: <Widget>[
                    Image.asset('assets/food.jpg'),
                    Text(product)
                  ]),
                ))
            .toList());
  }
}
```
2. This method will only render items on the screen
```
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  final List<String> products;

  Products([this.products = const []]) {
    print('[Products Widget] Constructor');
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Card(
        child: Column(children: <Widget>[
      Image.asset('assets/food.jpg'),
      Text(products[index])
    ]));
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build');
    return ListView.builder(
        itemBuilder: _buildProductItem, itemCount: products.length);
  }
}
```

## Navigation
1. Navigate to new page handling return value
```
        FlatButton(
            child: Text('Details'),
            onPressed: () => Navigator.pushNamed<bool>(context, '/product/' + index.toString())
                        .then((bool result) {
                            if (result)
                            {
                                deleteProduct(index);
                            }
                        }))
```
2. Navifate to named route
```
Navigator.pushReplacementNamed(context, '/admin');
```
3. Navigate to new page not allowing user to go back
```
RaisedButton(
                child: Text('LOGIN'),
                onPressed: () {
                   Navigator.pushReplacementNamed(context, '/');
                }
```				
4. Navigate back
```
    return WillPopScope(
        onWillPop: (){
          print('Back button pressed!');
          Navigator.pop(context, false);
		   //allows user to leave
            return Future.value(false);
        },
        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text('DELETE'),
                          onPressed: () => Navigator.pop(context, true)));
```

##Map Object = json
```
Map<String, String>
Map<String, String> product = {'title': 'Chocolate', 'image': 'assets/food.jpg'}
product['title']
```

## Tabs
```
import 'package:flutter/material.dart';

import './products.dart';
import './product_create.dart';
import './product_list.dart';

class ProductsAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                title: Text('Choose'),
              ),
              ListTile(
                title: Text('All Products'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ProductsPage()));
                },
              )
            ],
          ),
        ),
        //bottomNavigationBar
        appBar: AppBar(
          title: Text('Manage Products'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.create),
                text: 'Create Product',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'My Products',
              ),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          ProductCreatePage(),
          ProductListPage()
        ],),
      ),
    );
  }
}
```

## Dialog
```
  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('This action cannot be undone!'),
              actions: <Widget>[
                FlatButton(
                    child: Text('DISCARD'),  
                    onPressed: () {
                      //Closes dialog
                      Navigator.pop(context);
                    }),
                FlatButton(
                    child: Text('CONTINUE'),
                    onPressed: () {
                      Navigator.pop(context); 
                      Navigator.pop(context, true);
                    })
              ]);
        });
  }
 onPressed: () => _showWarningDialog(context)))
```

##Modal
```
onPressed: () {
        showModalBottomSheet(context:context, builder: (BuildContext context){
          return Center(child: Text('This is a Modal!'));
        });
      }
```

## Rows/Columns
* Expanded takes all available space
* flex property distributes space relatively
```
Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 10,
              child:Text(products[index]['title'],
                style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald'))),
            SizedBox(width: 8.0),
             Expanded(
                flex: 10,
               child:Container(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Theme.of(context).accentColor),
                child: Text('\$${products[index]['price'].toString()}',
                    style: TextStyle(color: Colors.white))))
          ],
        )
```

## Icons
1. Navigation icon
```
 ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'), onTap: (){
            Navigator.pushReplacementNamed(context, '/admin');
        }) 
```

2. Icon Button
```
 IconButton(
            icon: Icon(Icons.info),
            color: Theme.of(context).accentColor,
            onPressed: () => Navigator.pushNamed<bool>(
                context, '/product/' + index.toString())),
                 IconButton(
            color: Colors.red,
            icon: Icon(Icons.favorite_border),
            onPressed: () {
              
            })
```

## Media Queries
```
final double deviceWidth =  MediaQuery.of(context).size.width;
final targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
```

## Custom Buttons
```
 GestureDetector(
                child: Container(
                    color: Colors.green,
                    padding: EdgeInsets.all(5.0),
                    child: Text('My Button')),
                onTap: () {})
```

## Authors

* **David Ikin**