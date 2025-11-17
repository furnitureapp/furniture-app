import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/marketers/gst_api_service.dart';
import 'package:furniture_ecom_app/marketers/marketer_dashboard.dart';
import 'package:furniture_ecom_app/marketers/register_dealer_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';

class GstVerificationPage extends StatefulWidget {
  const GstVerificationPage({super.key});

  @override
  State<GstVerificationPage> createState() => _GstVerificationPageState();
}

class _GstVerificationPageState extends State<GstVerificationPage> {
  final gstController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyGst() async {
    final gstNumber = gstController.text.trim();

    if (gstNumber.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter GST number")));
      return;
    }

    setState(() => isLoading = true);
    final result = await GSTApiService.verifyGst(gstNumber);
    setState(() => isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ GST Verified: ${result['data']['tradeNam']}"),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterDealerPage(gstNumber: gstNumber),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ${result['message']}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
                'GST Verification',
                style: GoogleFonts.poppins(
                  fontSize: 20,
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
      drawer: const MarketerDrawer(currentPage: 'Register Dealer'),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: mythemecolor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/woodpecker_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.25,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      "Enter your GST Number for Verification",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mythemecolor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // GST Field
                    TextField(
                      cursorHeight: 20,
                      cursorColor: mythemecolor,
                      controller: gstController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.numbers,
                          color: mythemecolor,
                        ),
                        hintText: "Enter GST Number",
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Verify Button
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mythemecolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: mythemecolor.withOpacity(0.4),
                          ),
                          onPressed: isLoading ? null : verifyGst,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Verify GST",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
