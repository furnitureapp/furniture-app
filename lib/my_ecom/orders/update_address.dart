import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/del_address_provider.dart';
import 'package:provider/provider.dart';

import 'package:furniture_ecom_app/core/services_ecom/delivery_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/cart/add_delivery_details.dart';
import 'package:furniture_ecom_app/my_ecom/cart/edituserdetails.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';

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

      if (addressProvider.selectedAddress != null) {
        final exists = _deliveryAddresses.any(
          (a) => a['id'] == addressProvider.selectedAddressId,
        );

        if (!exists) {
          addressProvider.clear();
        } else {
          final match = _deliveryAddresses.firstWhere(
            (a) => a['id'] == addressProvider.selectedAddressId,
            orElse: () => {},
          );

          if (match.isNotEmpty) {
            addressProvider.setAddress(match);
          }
        }
      }

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

  String capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final selectedAddress = context
        .watch<SelectedAddressProvider>()
        .selectedAddress;


    return Scaffold(
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
              "Update Delivery Details",
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
      backgroundColor: const Color.fromARGB(255, 241, 224, 230),
      bottomNavigationBar: selectedAddress == null
          ? null
          : 
           Padding(
             padding: const EdgeInsets.only(bottom: 60,left: 80, right: 80),
             child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mythemecolor,
                    padding: const EdgeInsets.all(10),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      
                    ),
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("CONTINUE"),
                ),
           ),
    

      body: _isLoading
          ? const Center(child: AnimationPage1())
          : _deliveryAddresses.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 20 : 20),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 30 : 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: mythemecolor1.withOpacity(0.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/bab.png',
                          height: 210,
                          width: 190,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Please Add Delivery Details!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Right Product at Right Time for YOU!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AddDeliveryDetailsScreen(),
                              ),
                            );
                            if (res == true) _fetchDeliveryAddresses();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTablet
                                ? Colors.white
                                : mythemecolor,
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 30,
                              vertical: isTablet ? 14 : 12,
                            ),
                            textStyle: TextStyle(
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                            foregroundColor: isTablet
                                ? mythemecolor
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("ADD ADDRESS DETAILS"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : isTablet
          ? ListView.builder(
              padding: EdgeInsets.all(40),
              itemCount:
                  _deliveryAddresses.length +
                  (_deliveryAddresses.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _deliveryAddresses.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AddDeliveryDetailsScreen(),
                              ),
                            );
                            if (res == true) _fetchDeliveryAddresses();
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'ADD DELIVERY DETAILS',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mythemecolor,
                            padding: const EdgeInsets.all(18),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final a = _deliveryAddresses[index];
                final isSelected = selectedAddress?['id'] == a['id'];

                return Card(
                  color: isSelected ? Colors.purple.shade50 : Colors.white,
                  elevation: isSelected ? 6 : 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Radio(
                      value: a['id'],
                      groupValue: selectedAddress?['id'],
                      onChanged: (_) => _onAddressSelected(a['id']),
                    ),
                    title: Text(
                      capitalizeFirst(a['dealername'] ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? mythemecolor : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "${capitalizeFirst(a['houseNo'] ?? '')}, "
                      "${capitalizeFirst(a['streetName'] ?? '')}, "
                      "${capitalizeFirst(a['city'] ?? '')} - ${a['pinCode'] ?? ''}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: mythemecolor),
                      onPressed: () => _editAddress(a),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount:
                  _deliveryAddresses.length +
                  (_deliveryAddresses.length < 5 ? 1 : 0),
              itemBuilder: (context, index) {
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
                          padding: const EdgeInsets.all(10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final a = _deliveryAddresses[index];
                final isSelected = selectedAddress?['id'] == a['id'];

                return Card(
                  color: isSelected ? Colors.purple.shade50 : Colors.white,
                  elevation: isSelected ? 6 : 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Radio(
                      value: a['id'],
                      groupValue: selectedAddress?['id'],
                      onChanged: (_) => _onAddressSelected(a['id']),
                    ),
                    title: Text(
                      capitalizeFirst(a['dealername'] ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? mythemecolor : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "${capitalizeFirst(a['houseNo'] ?? '')}, "
                      "${capitalizeFirst(a['streetName'] ?? '')}, "
                      "${capitalizeFirst(a['city'] ?? '')} - ${a['pinCode'] ?? ''}",
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