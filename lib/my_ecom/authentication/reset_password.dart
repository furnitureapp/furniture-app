
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:furniture_ecom_app/core/services/auth_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/login_user.dart';
import 'package:furniture_ecom_app/my_ecom/my_constants/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreen();
}

class _ResetPasswordScreen extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newpassController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();

  bool _isLoading = false;
  bool _hideNewPass = true;
  bool _hideConfirmPass = true;

  final _formKey = GlobalKey<FormState>();

  late Timer _timer;
  int _remainingTime = 180;
  bool _showOtpTimer = true;

  @override
  void initState() {
    super.initState();
    _startOtpTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startOtpTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showOtpTimer = false;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.forgotPassword(widget.email);

      if (response['success'] == true) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('OTP has been resent!')),
        // );

        showTopSnackBar(context, 'OTP has been resent!');
        _otpController.clear();
        _newpassController.clear();
        _confirmpassController.clear();

        setState(() {
          _remainingTime = 180;
          _showOtpTimer = true;
        });
        _startOtpTimer(); // Restart timer
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text(response['message'] ?? 'Failed to resend OTP.')),
        // );
        showTopSnackBar(
            context, response['message'] ?? 'Failed to resend OTP.');
      }
    } catch (e) {
      log("Resend OTP error: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Error while resending OTP')),
      // );
      showTopSnackBar(context, 'Error while resending OTP');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPass() async {
    if (_remainingTime <= 0) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //       content: Text('OTP has expired. Please request a new one.')),
      // );
      showTopSnackBar(context, 'OTP has expired. Please request a new one.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.resetPassword(
        _otpController.text.trim(),
        _newpassController.text.trim(),
        _confirmpassController.text.trim(),
      );

      log('Response: $response');

      if (response['success'] == true) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Your password has been reset!')),
        // );
        showTopSnackBar(context, 'Your password has been reset!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        showTopSnackBar(context, response['message'] ?? "Reset Failed!");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(response['message'] ?? "Reset Failed!")),
        // );
      }
    } catch (e) {
      log('Reset error: $e');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Error occurred during reset')),
      // );
      showTopSnackBar(context, 'Error occurred during reset');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    bool isHidden = true,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: Color.fromARGB(255, 26, 99, 91), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 26, 99, 91)),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isHidden ? Icons.visibility_off : Icons.visibility,
                color: const Color.fromARGB(255, 104, 103, 103),
              ),
              onPressed: toggleVisibility,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color.fromARGB(255, 26, 99, 91), width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Color.fromARGB(255, 26, 99, 91), width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

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
            title: const Text("Reset Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                )),
            centerTitle: true,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bbc.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 50 : 30, vertical: 50),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    color: const Color.fromARGB(255, 249, 252, 249),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      width: isTablet ? 400 : double.infinity,
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text('OTP has been sent to:',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 5),
                            Text(widget.email,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal,
                                ),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 10),
                            _showOtpTimer
                                ? Text(
                                    'OTP expires in ${_formatTime(_remainingTime)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 8, 97, 88),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    'OTP has expired! \n Please request a new one.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center),
                            if (!_showOtpTimer)
                              TextButton(
                                onPressed: _isLoading ? null : _resendOtp,
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _otpController,
                              enabled: _remainingTime > 0,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 8, 63, 17),
                                letterSpacing: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: _inputDecoration(
                                label: "Enter OTP",
                                icon: Icons.password,
                              ).copyWith(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                              ),
                              textAlign: TextAlign.center,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "OTP is required";
                                }
                                if (value.length != 6) {
                                  return "Enter a valid 6-digit OTP";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _newpassController,
                              obscureText: _hideNewPass,
                              decoration: _inputDecoration(
                                label: "New Password",
                                icon: Icons.lock,
                                isPassword: true,
                                toggleVisibility: () {
                                  setState(() {
                                    _hideNewPass = !_hideNewPass;
                                  });
                                },
                                isHidden: _hideNewPass,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "New password is required";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _confirmpassController,
                              obscureText: _hideConfirmPass,
                              decoration: _inputDecoration(
                                label: "Confirm Password",
                                icon: Icons.lock,
                                isPassword: true,
                                toggleVisibility: () {
                                  setState(() {
                                    _hideConfirmPass = !_hideConfirmPass;
                                  });
                                },
                                isHidden: _hideConfirmPass,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please confirm password";
                                }
                                if (value != _newpassController.text) {
                                  return "Passwords do not match";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 25),
                            _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.green)
                                : ElevatedButton(
                                    onPressed: _resetPass,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 92, 174, 92),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 50 : 30,
                                        vertical: isTablet ? 20 : 10,
                                      ),
                                      textStyle: TextStyle(
                                        fontSize: isTablet ? 20 : 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('RESET'),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
