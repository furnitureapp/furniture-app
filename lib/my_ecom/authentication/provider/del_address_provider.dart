import 'package:flutter/material.dart';

class SelectedAddressProvider extends ChangeNotifier {
  Map<String, dynamic>? _selectedAddress;
  Map<String, dynamic>? get selectedAddress => _selectedAddress;
  String? get selectedAddressId => _selectedAddress?['id'];
  void setAddress(Map<String, dynamic> address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void clear() {
    _selectedAddress = null;
    notifyListeners();
  }
}
