import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_hub/farm_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sign_in_farmer.dart';
import 'selection_page.dart';

class LogInFarmer extends StatefulWidget {
  const LogInFarmer({super.key});

  @override
  _LogInFarmer createState() => _LogInFarmer();
}

class _LogInFarmer extends State<LogInFarmer> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  void _validateFields() {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      _signIn();
    }
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      final doc =
          await FirebaseFirestore.instance.collection('farmers').doc(uid).get();

      if (!doc.exists || (doc.data()?['role'] != 'farmer')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Not authorized as Farmer")),
        );
        setState(() => _isLoading = false);
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Login Successful!")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmAccount()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = "Login failed";

      if (e.code == 'user-not-found') {
        message = "No user found for this email.";
        _emailError = message;
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
        _passwordError = message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ $message")));
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return "Email is required";
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegExp.hasMatch(value) ? null : "Enter a valid email";
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    return value.length < 6 ? "Password must be at least 6 characters" : null;
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
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectionPage(),
                    ),
                  );
                },
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
                    _buildInputField(_emailController, "Email", false),
                    if (_emailError != null) _buildErrorText(_emailError!),
                    const SizedBox(height: 10),
                    _buildInputField(_passwordController, "Password", true),
                    if (_passwordError != null)
                      _buildErrorText(_passwordError!),
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
                                  builder: (context) => const SignInFarmer(),
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

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    bool isPassword,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Fredoka', color: Colors.grey),
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
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 14,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
