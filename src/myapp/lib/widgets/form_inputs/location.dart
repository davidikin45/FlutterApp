import 'package:flutter/material.dart';

import 'package:map_view/map_view.dart';

import '../../apis/geocoding.dart';
import '../../dtos/google.dart';
import '../../models/product.dart';

import '../../shared/keys.dart' as keys;

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  Uri _staticMapUri;
  GeocodingResult _locationData;
  final FocusNode _addressInputfocusNode = FocusNode();
  TextEditingController _addressInputController = TextEditingController();

  @override
  void initState() {
    _addressInputfocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getStaticMap(widget.product.locAddress, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputfocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _getStaticMap(String address,
      {geocode = false, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }

    if (geocode) {
      var resp = await GeocodingApi(keys.googleApiKey)
          .getCoordinates(address);
      _locationData = resp.data;
    } else if (lat == null && lng == null) {
      _locationData = GeocodingResult(
          address: widget.product.locAddress,
          latitude: widget.product.locLat,
          longitude: widget.product.locLng);
    } else {
      _locationData =
          GeocodingResult(address: address, latitude: lat, longitude: lng);
    }
    if (mounted) {
      final StaticMapProvider staticMapViewProvider =
          StaticMapProvider(keys.googleApiKey);
      final Uri staticMapUri = staticMapViewProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.latitude,
            _locationData.longitude)
      ],
          center: Location(_locationData.latitude, _locationData.longitude),
          width: 500,
          height: 300,
          maptype: StaticMapViewType.roadmap);
      widget.setLocation(_locationData);

      setState(() {
        _addressInputController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  void _getUserLocation() async {
    try {
      var resp = await GeocodingApi(keys.googleApiKey)
          .currentLocation();
      _getStaticMap(resp.data.address,
          geocode: false, lat: resp.data.latitude, lng: resp.data.longitude);
    } catch (err) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Could not fetch location'),
                content: Text('Please add an address manually!'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]);
          });
    }
  }

  void _updateLocation() {
    if (!_addressInputfocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text, geocode: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TextFormField(
          focusNode: _addressInputfocusNode,
          controller: _addressInputController,
          validator: (String value) {
            if (_locationData == null || value.isEmpty) {
              return 'No valid location found.';
            }
          },
          decoration: InputDecoration(labelText: 'Address')),
      SizedBox(height: 10.0),
      FlatButton(
        child: Text('Locate User'),
        onPressed: _getUserLocation,
      ),
      SizedBox(height: 10.0),
      _staticMapUri == null
          ? Container()
          : Image.network(_staticMapUri.toString())
    ]);
  }
}
