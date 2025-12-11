import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/delivery_service.dart';
import 'package:furniture_ecom_app/constants/colors.dart';

class AddDeliveryDetailsScreen extends StatefulWidget {
  const AddDeliveryDetailsScreen({super.key});

  @override
  State<AddDeliveryDetailsScreen> createState() =>
      _AddDeliveryDetailsScreenState();
}

class _AddDeliveryDetailsScreenState extends State<AddDeliveryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dealerNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  bool _isLoading = false;
  String? _formError;

  String? _validateDealerName(String value) {
    if (value.isEmpty) return "Dealer name is required";
    if (value.length < 3) return "Dealer name too short (min 3 chars)";
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
    final validPattern = RegExp(r'^\d+[A-Za-z]?(\/\d+[A-Za-z]?)?$');
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

  Future<void> _addDeliveryDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _formError = null;
    });

    try {
      await DeliveryService.createDelivery(
        dealername: _dealerNameController.text.trim(),
        phoneNo: _phoneNoController.text.trim(),
        houseNo: _houseNoController.text.trim(),
        streetName: _streetNameController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
      );

      setState(() {
        _formError = "Delivery details added successfully!";
      });

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context, true);
    } catch (e) {
      log('Error while adding delivery details: $e');
      setState(() {
        _formError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    Widget addressForm = Form(
      key: _formKey,
      child: Column(
        children: [
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _formError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _formError!.toLowerCase().contains("success")
                      ? mythemecolor
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          buildTextField(
            label: "Enter Dealer Name",
            icon: Icons.person,
            controller: _dealerNameController,
            validator: _validateDealerName,
          ),
          buildTextField(
            label: "Enter Phone Number",
            icon: Icons.phone,
            controller: _phoneNoController,
            prefix: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text("🇮🇳 |", style: TextStyle(fontSize: 16)),
            ),
            validator: _validatePhoneNumber,
          ),
          buildTextField(
            label: "House / Apartment Number",
            icon: Icons.home,
            controller: _houseNoController,
            validator: _validateHouseNo,
          ),
          buildTextField(
            label: "Street Name",
            icon: Icons.emoji_transportation,
            controller: _streetNameController,
            validator: _validateStreetName,
          ),
          buildTextField(
            label: "City",
            icon: Icons.location_city,
            controller: _cityController,
            validator: _validateCity,
          ),
          buildTextField(
            label: "State",
            icon: Icons.map,
            controller: _stateController,
            validator: _validateState,
          ),
          buildTextField(
            label: "PIN Code",
            icon: Icons.pin_drop,
            controller: _pinCodeController,
            validator: _validatePinCode,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator(color: mythemecolor)
              : ElevatedButton(
                  onPressed: _addDeliveryDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mythemecolor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("CONTINUE"),
                ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
       appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mythemecolor1, mythemecolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Add Delivery Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: isTablet ? 650 : double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: addressForm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    Widget? prefix,
    required TextEditingController controller,
    required String? Function(String) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: (value) => validator(value ?? ""),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: mythemecolor),
          prefixIcon: Icon(icon, color: mythemecolor),
          prefix: prefix,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: mythemecolor, width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: mythemecolor, width: 3),
          ),
        ),
      ),
    );
  }
}



// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/services/delivery_service.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';


// class AddDeliveryDetailsScreen extends StatefulWidget {
//   const AddDeliveryDetailsScreen({super.key});

//   @override
//   State<AddDeliveryDetailsScreen> createState() =>
//       _AddDeliveryDetailsScreenState();
// }

// class _AddDeliveryDetailsScreenState extends State<AddDeliveryDetailsScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _phoneNoController = TextEditingController();
//   final TextEditingController _houseNoController = TextEditingController();
//   final TextEditingController _streetNameController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _pinCodeController = TextEditingController();

//   bool _isLoading = false;
//   String? _formError;

  

//   String? _validateUsername(String value) {
//     if (value.isEmpty) return "Username is required";
//     if (value.length < 3) return "Username too short (min 3 chars)";
//     return null;
//   }

//   String? _validatePhoneNumber(String value) {
//     final phoneRegex = RegExp(r'^\d{10}$');
//     if (value.isEmpty) return "Phone number is required";
//     if (!phoneRegex.hasMatch(value)) return "Enter valid 10-digit number";
//     return null;
//   }

//   String? _validateHouseNo(String value) {
//     if (value.isEmpty) return "House number is required";

//     final validPattern = RegExp(r'^\d+[a-zA-Z]?$');

//     if (!validPattern.hasMatch(value)) {
//       return "Enter a valid house number (e.g. 12, 12A)";
//     }

//     return null;
//   }

