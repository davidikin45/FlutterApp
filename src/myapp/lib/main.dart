import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

import './models/product.dart';
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

  dynamic staticRoutes(MainModel model) {
    return {
      '/': (BuildContext context) => AuthPage(),
      '/products': (BuildContext context) => ProductsPage(model),
      '/admin': (BuildContext context) =>
          ProductsAdminPage(model)
    };
  }

  Route<bool> dynamicRouteHandler(RouteSettings settings, MainModel model) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '') {
      return null;
    }
    if (pathElements[1] == 'product') {
      final String id = pathElements[2];
      final Product product = model.allProducts.firstWhere((p)=>p.id == id);
      return MaterialPageRoute<bool>(
          builder: (BuildContext context) => ProductPage(product),);
    }
    return null;
  }

  Route<bool> unknownRouteHandler(RouteSettings settings, MainModel model) {
    return MaterialPageRoute(
        builder: (BuildContext context) => ProductsPage(model));
  }

  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();

    return ScopedModel<MainModel>(
      //one instance of model
      model: model,
      child: MaterialApp(
        //debugShowMaterialGrid: true,
        theme: ThemeData(
            //fontFamily: 'Oswald',
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        //home: AuthPage(),
        routes: staticRoutes(model),
        onGenerateRoute: (RouteSettings settings) => dynamicRouteHandler(settings, model),
        onUnknownRoute: (RouteSettings settings) => unknownRouteHandler(settings, model)));
  }
}
