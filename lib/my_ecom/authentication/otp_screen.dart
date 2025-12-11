import 'dart:async';
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/auth_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/provider/login_provider.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/my_ecom/navbar/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String redirectRoute;
  final String? productId;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.redirectRoute,
    this.productId,
  });

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otp = '';
  bool _isLoading = false;
  bool _isResending = false;
  bool _canResend = true;
  bool _otpError = false;
  String _message = '';
  String userEmail = '';

  Timer? _countdownTimer;
  int _remainingTime = 300;
  bool _showOtpTimer = true;

  int _resendCountdown = 0;
  Timer? _resendTimer;

  Future<void> _fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('user_email');
    setState(() {
      userEmail = email ?? 'Error: Email not found, please log in again.';
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _navigateAfterOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final redirectRoute = prefs.getString('redirectRoute');
    final String? productId = prefs.getString('productId');

    if (redirectRoute == '/product/:productId' && productId != null) {
      Navigator.pushReplacementNamed(
        context,
        '/productdetailpagep',
        arguments: productId,
      );
      prefs.remove('redirectRoute');
      prefs.remove('productId');
      return;
    }

    if (redirectRoute == '/cart') {
      Navigator.pushReplacementNamed(context, '/cart');
      prefs.remove('redirectRoute');
      return;
    }
    if (redirectRoute == '/notification') {
      Navigator.pushNamedAndRemoveUntil(
          context, '/notification', (route) => false);

      prefs.remove('redirectRoute');

      return;
    }
    if (redirectRoute == '/wishlist') {
      Navigator.pushReplacementNamed(
        context,
        '/wishlist',
      );
      prefs.remove('redirectRoute');
      return;
    }
    if (redirectRoute == '/myorders') {
      Navigator.pushReplacementNamed(
        context,
        '/myorders',
      );
      prefs.remove('redirectRoute');
      return;
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/myhome',
        (route) => false,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      setState(() {
        _message = 'Please enter a valid 6-digit OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _otpError = false;
    });

    try {
      final result = await ApiService.verifyOtp(userEmail, _otp);

      if (result['message'] == 'OTP verified successfully') {
        _countdownTimer?.cancel();

        if (result['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('auth_token', result['token']);
          Provider.of<LoginProvider>(context, listen: false).setLogin(true);
        }

        if (mounted) {
          _navigateAfterOtp();
        }
      } else {
        setState(() {
          _message = result['message'] ?? 'OTP verification failed';
          _otpError = true;
          _showOtpTimer = false;
        });
        _countdownTimer?.cancel();
      }
    } catch (error) {
      setState(() {
        _message = 'Invalid OTP! Please check your registered Email!';
        _otpError = true;
        _showOtpTimer = false;
      });
      _countdownTimer?.cancel();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startCountdown({int seconds = 300}) {
    _countdownTimer?.cancel();
    setState(() {
      _remainingTime = seconds;
      _showOtpTimer = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        timer.cancel();
        setState(() {
          _message = 'OTP has expired!\nPlease request a new one!';
          _otpError = true;
          _showOtpTimer = false;
        });
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    setState(() {
      _isResending = true;
      _message = '';
      _canResend = false;
      _otpError = false;
      _startCountdown(seconds: 180);
    });

    try {
      final result = await ApiService.resendOtp(userEmail);
      setState(() {
        _message = result['message'];
      });

      if (result['message'].toLowerCase().contains('otp sent')) {
        setState(() {
          _resendCountdown = 30;
        });

        _resendTimer?.cancel();
        _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCountdown == 0) {
            timer.cancel();
            if (mounted) {
              setState(() {
                _canResend = true;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _resendCountdown--;
              });
            }
          }
        });
      }
    } catch (error) {
      setState(() {
        _message = 'Failed to resend OTP. Please try again later.';
      });
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _startCountdown(seconds: 300);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  mythemecolor1,
               mythemecolor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const BottomNavBar()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            title: Text(
              "Verify your OTP",
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/theme.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                color: Colors.white.withOpacity(0.75),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: isTablet ? 400 : double.infinity,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'OTP has been sent to Email',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      if (_showOtpTimer)
                        Text(
                          'OTP will expire in ${_formatTime(_remainingTime)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 8, 97, 88),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 20),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          fieldHeight: isTablet ? 60 : 45,
                          fieldWidth: isTablet ? 50 : 33,
                          activeFillColor: Colors.white,
                          inactiveFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveColor:
                              const Color.fromARGB(255, 120, 119, 119),
                          selectedColor: const Color.fromARGB(255, 8, 97, 88),
                          activeColor: const Color.fromARGB(255, 8, 97, 88),
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                        cursorColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            _otp = value;
                            _otpError = false;
                          });
                        },
                        onCompleted: (value) {
                          setState(() {
                            _otp = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_message.isNotEmpty)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              _message,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _message.contains('success')
                                    ? Colors.teal
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      if (!_otpError)
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: mythemecolor)
                            : ElevatedButton(
                                onPressed: _verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Verify OTP'),
                              ),
                      if (_otpError)
                        ElevatedButton(
                          onPressed: _canResend ? _resendOtp : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _canResend ? "Resend OTP" : "Please Wait.."),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



  // body: SafeArea(
      //   child: Container(
      //     decoration: const BoxDecoration(
      //       image: DecorationImage(
      //         image: AssetImage('assets/images/theme.png'),
      //         fit: BoxFit.cover,
      //       ),
      //     ),
      //     child: SizedBox.expand(
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(horizontal: isTablet ? 50 : 30),
      //         child: SingleChildScrollView(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             children: [
      //               const SizedBox(height: 120),
      //               Card(
      //                 color: Colors.white.withOpacity(0.75),
      //                 elevation: 8,
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(20),
      //                 ),
      //                 child: Container(
      //                   width: isTablet ? 400 : double.infinity,
      //                   padding: const EdgeInsets.all(30),
      //                   child: Column(
      //                     children: [
      //                       Text(
      //                         'OTP has been sent to Email',
      //                         style: GoogleFonts.poppins(
      //                           fontSize: 16,
      //                           color: Colors.grey[700],
      //                         ),
      //                         textAlign: TextAlign.center,
      //                       ),
      //                       const SizedBox(height: 5),
      //                       Text(
      //                         userEmail,
      //                         style: GoogleFonts.poppins(
      //                           fontSize: 14,
      //                           fontWeight: FontWeight.w500,
      //                           color: Colors.teal,
      //                         ),
      //                         textAlign: TextAlign.center,
      //                       ),
      //                       const SizedBox(height: 20),
      //                       if (_showOtpTimer)
      //                         Text(
      //                           'OTP will expire in ${_formatTime(_remainingTime)}',
      //                           style: const TextStyle(
      //                             fontSize: 14,
      //                             color: Color.fromARGB(255, 8, 97, 88),
      //                             fontWeight: FontWeight.bold,
      //                           ),
      //                         ),
      //                       const SizedBox(height: 20),
      //                       PinCodeTextField(
      //                         appContext: context,
      //                         length: 6,
      //                         obscureText: false,
      //                         animationType: AnimationType.fade,
      //                         keyboardType: TextInputType.number,
      //                         pinTheme: PinTheme(
      //                           shape: PinCodeFieldShape.box,
      //                           borderRadius: BorderRadius.circular(8),
      //                           fieldHeight: isTablet ? 60 : 45,
      //                           fieldWidth: isTablet ? 50 : 33,
      //                           activeFillColor: Colors.white,
      //                           inactiveFillColor: Colors.white,
      //                           selectedFillColor: Colors.white,
      //                           inactiveColor:
      //                               const Color.fromARGB(255, 120, 119, 119),
      //                           selectedColor: Color.fromARGB(255, 8, 97, 88),
      //                           activeColor: Color.fromARGB(255, 8, 97, 88),
      //                         ),
      //                         animationDuration:
      //                             const Duration(milliseconds: 300),
      //                         enableActiveFill: true,
      //                         cursorColor: Colors.black,
      //                         onChanged: (value) {
      //                           setState(() {
      //                             _otp = value;
      //                             _otpError = false;
      //                           });
      //                         },
      //                         onCompleted: (value) {
      //                           setState(() {
      //                             _otp = value;
      //                           });
      //                         },
      //                       ),
      //                       const SizedBox(height: 20),
      //                       if (_message.isNotEmpty)
      //                         Column(
      //                           children: [
      //                             const SizedBox(height: 10),
      //                             Text(
      //                               _message,
      //                               style: GoogleFonts.poppins(
      //                                 fontSize: 14,
      //                                 fontWeight: FontWeight.w500,
      //                                 color: _message.contains('success')
      //                                     ? Colors.teal
      //                                     : Colors.grey,
      //                               ),
      //                               textAlign: TextAlign.center,
      //                             ),
      //                             const SizedBox(height: 10),
      //                           ],
      //                         ),
      //                       if (!_otpError)
      //                         _isLoading
      //                             ? const CircularProgressIndicator(
      //                                 color: Colors.green)
      //                             : ElevatedButton(
      //                                 onPressed: _verifyOtp,
      //                                 style: ElevatedButton.styleFrom(
      //                                   foregroundColor: Colors.white,
      //                                   backgroundColor: Colors.green,
      //                                   padding: const EdgeInsets.symmetric(
      //                                       horizontal: 40, vertical: 15),
      //                                   textStyle: const TextStyle(
      //                                       fontSize: 14,
      //                                       fontWeight: FontWeight.bold),
      //                                   shape: RoundedRectangleBorder(
      //                                       borderRadius:
      //                                           BorderRadius.circular(20)),
      //                                 ),
      //                                 child: const Text('Verify OTP'),
      //                               ),
      //                       if (_otpError)
      //                         ElevatedButton(
      //                           onPressed: _canResend ? _resendOtp : null,
      //                           style: ElevatedButton.styleFrom(
      //                             foregroundColor: Colors.white,
      //                             backgroundColor: Colors.green,
      //                             padding: const EdgeInsets.symmetric(
      //                                 horizontal: 40, vertical: 15),
      //                             textStyle: const TextStyle(
      //                                 fontSize: 16,
      //                                 fontWeight: FontWeight.bold),
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(20),
      //                             ),
      //                           ),
      //                           child: _isResending
      //                               ? const SizedBox(
      //                                   height: 20,
      //                                   width: 20,
      //                                   child: CircularProgressIndicator(
      //                                     color: Colors.white,
      //                                     strokeWidth: 2,
      //                                   ),
      //                                 )
      //                               : Text(_canResend
      //                                   ? "Resend OTP"
      //                                   : "Please Wait.."),
      //                         ),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //               const SizedBox(height: 20),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
