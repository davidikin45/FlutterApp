import 'package:flutter/services.dart';

Future<String> getBatteryLevel() async {
  final _platformChannel = MethodChannel('flutter-course.com/battery');
  String batteryLevel;
  try {
    final int result = await _platformChannel.invokeMethod('getBatteryLevel');
    batteryLevel = 'Battery level is $result %.';
  } catch (err) {
    batteryLevel = 'Failed to get battery level.';
  }
  return batteryLevel;
}