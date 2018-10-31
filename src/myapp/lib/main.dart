import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

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
  List<Map<String, dynamic>> _products = [];

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  dynamic staticRoutes() {
    return {
      '/': (BuildContext context) => AuthPage(),
      '/products': (BuildContext context) => ProductsPage(_products),
      '/admin': (BuildContext context) =>
          ProductsAdminPage(_addProduct, _deleteProduct)
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
          builder: (BuildContext context) => ProductPage(
              _products[index]['title'],
                _products[index]['image'],
                _products[index]['price'],
                _products[index]['description']),);
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ProductsPage(_products));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        onUnknownRoute: unknownRouteHandler);
  }
}
