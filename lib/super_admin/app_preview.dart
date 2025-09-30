// import 'package:flutter/material.dart';
// import 'package:furniture_ecom_app/constants/colors.dart';
// import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';

// class AppPreview extends StatelessWidget {
//   const AppPreview({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(80.0),
//         child: Container(
//           decoration: const BoxDecoration(
//             color: kPrimaryColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(50),
//               bottomRight: Radius.circular(50),
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Text(
//                 'app preview',
//                 style: AppTextStyles.heading,
//               ),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             centerTitle: true,
//           ),
//         ),
//       ),
//       drawer:const SuperAdminDrawer(currentPage: "App Preview"),
//       body: const Center(
//         child: Text('This is the App Preview screen'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/super_admin/super_admin_home.dart';
import 'package:url_launcher/url_launcher.dart';

class AppPreview extends StatelessWidget {
  const AppPreview({super.key});

  // URL of the app preview
  final String previewUrl = 'https://grocery-ecom-user.vercel.app/myhome';

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(previewUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // If URL cannot be opened
      debugPrint('Could not launch $previewUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'App Preview',
                style: AppTextStyles.heading,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      drawer: const SuperAdminDrawer(currentPage: "App Preview"),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchUrl,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Open App Preview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
