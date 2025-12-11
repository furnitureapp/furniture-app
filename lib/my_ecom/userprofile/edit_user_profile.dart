import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/user_service.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class EditUserProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditUserProfilePage({super.key, required this.userData});

  @override
  State<EditUserProfilePage> createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    emailController.text = widget.userData["email"] ?? "";
    companyController.text = widget.userData["companyName"] ?? "";
    usernameController.text = widget.userData["username"] ?? "";
    phoneController.text = widget.userData["phoneNumber"] ?? "";
    addressController.text = widget.userData["address"] ?? "";
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    final result = await UserService.updateDealer(
      dealerId: widget.userData["_id"],
      phoneNumber: phoneController.text.trim(),
      address: addressController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"] ?? "Update failed"),
        backgroundColor: result["success"] ? mythemecolor : mythemecolor1,
      ),
    );

    if (result["success"]) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 221, 197, 251),
                Colors.white,
                Color.fromARGB(255, 221, 197, 251),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: mythemecolor),
            title: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Edit User Profile',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 26 : 14,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: isTablet
          ? TabletEditUserProfileLayout(
              emailController: emailController,
              companyController: companyController,
              usernameController: usernameController,
              phoneController: phoneController,
              addressController: addressController,
              isLoading: isLoading,
              updateProfile: updateProfile,
            )
          : PhoneEditUserProfileLayout(
              emailController: emailController,
              companyController: companyController,
              usernameController: usernameController,
              phoneController: phoneController,
              addressController: addressController,
              isLoading: isLoading,
              updateProfile: updateProfile,
            ),
    );
  }
}

class PhoneEditUserProfileLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController companyController;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  final bool isLoading;
  final Function updateProfile;

  const PhoneEditUserProfileLayout({
    super.key,
    required this.emailController,
    required this.companyController,
    required this.usernameController,
    required this.phoneController,
    required this.addressController,
    required this.isLoading,
    required this.updateProfile,
  });

  Widget buildReadOnlyField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromARGB(255, 240, 225, 237),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: mythemecolor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: mythemecolor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          buildReadOnlyField("Email", emailController),
          buildReadOnlyField("Company Name", companyController),
          buildReadOnlyField("Username", usernameController),

          buildEditableField("Phone Number", phoneController),
          buildEditableField("Address", addressController, maxLines: 3),

          const SizedBox(height: 25),

          SizedBox(
            width: 150,
            height: 55,
            child: ElevatedButton(
              
              style: ElevatedButton.styleFrom(backgroundColor: mythemecolor,),
              onPressed: isLoading ? null : () => updateProfile(),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Save Changes",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class TabletEditUserProfileLayout extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController companyController;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  final bool isLoading;
  final Function updateProfile;

  const TabletEditUserProfileLayout({
    super.key,
    required this.emailController,
    required this.companyController,
    required this.usernameController,
    required this.phoneController,
    required this.addressController,
    required this.isLoading,
    required this.updateProfile,
  });

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? const Color.fromARGB(255, 240, 225, 237)
                : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                buildField("Email", emailController, readOnly: true),
                const SizedBox(height: 20),
                buildField("Company Name", companyController, readOnly: true),
                const SizedBox(height: 20),
                buildField("Username", usernameController, readOnly: true),
              ],
            ),
          ),

          const SizedBox(width: 40),

          Expanded(
            child: Column(
              children: [
                buildField("Phone Number", phoneController),
                const SizedBox(height: 20),
                buildField("Address", addressController, maxLines: 3),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mythemecolor,
                    ),
                    onPressed: isLoading ? null : () => updateProfile(),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
