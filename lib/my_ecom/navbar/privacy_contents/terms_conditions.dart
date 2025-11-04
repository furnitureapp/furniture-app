
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:furniture_ecom_app/core/services/marque_policy_terms.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  String? policyContent;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPolicy();
  }

  Future<void> fetchPolicy() async {
    try {
      final content = await MarqueePolicyTermsService.fetchTermsPolicy();
      setState(() {
        policyContent = content;
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
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
              "Terms & Conditions",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.poppins(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    child: policyContent != null
                        ? Html(
                            data: policyContent!,
                            style: {
                              "body": Style(
                                fontSize: FontSize(12.0),
                                color: Colors.black87,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                textAlign: TextAlign.justify,
                              ),
                            },
                          )
                        : Text(
                            "No content available",
                            style: GoogleFonts.poppins(fontSize: 12),
                            textAlign: TextAlign.justify,
                          ),
                  ),
      ),
    );
  }
}
