// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
// import 'package:furniture_ecom_app/core/services_ecom/settings_service.dart';
// import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';

// import 'package:google_fonts/google_fonts.dart';

// class BankingInfoPage extends StatefulWidget {
//   const BankingInfoPage({super.key});

//   @override
//   State<BankingInfoPage> createState() => _BankingInfoPageState();
// }

// class _BankingInfoPageState extends State<BankingInfoPage> {
//   ShopSettings? settings;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchBankingInfo();
//   }

//   Future<void> fetchBankingInfo() async {
//     try {
//       final data = await SettingsService.fetchShopSettings();
//       setState(() {
//         settings = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [mythemecolor1, mythemecolor],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             title: const Text(
//               "Banking Information",
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
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: isLoading
//             ? const Center(child: AnimationPage1())
//             : errorMessage != null
//                 ? Center(
//                     child: Text(
//                       errorMessage!,
//                       style: GoogleFonts.poppins(fontSize: 12),
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 : _buildContent(),
//       ),
//     );
//   }
// Widget _buildContent() {
//   final data = settings!;

//   return Container(
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Color(0xFFF6F4F8),
//           Color(0xFFFFFFFF),
//         ],
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//       ),
//     ),
//     child: SingleChildScrollView(
//       padding: const EdgeInsets.only(bottom: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 🔔 NOTE (Premium Info Card)
//           if (data.note.isNotEmpty)
//             _premiumInfoCard(
//               title: "Important Note",
//               child: Html(
//                 data: data.note,
//                 style: {
//                   "body": Style(
//                     fontSize: FontSize(12),
//                     fontFamily: GoogleFonts.poppins().fontFamily,
//                     textAlign: TextAlign.justify,
//                   ),
//                 },
//               ),
//             ),

//           const SizedBox(height: 24),

//           // 💎 HERO QR CARD
//           if (data.qrCode.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28),
//                   gradient: LinearGradient(
//                     colors: [
//                       mythemecolor.withOpacity(0.9),
//                       mythemecolor1.withOpacity(0.9),
//                     ],
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: mythemecolor.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       Text(
//                         "Scan & Pay",
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Image.network(
//                           data.qrCode,
//                           height: 250,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           const SizedBox(height: 32),

//           // 🏦 BANK DETAILS
//           _premiumSection(
//             title: "Bank Details",
//             children: [
//               _iconInfoTile(Icons.phone_android, "GPay Number", data.gpayNumber),
//               _iconInfoTile(Icons.person, "Account Holder", data.accountHolderName),
//               _iconInfoTile(Icons.account_balance, "Account Number", data.accountNumber),
//               _iconInfoTile(Icons.qr_code, "IFSC Code", data.ifscCode),
//               _iconInfoTile(Icons.location_city, "Branch Name", data.branchName),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // 📧 CONTACT INFO
//           _premiumSection(
//             title: "Contact Information",
//             children: [
//               _iconInfoTile(Icons.email, "Email", data.email),
//               _iconInfoTile(Icons.location_on, "Address", data.address),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }


// Widget _premiumInfoCard({required String title, required Widget child}) {
//   return Padding(
//     padding: const EdgeInsets.all(6),
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: mythemecolor,
//               ),
//             ),
//             const SizedBox(height: 8),
//             child,
//           ],
//         ),
//       ),
//     ),
//   );
// }

// Widget _premiumSection({
//   required String title,
//   required List<Widget> children,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: mythemecolor,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 18,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: children),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _iconInfoTile(IconData icon, String label, String value) {
//   if (value.isEmpty) return const SizedBox.shrink();

//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 10),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: mythemecolor.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, size: 20, color: mythemecolor),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.poppins(
//                   fontSize: 11,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// }


import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/core/models_ecom/model_file.dart';
import 'package:furniture_ecom_app/core/services_ecom/settings_service.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:google_fonts/google_fonts.dart';

class BankingInfoPage extends StatefulWidget {
  const BankingInfoPage({super.key});

  @override
  State<BankingInfoPage> createState() => _BankingInfoPageState();
}

class _BankingInfoPageState extends State<BankingInfoPage> {
  ShopSettings? settings;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBankingInfo();
  }

  Future<void> fetchBankingInfo() async {
    try {
      final data = await SettingsService.fetchShopSettings();
      setState(() {
        settings = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
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
              "Banking Information",
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

      body: isLoading
          ? const Center(child: AnimationPage1())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: GoogleFonts.poppins(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 780 : double.infinity,
                    ),
                    child: _buildContent(),
                  ),
                ),
    );
  }

  Widget _buildContent() {
    final data = settings!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF6F4F8),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔔 NOTE
            if (data.note.isNotEmpty)
              _premiumInfoCard(
                title: "Important Note",
                child: Html(
                  data: data.note,
                  style: {
                    "body": Style(
                      fontSize: FontSize(12),
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      textAlign: TextAlign.justify,
                    ),
                  },
                ),
              ),

            const SizedBox(height: 24),

            /// 💎 QR CARD
            if (data.qrCode.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          mythemecolor.withOpacity(0.9),
                          mythemecolor1.withOpacity(0.9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mythemecolor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            "Scan & Pay",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              data.qrCode,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            /// 🏦 BANK DETAILS
            _premiumSection(
              title: "Bank Details",
              children: [
                _iconInfoTile(Icons.phone_android, "GPay Number", data.gpayNumber),
                _iconInfoTile(Icons.person, "Account Holder", data.accountHolderName),
                _iconInfoTile(Icons.account_balance, "Account Number", data.accountNumber),
                _iconInfoTile(Icons.qr_code, "IFSC Code", data.ifscCode),
                _iconInfoTile(Icons.location_city, "Branch Name", data.branchName),
              ],
            ),

            const SizedBox(height: 24),

            /// 📧 CONTACT INFO
            _premiumSection(
              title: "Contact Information",
              children: [
                _iconInfoTile(Icons.email, "Email", data.email),
                _iconInfoTile(Icons.location_on, "Address", data.address),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI HELPERS (UNCHANGED) ----------

  Widget _premiumInfoCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: mythemecolor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconInfoTile(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mythemecolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: mythemecolor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
