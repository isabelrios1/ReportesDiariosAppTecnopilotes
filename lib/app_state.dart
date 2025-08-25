import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _TimePickerWidget = '';
  String get TimePickerWidget => _TimePickerWidget;
  set TimePickerWidget(String value) {
    _TimePickerWidget = value;
  }

  String _date = '';
  String get date => _date;
  set date(String value) {
    _date = value;
  }
}
