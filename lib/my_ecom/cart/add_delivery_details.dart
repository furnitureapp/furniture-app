import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';


class AddDeliveryDetailsScreen extends StatefulWidget {
  const AddDeliveryDetailsScreen({super.key});

  @override
  State<AddDeliveryDetailsScreen> createState() =>
      _AddDeliveryDetailsScreenState();
}

class _AddDeliveryDetailsScreenState extends State<AddDeliveryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  bool _isLoading = false;
  String? _formError;

  

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

  Future<void> _addDeliveryDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _formError = null;
    });

    try {
      await ApiService.createDelivery(
        username: _usernameController.text.trim(),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _formError!,
                style: TextStyle(
                  color: _formError!.toLowerCase().contains("success")
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          buildTextField(
            label: "Enter your Username",
            icon: Icons.person,
            controller: _usernameController,
            validator: _validateUsername,
          ),
          buildTextField(
            label: "Enter your Phone Number",
            icon: Icons.phone,
            controller: _phoneNoController,
            prefix: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text("🇮🇳 |", style: TextStyle(fontSize: 16)),
            ),
            validator: _validatePhoneNumber,
          ),
          buildTextField(
            label: "House/Apartment Number",
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
              ? const CircularProgressIndicator(color: tdgreen)
              : ElevatedButton(
                  onPressed: _addDeliveryDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("CONTINUE"),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 245, 236),
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 149, 220, 124),
                Color.fromARGB(255, 41, 97, 67),
              ],
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
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  "assets/images/del.png",
                  width: double.infinity,
                  height: isTablet ? 100 : 80,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: addressForm,
              ),
            ],
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
          labelStyle: const TextStyle(color: tdgreen, fontSize: 12),
          prefixIcon: Icon(icon, color: tdgreen),
          prefix: prefix,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromARGB(255, 50, 107, 34), width: 3),
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




 // body: Stack(
      //   children: [
      //     SafeArea(
      //       bottom: true,
      //       child: Center(
      //         child: Padding(
      //           padding: const EdgeInsets.all(20),
      //           child: isTablet
      //               ? ConstrainedBox(
      //                   constraints: const BoxConstraints(
      //                       maxWidth: 650, maxHeight: 850),
      //                   child: Card(
      //                     color: const Color.fromARGB(255, 247, 253, 247),
      //                     elevation: 5,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: Column(
      //                       mainAxisSize: MainAxisSize.min,
      //                       crossAxisAlignment: CrossAxisAlignment.center,
      //                       children: [
      //                         const SizedBox(height: 10),
      //                         ClipRRect(
      //                           borderRadius: const BorderRadius.vertical(
      //                               top: Radius.circular(12)),
      //                           child: Image.asset(
      //                             "assets/images/del.png",
      //                             width: double.infinity,
      //                             height: 130,
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.all(20),
      //                           child: addressForm,
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 )
      //               : ConstrainedBox(
      //                   constraints: const BoxConstraints(
      //                     maxWidth: 550,
      //                     maxHeight: 850,
      //                   ),
      //                   child: Card(
      //                     color: Colors.white,
      //                     elevation: 5,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(12),
      //                     ),
      //                     child: Column(
      //                       mainAxisSize: MainAxisSize.min,
      //                       crossAxisAlignment: CrossAxisAlignment.center,
      //                       children: [
      //                         ClipRRect(
      //                           borderRadius: const BorderRadius.vertical(
      //                               top: Radius.circular(12)),
      //                           child: Image.asset(
      //                             "assets/images/del.png",
      //                             width: double.infinity,
      //                             height: 80,
      //                           ),
      //                         ),
      //                         Padding(
      //                           padding: const EdgeInsets.all(10),
      //                           child: addressForm,
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),


// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:model_app/authentication/api_service.dart';
// import 'package:model_app/constants/colors.dart';
// import 'package:model_app/constants/snackbar.dart';

// class AddDeliveryDetailsScreen extends StatefulWidget {
//   const AddDeliveryDetailsScreen({super.key});

//   @override
//   State<AddDeliveryDetailsScreen> createState() =>
//       _AddDeliveryDetailsScreenState();
// }

// class _AddDeliveryDetailsScreenState extends State<AddDeliveryDetailsScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _phoneNoController = TextEditingController();
//   final TextEditingController _houseNoController = TextEditingController();
//   final TextEditingController _streetNameController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _pinCodeController = TextEditingController();

//   bool _isLoading = false;

//   Future<void> _handleRefresh() async {
//     await Future.delayed(const Duration(seconds: 1));

//     setState(() {
//       _usernameController.clear();
//       _phoneNoController.clear();
//       _houseNoController.clear();
//       _streetNameController.clear();
//       _cityController.clear();
//       _stateController.clear();
//       _pinCodeController.clear();
//     });
//   }

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
//     final username = _usernameController.text.trim();
//     final phoneNo = _phoneNoController.text.trim();
//     final houseNo = _houseNoController.text.trim();
//     final streetName = _streetNameController.text.trim();
//     final city = _cityController.text.trim();
//     final state = _stateController.text.trim();
//     final pinCode = _pinCodeController.text.trim();

