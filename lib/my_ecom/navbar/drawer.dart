
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/my_ecom/animations/animation.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  static const Color kGreen = Color.fromARGB(255, 4, 73, 6);

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Drawer(
      backgroundColor: Colors.white,
      width: isTablet ? screenWidth * 0.4 : 304,
      child: FutureBuilder<ShopSettings?>(
        future: ApiService.fetchShopSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: AnimationPage1());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load settings"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No shop settings available"));
          }

          final settings = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                color: kGreen,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(settings.profileImage),
                      radius: isTablet ? 35 : 25,
                    ),
                   
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Welcome to ${settings.name}!",
                        style: GoogleFonts.aBeeZee(
                          fontSize: isTablet ? 22 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation options
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on, color: kGreen),
                      title: Text(
                        "Our Location",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () => _launchUrl(settings.mapLink),
                    ),
                    ListTile(
                      leading: const Icon(Icons.share, color: kGreen),
                      title: Text(
                        "Invite Friends",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () async {
                        await Share.share(
                          settings.message,
                          subject: settings.name,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.web, color: kGreen),
                      title: Text(
                        "Visit Website",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () => _launchUrl(settings.websiteUrl),
                    ),
                    ListTile(
                      leading: const Icon(Icons.call, color: kGreen),
                      title: Text(
                        "24/7 Phone Support",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () => _launchUrl("tel:${settings.phoneNumber}"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat, color: kGreen),
                      title: Text(
                        "24/7 Chat Support",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () => _launchUrl(
                          "https://wa.me/${settings.whatsappNumber}"),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip, color: kGreen),
                      title: Text(
                        "Privacy Policy",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description, color: kGreen),
                      title: Text(
                        "Terms & Conditions",
                        style: TextStyle(fontSize: isTablet ? 19 : 14),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/terms-and-conditions');
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Powered by",
                      style: TextStyle(fontSize: isTablet ? 12 : 10),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      child: Image.network(
                        settings.poweredByImage,
                        height: isTablet ? 60 : 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 40),
                      ),
                      onTap: () => _launchUrl(settings.link),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      settings.poweredByName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 12 : 10,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
