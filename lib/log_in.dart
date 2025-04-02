import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_hub/location_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogIn createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() => _emailError = null));
    _passwordController.addListener(
      () => setState(() => _passwordError = null),
    );
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 🔐 Firebase Auth Sign In
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;

      // 📦 Check Firestore "users" collection
      final userDoc =
          await FirebaseFirestore.instance
              .collection(
                'users',
              ) // <-- Make sure your consumers are stored here
              .doc(uid)
              .get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
          _emailError = "This account is not a consumer.";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ This account is not a consumer."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ✅ Success - Navigate to Location Page
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LocationPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'user-not-found') {
        _emailError = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        _passwordError = "Incorrect password.";
      } else {
        _emailError = "Login failed. Please try again.";
      }
    }
  }

  void _validateFields() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      _loginUser();
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return "Email is required";
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (!emailRegExp.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7E063),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "LOG IN",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email",
                      errorText: _emailError,
                      isPassword: false,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Password",
                      errorText: _passwordError,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B5D36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 100,
                        ),
                      ),
                      onPressed: _isLoading ? null : _validateFields,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "LOG IN",
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
            ),
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: "Don't have an Account? ",
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "SIGN IN",
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignIn(),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            keyboardType:
                hintText.toLowerCase().contains("email")
                    ? TextInputType.emailAddress
                    : null,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Fredoka',
                color: Colors.grey,
              ),
              border: InputBorder.none,
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                      : null,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