//   String? _validateStreetName(String value) {
//     if (value.isEmpty) return "Street name is required";
//     if (value.length < 4) return "Enter valid street name";
//     return null;
//   }

//   String? _validateCity(String value) {
//     if (value.isEmpty) return "City is required";
//     if (value.length < 3) return "Enter valid city name";
//     return null;
//   }

//   String? _validateState(String value) {
//     if (value.isEmpty) return "State is required";
//     if (value.length < 3) return "Enter valid state name";
//     return null;
//   }

//   String? _validatePinCode(String value) {
//     final pinRegex = RegExp(r'^\d{6}$');
//     if (value.isEmpty) return "PIN code is required";
//     if (!pinRegex.hasMatch(value)) return "Enter valid 6-digit PIN";
//     return null;
//   }

//   Future<void> _addDeliveryDetails() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _formError = null;
//     });

//     try {
//       await DeliveryService.createDelivery(
//         username: _usernameController.text.trim(),
//         phoneNo: _phoneNoController.text.trim(),
//         houseNo: _houseNoController.text.trim(),
//         streetName: _streetNameController.text.trim(),
//         city: _cityController.text.trim(),
//         state: _stateController.text.trim(),
//         pinCode: _pinCodeController.text.trim(),
//       );
//       setState(() {
//         _formError = "Delivery details added successfully!";
//       });
//       await Future.delayed(const Duration(seconds: 1));
//       Navigator.pop(context, true);
//     } catch (e) {
//       log('Error while adding delivery details: $e');
//       setState(() {
//         _formError = e.toString().replaceAll('Exception: ', '');
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final bool isTablet = screenWidth >= 600;

//     Widget addressForm = Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (_formError != null)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: Text(
//                 _formError!,
//                 style: TextStyle(
//                   color: _formError!.toLowerCase().contains("success")
//                       ? Colors.green
//                       : Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           buildTextField(
//             label: "Enter your Username",
//             icon: Icons.person,
//             controller: _usernameController,
//             validator: _validateUsername,
//           ),
//           buildTextField(
//             label: "Enter your Phone Number",
//             icon: Icons.phone,
//             controller: _phoneNoController,
//             prefix: const Padding(
//               padding: EdgeInsets.only(right: 8.0),
//               child: Text("🇮🇳 |", style: TextStyle(fontSize: 16)),
//             ),
//             validator: _validatePhoneNumber,
//           ),
//           buildTextField(
//             label: "House/Apartment Number",
//             icon: Icons.home,
//             controller: _houseNoController,
//             validator: _validateHouseNo,
//           ),
//           buildTextField(
//             label: "Street Name",
//             icon: Icons.emoji_transportation,
//             controller: _streetNameController,
//             validator: _validateStreetName,
//           ),
//           buildTextField(
//             label: "City",
//             icon: Icons.location_city,
//             controller: _cityController,
//             validator: _validateCity,
//           ),
//           buildTextField(
//             label: "State",
//             icon: Icons.map,
//             controller: _stateController,
//             validator: _validateState,
//           ),
//           buildTextField(
//             label: "PIN Code",
//             icon: Icons.pin_drop,
//             controller: _pinCodeController,
//             validator: _validatePinCode,
//           ),
//           const SizedBox(height: 20),
//           _isLoading
//               ? const CircularProgressIndicator(color: mythemecolor)
//               : ElevatedButton(
//                   onPressed: _addDeliveryDetails,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 12),
//                     textStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text("CONTINUE"),
//                 ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 236, 245, 236),
//       resizeToAvoidBottomInset: true,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                   mythemecolor1,
//                mythemecolor,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: const Text(
//               "Add Delivery Details",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
     
//       body: SafeArea(
//   child: Center(
//     child: SizedBox(
//       width: isTablet ? 650 : double.infinity,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Card(
//           color: Colors.white,
//           elevation: 5,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(12)),
//                 child: Image.asset(
//                   "assets/images/del.png",
//                   width: double.infinity,
//                   height: isTablet ? 100 : 80,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: addressForm,
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   ),
// ),

//     );
//   }

//   Widget buildTextField({
//     required String label,
//     required IconData icon,
//     Widget? prefix,
//     required TextEditingController controller,
//     required String? Function(String) validator,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         controller: controller,
//         validator: (value) => validator(value ?? ""),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: tdgreen, fontSize: 12),
//           prefixIcon: Icon(icon, color: tdgreen),
//           prefix: prefix,
//           enabledBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.green, width: 2),
//           ),
//           focusedBorder: const UnderlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromARGB(255, 50, 107, 34), width: 3),
//           ),
//           errorStyle: const TextStyle(
//             color: Colors.red,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }
