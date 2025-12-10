// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/core/model/model_file.dart';
// import 'package:furniture_ecom_app/core/services/delivery_service.dart';
// import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/add_delivery_details.dart';
// import 'package:furniture_ecom_app/my_ecom/cart/edituserdetails.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
// import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/order_summary.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// class UpdateAddressScreen extends StatefulWidget {
//   final Product? product;
//   const UpdateAddressScreen({super.key, this.product});

//   @override
//   State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
// }

// class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
//   List<Map<String, dynamic>> _deliveryAddresses = [];
//   String? _selectedAddressId;
//   String? _selecteddealername;
//   String? _selectedPhoneNo;
//   String? _selectedHouseNo;
//   String? _selectedStreetName;
//   String? _selectedCity;
//   String? _selectedState;
//   String? _selectedPinCode;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchSavedAddress();
//     _fetchDeliveryAddresses();
//   }

//   Future<void> _fetchDeliveryAddresses() async {
//     try {
//       List<dynamic> response = await DeliveryService.mygetDeliveryDetails();

//       if (!mounted) return;

//       setState(() {
//         _deliveryAddresses = response.map<Map<String, dynamic>>((item) {
//           return {
//             'id': item['_id']?.toString() ?? '',
//             'dealername': item['dealername'] ?? '',
//             'phoneNo': item['phoneNo']?.toString() ?? '',
//             'houseNo': item['houseNo'] ?? '',
//             'streetName': item['streetName'] ?? '',
//             'city': item['city'] ?? '',
//             'state': item['state'] ?? '',
//             'pinCode': item['pinCode'] ?? '',
//           };
//         }).toList();
//       });

//       print("Updated Addresses: $_deliveryAddresses");

//       if (_deliveryAddresses.isEmpty) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.remove('selectedAddressId');
//         await prefs.remove('selecteddealername');
//         await prefs.remove('selectedPhoneNo');
//         await prefs.remove('selectedHouseNo');
//         await prefs.remove('selectedStreetName');
//         await prefs.remove('selectedCity');
//         await prefs.remove('selectedState');
//         await prefs.remove('selectedPinCode');
//         _clearSelectedAddress();
//         return;
//       }

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       final savedAddressId = prefs.getString('selectedAddressId');
//       bool addressExistsInDb = _deliveryAddresses.any(
//         (address) => address['id'] == savedAddressId,
//       );

//       if (!addressExistsInDb) {
//         print("Saved address not found, clearing preferences.");
//         await prefs.remove('selectedAddressId');
//         await prefs.remove('selecteddealername');
//         await prefs.remove('selectedPhoneNo');
//         await prefs.remove('selectedHouseNo');
//         await prefs.remove('selectedStreetName');
//         await prefs.remove('selectedCity');
//         await prefs.remove('selectedState');
//         await prefs.remove('selectedPinCode');
//         _clearSelectedAddress();
//       } else if (savedAddressId != null) {
//         _onAddressSelected(savedAddressId, saveToPrefs: false);
//       }
//     } catch (e) {
//       if (mounted) {
//         //    ScaffoldMessenger.of(context).showSnackBar(
//         //   SnackBar(
//         //     content: Text( "Please Add Delivery Details!"),
//         //   ),
//         // );
//         showTopSnackBar(context, "Please Add Delivery Details!");
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchSavedAddress() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (!mounted) return;

//     setState(() {
//       _selectedAddressId = prefs.getString('selectedAddressId');
//       _selecteddealername = prefs.getString('selecteddealername');
//       _selectedPhoneNo = prefs.getString('selectedPhoneNo');
//       _selectedHouseNo = prefs.getString('selectedHouseNo');
//       _selectedStreetName = prefs.getString('selectedStreetName');
//       _selectedCity = prefs.getString('selectedCity');
//       _selectedState = prefs.getString('selectedState');
//       _selectedPinCode = prefs.getString('selectedPinCode');
//     });

//     print("Fetched saved address: $_selectedAddressId, $_selecteddealername");
//   }

//   void _clearSelectedAddress() {
//     setState(() {
//       _selectedAddressId = null;
//       _selecteddealername = "No Name Selected";
//       _selectedPhoneNo = "No Phone Selected";
//       _selectedHouseNo = "No House No";
//       _selectedStreetName = "No Street";
//       _selectedCity = "No City";
//       _selectedState = "No State";
//       _selectedPinCode = "No PIN Code";
//     });
//   }

//   Future<void> _onAddressSelected(
//     String addressId, {
//     bool saveToPrefs = true,
//   }) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Map<String, dynamic>? selectedAddress = _deliveryAddresses.firstWhere(
//       (address) => address['id'] == addressId,
//       orElse: () => {},
//     );

//     if (selectedAddress.isNotEmpty) {
//       if (saveToPrefs) {
//         await prefs.setString('selectedAddressId', addressId);
//         await prefs.setString('selecteddealername', selectedAddress['dealername']);
//         await prefs.setString('selectedPhoneNo', selectedAddress['phoneNo']);
//         await prefs.setString('selectedHouseNo', selectedAddress['houseNo']);
//         await prefs.setString(
//           'selectedStreetName',
//           selectedAddress['streetName'],
//         );
//         await prefs.setString('selectedCity', selectedAddress['city']);
//         await prefs.setString('selectedState', selectedAddress['state']);
//         await prefs.setString('selectedPinCode', selectedAddress['pinCode']);
//       }

//       print(
//         "Saved Address: ID: $addressId, Name: ${selectedAddress['dealername']}",
//       );

//       if (!mounted) return;
//       setState(() {
//         _selectedAddressId = addressId;
//         _selecteddealername = selectedAddress['dealername'];
//         _selectedPhoneNo = selectedAddress['phoneNo'];
//         _selectedHouseNo = selectedAddress['houseNo'];
//         _selectedStreetName = selectedAddress['streetName'];
//         _selectedCity = selectedAddress['city'];
//         _selectedState = selectedAddress['state'];
//         _selectedPinCode = selectedAddress['pinCode'];
//       });
//     }
//   }

//   void _editAddress(Map<String, dynamic> address) async {
//     bool? result = await showDialog(
//       context: context,
//       builder: (context) {
//         return EditUserDialog(
//           dealername: address['dealername'],
//           phoneNo: address['phoneNo'],
//           houseNo: address['houseNo'],
//           streetName: address['streetName'],
//           city: address['city'],
//           state: address['state'],
//           pinCode: address['pinCode'],
//           onUpdate:
//               ({
//                 required String updateddealername,
//                 required String updatedPhoneNo,
//                 required String houseNo,
//                 required String streetName,
//                 required String city,
//                 required String state,
//                 required String pinCode,
//               }) async {
//                 await DeliveryService.myupdateDelivery(
//                   deliveryId: address['id'],
//                   phoneNo: updatedPhoneNo,
//                   dealername: updateddealername,
//                   houseNo: houseNo,
//                   streetName: streetName,
//                   city: city,
//                   state: state,
//                   pinCode: pinCode,
//                 );
//                 setState(() {
//                   address['dealername'] = updateddealername;
//                   address['phoneNo'] = updatedPhoneNo;
//                   address['houseNo'] = houseNo;
//                   address['streetName'] = streetName;
//                   address['city'] = city;
//                   address['state'] = state;
//                   address['pinCode'] = pinCode;
//                 });
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.setString('selecteddealername', updateddealername);
//                 await prefs.setString('selectedPhoneNo', updatedPhoneNo);
//                 await prefs.setString('selectedHouseNo', houseNo);
//                 await prefs.setString('selectedStreetName', streetName);
//                 await prefs.setString('selectedCity', city);
//                 await prefs.setString('selectedState', state);
//                 await prefs.setString('selectedPinCode', pinCode);
//                 if (context.mounted) {
//                   Navigator.pop(context, true);
//                 }
//               },
//         );
//       },
//     );

//     if (result == true && mounted) {
//       setState(() {
//         _fetchDeliveryAddresses();
//       });
//       if (_selectedAddressId != null) {
//         _onAddressSelected(_selectedAddressId!);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(kToolbarHeight),
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
//             title: Text(
//               "Update Delivery Details",
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
//       bottomNavigationBar: isTablet
//           ? null
//           : SafeArea(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 color: Colors.white,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     if (_deliveryAddresses.isNotEmpty &&
//                         _deliveryAddresses.length < 5)
//                       Expanded(
//                         child: SizedBox(
//                           height: 40,
//                           child: ElevatedButton.icon(
//                             onPressed: () async {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const AddDeliveryDetailsScreen(),
//                                 ),
//                               );
//                               if (result == true) {
//                                 await _fetchDeliveryAddresses();
//                                 setState(() {});
//                               }
//                             },
//                             icon: const Icon(
//                               Icons.add,
//                               size: 16,
//                               color: Colors.white,
//                             ),
//                             label: const Text(
//                               " ADD ADDRESS",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: mythemecolor1,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: SizedBox(
//                         height: 40,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             await _fetchDeliveryAddresses();
//                             await _fetchSavedAddress();
//                             if (widget.product != null) {
//                               Navigator.pop(context, true);
//                             } else {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       OrderSummary(refresh: true),
//                                 ),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: mythemecolor,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             "CONTINUE",
//                             style: TextStyle(fontSize: 14, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//       body: _isLoading
//           ? const Center(child: AnimationPage1())
//           : RefreshIndicator(
//               onRefresh: () async {
//                 setState(() {
//                   _fetchSavedAddress();
//                   _fetchDeliveryAddresses();
//                 });
//               },
//               color: const Color.fromARGB(255, 13, 75, 15),
//               backgroundColor: const Color.fromARGB(255, 245, 240, 242),
//               displacement: 40,
//               strokeWidth: 2.5,
//               child: _deliveryAddresses.isEmpty
//                   ? Center(
//                       child: SingleChildScrollView(
//                         physics: AlwaysScrollableScrollPhysics(),
//                         child: Card(
//                           elevation: 10,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           margin: EdgeInsets.symmetric(
//                             horizontal: isTablet ? 300 : 30,
//                             vertical: isTablet ? 30 : 60,
//                           ),
//                           child: Container(
//                             padding: EdgeInsets.all(isTablet ? 20 : 20),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               color: isTablet
//                                   ? null
//                                   : const Color.fromARGB(255, 210, 199, 208),
//                               gradient: const LinearGradient(
//                                 colors: [
//                                   Color.fromARGB(255, 249, 254, 222),
//                                   Color.fromARGB(255, 253, 234, 175),
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'No address found. \n Please create a delivery address!',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: isTablet ? 24 : 17,
//                                     fontWeight: FontWeight.bold,
//                                     color: isTablet
//                                         ? const Color.fromARGB(255, 206, 86, 86)
//                                         : const Color.fromARGB(255, 66, 62, 62),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 Image.asset(
//                                   "assets/images/del.png",
//                                   width: double.infinity,
//                                   height: isTablet ? 160 : 130,
//                                 ),
//                                 const SizedBox(height: 10),
//                                 ElevatedButton(
//                                   onPressed: () async {
//                                     final result = await Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             const AddDeliveryDetailsScreen(),
//                                       ),
//                                     );
//                                     if (result == true) {
//                                       await _fetchDeliveryAddresses();
//                                       await _fetchSavedAddress();
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color.fromARGB(
//                                       255,
//                                       254,
//                                       209,
//                                       93,
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 40,
//                                       vertical: 14,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(
//                                         isTablet ? 12 : 0,
//                                       ),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     "Add Delivery Details!",
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: isTablet ? 18 : 16,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     )
//                   : SingleChildScrollView(
//                       physics: AlwaysScrollableScrollPhysics(),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Select an Address:",
//                               style: TextStyle(
//                                 fontSize: isTablet ? 20 : 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: mythemecolor,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             ListView.builder(
//                               shrinkWrap: true,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemCount: _deliveryAddresses.length,
//                               itemBuilder: (context, index) {
//                                 final address = _deliveryAddresses[index];
//                                 final fullAddress =
//                                     '${address['houseNo']}, ${address['streetName']}, ${address['city']}, ${address['state']} - ${address['pinCode']}';

//                                 return Column(
//                                   children: [
//                                     SizedBox(
//                                       width: isTablet ? 1100 : 500,
//                                       child: Card(
//                                         color: Colors.white,
//                                         elevation: 4,
//                                         margin: EdgeInsets.symmetric(
//                                           vertical: isTablet ? 12 : 8,
//                                           horizontal: isTablet ? 8 : 4,
//                                         ),
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             vertical: isTablet ? 12 : 8,
//                                             horizontal: isTablet ? 8 : 4,
//                                           ),
//                                           child: Row(
//                                             children: [
//                                               Radio<String>(
//                                                 value: address['id'],
//                                                 groupValue: _selectedAddressId,
//                                                 onChanged: (String? value) {
//                                                   if (value != null) {
//                                                     _onAddressSelected(value);
//                                                   }
//                                                 },
//                                                 activeColor:
//                                                    mythemecolor,
//                                                 hoverColor:
//                                                   mythemecolor1
//                                               ),
//                                               isTablet
//                                                   ? Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Row(
//                                                             children: [
//                                                               const Icon(
//                                                                 Icons.person,
//                                                                 color:
//                                                                     mythemecolor,
//                                                                 size: 18,
//                                                               ),
//                                                               const SizedBox(
//                                                                 width: 6,
//                                                               ),
//                                                               Text(
//                                                                 address['dealername'],
//                                                                 style: const TextStyle(
//                                                                   fontSize: 15,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                 ),
//                                                               ),
//                                                               const SizedBox(
//                                                                 width: 10,
//                                                               ),
//                                                               const Icon(
//                                                                 Icons.phone,
//                                                                 color:
//                                                                     Color.fromRGBO(
//                                                                       33,
//                                                                       150,
//                                                                       243,
//                                                                       1,
//                                                                     ),
//                                                                 size: 18,
//                                                               ),
//                                                               const SizedBox(
//                                                                 width: 6,
//                                                               ),
//                                                               Text(
//                                                                 address['phoneNo'],
//                                                                 style:
//                                                                     const TextStyle(
//                                                                       fontSize:
//                                                                           15,
//                                                                     ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 8,
//                                                           ),
//                                                           Row(
//                                                             crossAxisAlignment:
//                                                                 CrossAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               const Icon(
//                                                                 Icons
//                                                                     .location_on,
//                                                                 color:
//                                                                     mythemecolor1,
//                                                                 size: 18,
//                                                               ),
//                                                               const SizedBox(
//                                                                 width: 6,
//                                                               ),
//                                                               Expanded(
//                                                                 child: Text(
//                                                                   fullAddress,
//                                                                   style: const TextStyle(
//                                                                     fontSize:
//                                                                         15,
//                                                                     color: Colors
//                                                                         .black87,
//                                                                   ),
//                                                                   maxLines: 5,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     )
//                                                   : Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               Expanded(
//                                                                 child: Text(
//                                                                   address['dealername'],
//                                                                   style: const TextStyle(
//                                                                     fontSize:
//                                                                         14,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold,
//                                                                     color: Colors
//                                                                         .black87,
//                                                                   ),
//                                                                   maxLines: 1,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                               ),
//                                                               IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                       Icons
//                                                                           .edit,
//                                                                     ),
//                                                                 iconSize: 20,
//                                                                 onPressed: () =>
//                                                                     _editAddress(
//                                                                       address,
//                                                                     ),
//                                                                 color:
//                                                                     mythemecolor,
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 4,
//                                                           ),
//                                                           Text(
//                                                             address['phoneNo'],
//                                                             style:
//                                                                 const TextStyle(
//                                                                   fontSize: 14,
//                                                                   color: Colors
//                                                                       .black87,
//                                                                 ),
//                                                             maxLines: 1,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                           const SizedBox(
//                                                             height: 4,
//                                                           ),
//                                                           Text(
//                                                             fullAddress,
//                                                             style:
//                                                                 const TextStyle(
//                                                                   fontSize: 14,
//                                                                   color: Colors
//                                                                       .black87,
//                                                                 ),
//                                                             maxLines: 5,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                               if (isTablet)
//                                                 Container(
//                                                   decoration: BoxDecoration(
//                                                     gradient:
//                                                         const LinearGradient(
//                                                           colors: [
//                                                             Color.fromARGB(
//                                                               255,
//                                                               97,
//                                                               217,
//                                                               244,
//                                                             ),
//                                                             Color(0xFF0083B0),
//                                                           ],
//                                                           begin:
//                                                               Alignment.topLeft,
//                                                           end: Alignment
//                                                               .bottomRight,
//                                                         ),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           isTablet ? 12 : 10,
//                                                         ),
//                                                   ),
//                                                   child: ElevatedButton.icon(
//                                                     onPressed: () =>
//                                                         _editAddress(address),
//                                                     style: ElevatedButton.styleFrom(
//                                                       backgroundColor:
//                                                           Colors.transparent,
//                                                       shadowColor:
//                                                           Colors.transparent,
//                                                       minimumSize: Size(
//                                                         isTablet ? 200 : 100,
//                                                         isTablet ? 48 : 24,
//                                                       ),
//                                                       padding: isTablet
//                                                           ? const EdgeInsets.symmetric(
//                                                               vertical: 12,
//                                                               horizontal: 16,
//                                                             )
//                                                           : const EdgeInsets.all(
//                                                               4,
//                                                             ),
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                               isTablet ? 12 : 6,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                     icon: Icon(
//                                                       Icons.edit_location_alt,
//                                                       color: Colors.white,
//                                                       size: isTablet ? 20 : 16,
//                                                     ),
//                                                     label: Text(
//                                                       isTablet
//                                                           ? "Edit Delivery Details"
//                                                           : "Edit",
//                                                       style: TextStyle(
//                                                         fontSize: isTablet
//                                                             ? 16
//                                                             : 14,
//                                                         color: Colors.white,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                             const SizedBox(height: 5),
//                             if (_selectedAddressId != null) ...[
//                               isTablet
//                                   ? Padding(
//                                       padding: const EdgeInsets.fromLTRB(
//                                         20,
//                                         5,
//                                         20,
//                                         20,
//                                       ),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             width: 600,
//                                             child: Card(
//                                               color: const Color.fromARGB(
//                                                 255,
//                                                 233,
//                                                 241,
//                                                 248,
//                                               ),
//                                               elevation: 10,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               margin: const EdgeInsets.all(8),
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(
//                                                   10,
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         const Icon(
//                                                           Icons.location_on,
//                                                           color:
//                                                               mythemecolor,
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 8,
//                                                         ),
//                                                         const Text(
//                                                           "Selected Address",
//                                                           style: TextStyle(
//                                                             fontSize: 18,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color:mythemecolor,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     const Divider(
//                                                       thickness: 1,
//                                                       color: Colors.grey,
//                                                     ),
//                                                     const SizedBox(height: 10),
//                                                     Text(
//                                                       "Name     : ${_selecteddealername ?? ''}",
//                                                       style: const TextStyle(
//                                                         fontSize: 18,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black87,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "Phone      : ${_selectedPhoneNo ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "House No : ${_selectedHouseNo ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "Street     : ${_selectedStreetName ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "City         : ${_selectedCity ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "State      : ${_selectedState ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 6),
//                                                     Text(
//                                                       "PIN Code : ${_selectedPinCode ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Column(
//                                             children: [
//                                               if (_deliveryAddresses
//                                                       .isNotEmpty &&
//                                                   _deliveryAddresses.length < 5)
//                                                 SizedBox(
//                                                   width: 160,
//                                                   child: ElevatedButton.icon(
//                                                     onPressed: () async {
//                                                       final result =
//                                                           await Navigator.push(
//                                                             context,
//                                                             MaterialPageRoute(
//                                                               builder: (context) =>
//                                                                   const AddDeliveryDetailsScreen(),
//                                                             ),
//                                                           );
//                                                       if (result == true) {
//                                                         await _fetchDeliveryAddresses();
//                                                         setState(() {});
//                                                       }
//                                                     },
//                                                     icon: const Icon(
//                                                       Icons.add,
//                                                       size: 20,
//                                                       color: Colors.white,
//                                                     ),
//                                                     label: const Text(
//                                                       "mythemecolorress",
//                                                       style: TextStyle(
//                                                         color: Colors.white,
//                                                       ),
//                                                     ),
//                                                     style: ElevatedButton.styleFrom(
//                                                       padding:
//                                                           const EdgeInsets.symmetric(
//                                                             vertical: 18,
//                                                           ),
//                                                       backgroundColor:
//                                                           const Color.fromARGB(
//                                                             255,
//                                                             0,
//                                                             148,
//                                                             211,
//                                                           ),
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.circular(
//                                                               12,
//                                                             ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               const SizedBox(height: 16),
//                                               SizedBox(
//                                                 width: 160,
//                                                 child: ElevatedButton(
//                                                   onPressed: () async {
//                                                     await _fetchDeliveryAddresses();
//                                                     await _fetchSavedAddress();

//                                                     if (widget.product !=
//                                                         null) {
//                                                       Navigator.pushReplacement(
//                                                         context,
//                                                         MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               OrderConfirmationPage(
//                                                                 product: widget
//                                                                     .product!,
//                                                                 refresh: true,
//                                                               ),
//                                                         ),
//                                                       );
//                                                     } else {
//                                                       Navigator.pop(
//                                                         context,
//                                                         true,
//                                                       );
//                                                     }
//                                                   },
//                                                   style: ElevatedButton.styleFrom(
//                                                     padding:
//                                                         const EdgeInsets.symmetric(
//                                                           vertical: 18,
//                                                         ),
//                                                     backgroundColor:
//                                                         Colors.green,
//                                                     shape: RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                             12,
//                                                           ),
//                                                     ),
//                                                   ),
//                                                   child: const Text(
//                                                     "CONTINUE",
//                                                     style: TextStyle(
//                                                       fontSize: 16,
//                                                       color: Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   : Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           SizedBox(
//                                             width: double.infinity,
//                                             child: Card(
//                                               color: const Color.fromARGB(
//                                                 255,
//                                                 233,
//                                                 241,
//                                                 248,
//                                               ),
//                                               elevation: 10,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                               margin: const EdgeInsets.only(
//                                                 bottom: 12,
//                                               ),
//                                               child: Padding(
//                                                 padding: const EdgeInsets.all(
//                                                   12,
//                                                 ),
//                                                 child: Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: [
//                                                     Row(
//                                                       children: [
//                                                         const Icon(
//                                                           Icons.location_on,
//                                                           color:
//                                                               mythemecolor,
//                                                           size: 20,
//                                                         ),
//                                                         const SizedBox(
//                                                           width: 6,
//                                                         ),
//                                                         const Text(
//                                                           "Selected Address",
//                                                           style: TextStyle(
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             color: mythemecolor,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     const Divider(
//                                                       thickness: 1,
//                                                       color: Colors.grey,
//                                                     ),
//                                                     const SizedBox(height: 8),
//                                                     Text(
//                                                       "Name: ${_selecteddealername ?? ''}",
//                                                       style: const TextStyle(
//                                                         fontSize: 16,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.black87,
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "Phone: ${_selectedPhoneNo ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "House No: ${_selectedHouseNo ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "Street: ${_selectedStreetName ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "City: ${_selectedCity ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "State: ${_selectedState ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                     ),
//                                                     const SizedBox(height: 4),
//                                                     Text(
//                                                       "PIN Code: ${_selectedPinCode ?? ''}",
//                                                       style: TextStyle(
//                                                         fontSize: 14,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         color: Colors.grey[800],
//                                                       ),
//                                                       maxLines: 1,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 16),
//                                         ],
//                                       ),
//                                     ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/del_address_provider.dart';
import 'package:provider/provider.dart';

import 'package:furniture_ecom_app/core/services/delivery_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/cart/add_delivery_details.dart';
import 'package:furniture_ecom_app/my_ecom/cart/edituserdetails.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/order_confirmationpage.dart';
// import 'package:furniture_ecom_app/my_ecom/orders/order_summary.dart';

class UpdateAddressScreen extends StatefulWidget {
  final dynamic product;
  const UpdateAddressScreen({super.key, this.product});

  @override
  State<UpdateAddressScreen> createState() => _UpdateAddressScreenState();
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  List<Map<String, dynamic>> _deliveryAddresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryAddresses();
  }

  Future<void> _fetchDeliveryAddresses() async {
    final addressProvider = context.read<SelectedAddressProvider>();

    try {
      final response = await DeliveryService.mygetDeliveryDetails();
      if (!mounted) return;

      // 1️⃣ Build fresh address list
      _deliveryAddresses = response.map<Map<String, dynamic>>((item) {
        return {
          'id': item['_id'],
          'dealername': item['dealername'],
          'phoneNo': item['phoneNo'],
          'houseNo': item['houseNo'],
          'streetName': item['streetName'],
          'city': item['city'],
          'state': item['state'],
          'pinCode': item['pinCode'],
        };
      }).toList();

      // 2️⃣ Clear provider if selected address was deleted
      if (addressProvider.selectedAddress != null) {
        final exists = _deliveryAddresses.any(
          (a) => a['id'] == addressProvider.selectedAddressId,
        );

        if (!exists) {
          addressProvider.clear();
        }
        // 3️⃣ ✅ Re-sync provider with fresh list (THIS GOES HERE)
        else {
          final match = _deliveryAddresses.firstWhere(
            (a) => a['id'] == addressProvider.selectedAddressId,
            orElse: () => {},
          );

          if (match.isNotEmpty) {
            addressProvider.setAddress(match);
          }
        }
      }

      // 4️⃣ Rebuild UI
      setState(() {});
    } catch (e) {
      showTopSnackBar(context, "Please add delivery details!");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onAddressSelected(String id) {
    final address = _deliveryAddresses.firstWhere((a) => a['id'] == id);
    context.read<SelectedAddressProvider>().setAddress(address);
  }

  void _editAddress(Map<String, dynamic> address) async {
    bool? updated = await showDialog(
      context: context,
      builder: (_) => EditUserDialog(
        dealername: address['dealername'],
        phoneNo: address['phoneNo'],
        houseNo: address['houseNo'],
        streetName: address['streetName'],
        city: address['city'],
        state: address['state'],
        pinCode: address['pinCode'],
        onUpdate:
            ({
              required String updateddealername,
              required String updatedPhoneNo,
              required String houseNo,
              required String streetName,
              required String city,
              required String state,
              required String pinCode,
            }) async {
              await DeliveryService.myupdateDelivery(
                deliveryId: address['id'],
                dealername: updateddealername,
                phoneNo: updatedPhoneNo,
                houseNo: houseNo,
                streetName: streetName,
                city: city,
                state: state,
                pinCode: pinCode,
              );

              address
                ..['dealername'] = updateddealername
                ..['phoneNo'] = updatedPhoneNo
                ..['houseNo'] = houseNo
                ..['streetName'] = streetName
                ..['city'] = city
                ..['state'] = state
                ..['pinCode'] = pinCode;

              context.read<SelectedAddressProvider>().setAddress(address);
              Navigator.pop(context, true);
            },
      ),
    );

    if (updated == true) _fetchDeliveryAddresses();
  }

  
  void _continue() {
  Navigator.pop(context, true);
}


// void _continue() {
  //   if (widget.product != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) =>
  //             OrderConfirmationPage(product: widget.product, refresh: true),
  //       ),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => OrderSummary(refresh: true)),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final selectedAddress = context
        .watch<SelectedAddressProvider>()
        .selectedAddress;

    // Reserve enough space for bottom button if visible
    final bottomSpace = selectedAddress == null ? 12.0 : 90.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Delivery Details"),
        backgroundColor: mythemecolor,
        centerTitle: true,
      ),

      /// ✅ CONTINUE BUTTON
      bottomNavigationBar: selectedAddress == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mythemecolor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

      body: _isLoading
          ? const Center(child: AnimationPage1())
          : _deliveryAddresses.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddDeliveryDetailsScreen(),
                    ),
                  );
                  if (res == true) _fetchDeliveryAddresses();
                },
                child: const Text("Add Delivery Address"),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, bottomSpace),
              itemCount:
                  _deliveryAddresses.length +
                  (_deliveryAddresses.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
                // ✅ ADD ADDRESS FOOTER
                if (index == _deliveryAddresses.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddDeliveryDetailsScreen(),
                            ),
                          );
                          if (res == true) _fetchDeliveryAddresses();
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Add Delivery Address",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mythemecolor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  );
                }

                final a = _deliveryAddresses[index];
                final isSelected = selectedAddress?['id'] == a['id'];

                return Card(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  elevation: isSelected ? 6 : 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Radio(
                      value: a['id'],
                      groupValue: selectedAddress?['id'],
                      onChanged: (_) => _onAddressSelected(a['id']),
                    ),
                    title: Text(
                      a['dealername'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? mythemecolor : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "${a['houseNo']}, ${a['streetName']}, ${a['city']} - ${a['pinCode']}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: mythemecolor),
                      onPressed: () => _editAddress(a),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