//     // Validate all fields
//     final errors = [
//       _validateUsername(username),
//       _validatePhoneNumber(phoneNo),
//       _validateHouseNo(houseNo),
//       _validateStreetName(streetName),
//       _validateCity(city),
//       _validateState(state),
//       _validatePinCode(pinCode),
//     ].where((error) => error != null).toList();

//     if (errors.isNotEmpty) {
//       showTopSnackBar(context, errors.first!);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await ApiService.createDelivery(
//         username: username,
//         phoneNo: phoneNo,
//         houseNo: houseNo,
//         streetName: streetName,
//         city: city,
//         state: state,
//         pinCode: pinCode,
//       );
//       showTopSnackBar(context, "Delivery details added successfully!");
//       Navigator.pop(context, true);
//     } catch (e) {
//       log('Error while adding delivery details: $e');
//       showTopSnackBar(context, e.toString().replaceAll('Exception: ', ''));
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

//     Widget addressForm = Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "Add your Delivery Details!",
//           style: TextStyle(
//             color: Color.fromARGB(255, 199, 4, 69),
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),
//         buildTextField(
//           "Enter your Username",
//           Icons.person,
//           _usernameController,
//           _validateUsername,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "Enter your Phone Number",
//           Icons.call,
//           _phoneNoController,
//           _validatePhoneNumber,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "House/Apartment Number",
//           Icons.home,
//           _houseNoController,
//           _validateHouseNo,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "Street Name",
//           Icons.light,
//           _streetNameController,
//           _validateStreetName,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "City",
//           Icons.location_city,
//           _cityController,
//           _validateCity,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "State",
//           Icons.map,
//           _stateController,
//           _validateState,
//         ),
//         const SizedBox(height: 10),
//         buildTextField(
//           "PIN Code",
//           Icons.pin,
//           _pinCodeController,
//           _validatePinCode,
//         ),
//         const SizedBox(height: 30),
//         _isLoading
//             ? const CircularProgressIndicator(color: tdgreen)
//             : GestureDetector(
//                 onTap: _addDeliveryDetails,
//                 child: Container(
//                   width: 170,
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color.fromARGB(255, 42, 208, 48),
//                         Color.fromARGB(255, 227, 232, 150)
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                         color: Color.fromARGB(255, 199, 4, 69), width: 4),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color.fromARGB(255, 246, 146, 216),
//                         blurRadius: 5,
//                         spreadRadius: 1,
//                         offset: const Offset(2, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Center(
//                     child: Text(
//                       'Save Details',
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromARGB(255, 144, 12, 45)),
//                     ),
//                   ),
//                 ),
//               ),
//       ],
//     );

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 const Color.fromARGB(255, 26, 99, 91),
//                 Colors.green,
//                 Color.fromARGB(255, 26, 99, 91),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: Text(
//               "Add Delivery Details",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               isTablet
//                   ? 'assets/images/register.png'
//                   : 'assets/images/logg.png',
//               fit: BoxFit.fill,
//             ),
//           ),
//           RefreshIndicator(
//             onRefresh: _handleRefresh,
//             color: const Color.fromARGB(255, 22, 97, 33),
//             backgroundColor: const Color.fromARGB(255, 253, 252, 253),
//             displacement: 50,
//             strokeWidth: 3.5,
//             child: SingleChildScrollView(
//               physics: AlwaysScrollableScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: isTablet
//                     ? ConstrainedBox(
//                         constraints:
//                             const BoxConstraints(maxWidth: 650, maxHeight: 850),
//                         child: Card(
//                           color: const Color.fromARGB(255, 247, 253, 247),
//                           elevation: 5,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const SizedBox(height: 20),
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(12)),
//                                 child: Image.asset(
//                                   "assets/images/del.png",
//                                   width: double.infinity,
//                                   height: 130,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: addressForm,
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     : ConstrainedBox(
//                         constraints: const BoxConstraints(
//                           maxWidth: 550,
//                           maxHeight: 850,
//                         ),
//                         child: Card(
//                           color: const Color.fromARGB(255, 247, 253, 247),
//                           elevation: 5,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               const SizedBox(height: 20),
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(12)),
//                                 child: Image.asset(
//                                   "assets/images/del.png",
//                                   width: double.infinity,
//                                   height: 130,
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: addressForm,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildTextField(
//     String label,
//     IconData icon,
//     TextEditingController controller,
//     String? Function(String)? validator,
//   ) {
//     return SizedBox(
//       width: 400,
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: tdgreen),
//           prefixIcon: Icon(icon, color: Colors.red),
//           enabledBorder: const UnderlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromARGB(255, 199, 4, 69), width: 2),
//           ),
//           focusedBorder: const UnderlineInputBorder(
//             borderSide:
//                 BorderSide(color: Color.fromARGB(255, 26, 82, 10), width: 3),
//           ),
//           errorBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.red, width: 2),
//           ),
//         ),
//         onChanged: (value) {
//           if (validator != null) {
//             final error = validator(value);
//             if (error != null) {}
//           }
//         },
//       ),
//     );
//   }
// }
