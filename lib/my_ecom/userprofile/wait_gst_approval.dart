import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/api/api_service_auth.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:furniture_ecom_app/my_login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/colors.dart';
import 'package:furniture_ecom_app/core/api/dealers_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitForGSTApprovalPage extends StatefulWidget {
  const WaitForGSTApprovalPage({super.key});

  @override
  State<WaitForGSTApprovalPage> createState() => _WaitForGSTApprovalPageState();
}

class _WaitForGSTApprovalPageState extends State<WaitForGSTApprovalPage> {
  bool _loading = true;
  bool _rejected = false;
  String _rejectionReason = "";
  Timer? _statusTimer;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();

    _statusTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _checkStatus(),
    );
  }

  Future<void> _checkStatus() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final response = await DealerApiService.getDealerStatus();
      final data = response["data"] as Map<String, dynamic>;

      final bool isApproved = data["isApproved"] == true;
      final bool isRejected = data["isRejected"] == true;

      final rejectionMap = data["rejection"] as Map<String, dynamic>?;
      final String rejectionReason = rejectionMap?["reason"] ?? "";

      if (isApproved || isRejected) {
        _statusTimer?.cancel();
        _statusTimer = null;
      }

      if (!mounted) return;

      setState(() {
        _rejected = isRejected;
        _rejectionReason = rejectionReason;
        _loading = false;
      });

      if (isApproved) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("dealer_pending_approval");

        if (!mounted) return;

        showTopSnackBar(context, "✅ GST Approved! Please login.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyLoginScreen()),
        );
        return;
      }

      if (isRejected && !_dialogShown) {
        _dialogShown = true;
        _showRejectedDialog();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      showTopSnackBar(context, "⏳ GST Verification still pending");
    }
  }

  void _showRejectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("GST Rejected"),
        content: Text(
          _rejectionReason.isEmpty
              ? "No rejection reason provided."
              : _rejectionReason,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // ✅ Close dialog first
              Navigator.pop(context);

              // ✅ Clear pending approval flag
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("dealer_pending_approval");

              // ✅ Navigate to login and clear stack
              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MyLoginScreen()),
                (route) => false,
              );
            },
            child: const Text("OK", style: TextStyle(color: mythemecolor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _checkStatus,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 130),

              Icon(
                Icons.hourglass_bottom_rounded,
                size: isTablet ? 140 : 90,
                color: mythemecolor,
              ),

              const SizedBox(height: 40),

              Text(
                _rejected
                    ? "GST Verification Rejected"
                    : "Kindly wait for GST approval",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 26 : 18,
                  fontWeight: FontWeight.w600,
                  color: mythemecolor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _rejected
                    ? "Please contact support or re-register"
                    : "Once approved, you can proceed to login.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 18 : 14,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 40),

              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: mythemecolor),
                )
              else
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _checkStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Refresh Status",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mythemecolor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove("dealer_pending_approval");
                  await prefs.remove("pending_email"); // optional but safe
                  await ApiAuthService.clearAuthData();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyLoginScreen()),
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Login",
                  style: GoogleFonts.poppins(
                    color: mythemecolor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




  // Future<void> _checkStatus() async {
  //   if (!mounted) return;
  //   setState(() => _loading = true);

  //   try {
  //     final response = await DealerApiService.getDealerStatus();
  //     final data = response["data"];

  //     final bool isApproved = data["isApproved"] == true;
  //     final bool isRejected = data["isRejected"] == true;
  //     final String rejectionReason = data["rejection"]?["reason"] ?? "";

  //     if (!mounted) return;

  //     // ✅ STOP POLLING AS SOON AS FINAL RESULT COMES
  //     if (isApproved || isRejected) {
  //       _statusTimer?.cancel();
  //       _statusTimer = null;
  //     }

  //     setState(() {
  //       _rejected = isRejected;
  //       _rejectionReason = rejectionReason;
  //       _loading = false;
  //     });

  //     // ✅ APPROVED → GO TO LOGIN
  //     if (isApproved) {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.remove("dealer_pending_approval");

  //       // ScaffoldMessenger.of(context).showSnackBar(
  //       //   const SnackBar(content: Text("✅ GST Approved! Please login.")),
  //       // );
  //       showTopSnackBar(context, "✅ GST Approved! Please login.");

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const MyLoginScreen()),
  //       );
  //       return;
  //     }
  //     // ✅ REJECTED → SHOW REASON (ONLY ONCE)
  //     if (isRejected) {
  //       _showRejectedDialog();
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() => _loading = false);

  //     showTopSnackBar(context, "Your GST Verification is Still Pending");
  //   }
  // }