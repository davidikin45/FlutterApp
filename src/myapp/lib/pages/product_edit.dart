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
                  title: Text('Something went wrong'),
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
          _showErrorMessage(result.message);
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
          _showErrorMessage(result.message);
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
