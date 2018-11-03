import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:scoped_model/scoped_model.dart';
import '../shared/result.dart';

import '../models/product.dart';
import '../scoped-models/main.dart';
import '../widgets/form_inputs/image.dart';
import '../widgets/form_inputs/location.dart';
import '../widgets/ui_elements/adaptive_progress_indicator.dart';
import '../dtos/google.dart';

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
    'image': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  Widget _buildTitleTextField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Title',
      ),
      controller: _titleTextController,
      //initialValue: product == null ? '' : product.title,
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
    if (product == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (product != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Product Description',
      ),
      controller: _descriptionTextController,
      //initialValue: product == null ? '' : product.description,
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
    if (product == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (product != null && _priceTextController.text.trim() == '') {
      _priceTextController.text =
          product == null ? '' : product.price.toString();
    }
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'Product Price',
        ),
        //initialValue: product == null ? '' : product.price.toString(),
        controller: _priceTextController,
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
            return "Price is required and should be a number.";
          }
        },
        keyboardType: TextInputType.number);
  }

  void _showErrorMessage(String errorMessage) {
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

  void _setLocation(GeocodingResult result) {
    _formData['location'] = result;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitFormHandler(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }

    _formKey.currentState.save();

    if (selectedProductIndex == -1) {
      addProduct(
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              double.parse(
                  _priceTextController.text.replaceFirst(RegExp(r','), '.')),
              _formData['location'])
          .then((Result result) {
        if (result.success) {
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          _showErrorMessage(result.message);
        }
      });
    } else {
      updateProduct(
              _titleTextController.text,
              _descriptionTextController.text,
              _formData['image'],
              double.parse(
                  _priceTextController.text.replaceFirst(RegExp(r','), '.')),
              _formData['location'])
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
          ? Center(child: AdaptiveProgressIndicator())
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
                    LocationInput(_setLocation, product),
                    SizedBox(height: 10.0),
                    ImageInput(_setImage, product),
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
              appBar: AppBar(
                  elevation: Theme.of(context).platform == TargetPlatform.iOS
                      ? 0.0
                      : 4.0,
                  title: Text('Edit Product')),
              body: pageContent);
    });
  }
}
