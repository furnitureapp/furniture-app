

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

class EditUserDialog extends StatefulWidget {
  final String username;
  final String phoneNo;
  final String houseNo;
  final String streetName;
  final String city;
  final String state;
  final String pinCode;

  final Function({
    required String updatedUsername,
    required String updatedPhoneNo,
    required String houseNo,
    required String streetName,
    required String city,
    required String state,
    required String pinCode,
  }) onUpdate;

  const EditUserDialog({
    super.key,
    required this.username,
    required this.phoneNo,
    required this.houseNo,
    required this.streetName,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.onUpdate,
  });

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _phoneNoController;
  late TextEditingController _houseNoController;
  late TextEditingController _streetNameController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;

  String? _formError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _phoneNoController = TextEditingController(text: widget.phoneNo);
    _houseNoController = TextEditingController(text: widget.houseNo);
    _streetNameController = TextEditingController(text: widget.streetName);
    _cityController = TextEditingController(text: widget.city);
    _stateController = TextEditingController(text: widget.state);
    _pinCodeController = TextEditingController(text: widget.pinCode);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNoController.dispose();
    _houseNoController.dispose();
    _streetNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  String? _validateUsername(String value) {
    if (value.isEmpty) return "Username is required";
    if (value.length < 3) return "Username too short (min 3 chars)";
    return null;
  }

  String? _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^\d{10}$');
    if (value.isEmpty) return "Phone number is required";
    if (!phoneRegex.hasMatch(value)) return "Enter valid 10-digit number";
    return null;
  }

  String? _validateHouseNo(String value) {
    if (value.isEmpty) return "House number is required";
    final validPattern = RegExp(r'^\d+[a-zA-Z]?$');
    if (!validPattern.hasMatch(value)) {
      return "Enter a valid house number (e.g. 12, 12A)";
    }
    return null;
  }

  String? _validateStreetName(String value) {
    if (value.isEmpty) return "Street name is required";
    if (value.length < 4) return "Enter valid street name";
    return null;
  }

  String? _validateCity(String value) {
    if (value.isEmpty) return "City is required";
    if (value.length < 3) return "Enter valid city name";
    return null;
  }

  String? _validateState(String value) {
    if (value.isEmpty) return "State is required";
    if (value.length < 3) return "Enter valid state name";
    return null;
  }

  String? _validatePinCode(String value) {
    final pinRegex = RegExp(r'^\d{6}$');
    if (value.isEmpty) return "PIN code is required";
    if (!pinRegex.hasMatch(value)) return "Enter valid 6-digit PIN";
    return null;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    widget.onUpdate(
      updatedUsername: _usernameController.text.trim(),
      updatedPhoneNo: _phoneNoController.text.trim(),
      houseNo: _houseNoController.text.trim(),
      streetName: _streetNameController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
    );

    Navigator.of(context).pop(); // Close dialog after successful update
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 236, 245, 236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Edit Delivery Details',
        style: TextStyle(
          color: mythemecolor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: isTablet ? 500 : double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_formError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _formError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                _buildTextField(
                  label: "Username",
                  icon: Icons.person,
                  controller: _usernameController,
                  validator: _validateUsername,
                ),
                _buildTextField(
                  label: "Phone Number",
                  icon: Icons.phone,
                  controller: _phoneNoController,
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text("🇮🇳 |", style: TextStyle(fontSize: 16)),
                  ),
                  validator: _validatePhoneNumber,
                ),
                _buildTextField(
                  label: "House No.",
                  icon: Icons.home,
                  controller: _houseNoController,
                  validator: _validateHouseNo,
                ),
                _buildTextField(
                  label: "Street Name",
                  icon: Icons.emoji_transportation,
                  controller: _streetNameController,
                  validator: _validateStreetName,
                ),
                _buildTextField(
                  label: "City",
                  icon: Icons.location_city,
                  controller: _cityController,
                  validator: _validateCity,
                ),
                _buildTextField(
                  label: "State",
                  icon: Icons.map,
                  controller: _stateController,
                  validator: _validateState,
                ),
                _buildTextField(
                  label: "PIN Code",
                  icon: Icons.pin_drop,
                  controller: _pinCodeController,
                  validator: _validatePinCode,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
            backgroundColor: mythemecolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Save changes",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    Widget? prefix,
    required TextEditingController controller,
    required String? Function(String) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: (value) => validator(value ?? ""),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: mythemecolor,
 fontSize: 12),
          prefixIcon: Icon(icon, color: mythemecolor,
),
          prefix: prefix,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: mythemecolor1
, width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: mythemecolor1
, width: 3),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
