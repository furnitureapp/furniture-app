
import 'package:flutter/material.dart';
import 'package:furniture_ecom_app/core/services_ecom/auth_service.dart';
import 'package:furniture_ecom_app/my_ecom/authentication/reset_password.dart';
import 'package:furniture_ecom_app/constants/colors.dart';
import 'package:furniture_ecom_app/constants/snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _hideButton = false;
  String _message = '';

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _forgotPassword() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      showTopSnackBar(context, "Please enter your email address!");
      setState(() => _isLoading = false);
      return;
    }

    if (!_isValidEmail(email)) {
      showTopSnackBar(context, "Invalid email format! Example: user@mail.com");
      setState(() => _isLoading = false);
      return;
    }

    final result = await ApiService.forgotPassword(email);

    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: email),
        ),
      );
    } else {
      String errorMessage = result['message'];
      if (errorMessage.toLowerCase().contains('user not found')) {
        errorMessage =
            'No account found with this email!\nPlease check and try again!';
      }
      showTopSnackBar(context, errorMessage);
    }
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
            title: const Text(
              "Forgot password?",
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
      body: Stack(
        children: [
          SizedBox.expand(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/theme.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: Colors.white.withOpacity(0.85),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    width: isTablet ? 450 : double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Reset Password",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 41, 97, 67),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter your email to receive a password reset link.",
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: const TextStyle(
                              color: Colors.grey
                            ),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color.fromARGB(255, 115, 158, 103),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 48, 84, 38),
                                  width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        if (!_hideButton)
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: mythemecolor)
                              : ElevatedButton(
                                  onPressed: _forgotPassword,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 92, 174, 92),
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
                                  child: const Text('Send Reset Link'),
                                ),
                        const SizedBox(height: 20),
                        if (_message.isNotEmpty)
                          Text(
                            _message,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _message.contains('success')
                                  ? Colors.teal
                                  : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
