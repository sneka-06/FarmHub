import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:farm_hub/log_in.dart';
import 'package:farm_hub/selection_page.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _nameError, _emailError, _passwordError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() => _nameError = null));
    _emailController.addListener(() => setState(() => _emailError = null));
    _passwordController.addListener(
      () => setState(() => _passwordError = null),
    );
  }

  void _signUp() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? "Name is required" : null;
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_nameError == null && _emailError == null && _passwordError == null) {
      setState(() => _isLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'name': _nameController.text.trim(),
              'email': _emailController.text.trim(),
              'role': 'consumer',
              'createdAt': FieldValue.serverTimestamp(),
            });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Sign Up Successful")));

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LogIn()),
          );
        });
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);

        String errorMessage = "Sign up failed";
        if (e.code == 'email-already-in-use') {
          errorMessage = "Email is already in use";
        } else if (e.code == 'weak-password') {
          errorMessage = "Password must be at least 6 characters";
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ $errorMessage")));
      }
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
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SIGN UP",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6E69A),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(_nameController, "Name"),
                          if (_nameError != null) _buildErrorText(_nameError!),
                          const SizedBox(height: 10),
                          _buildTextField(
                            _emailController,
                            "Email",
                            type: TextInputType.emailAddress,
                          ),
                          if (_emailError != null)
                            _buildErrorText(_emailError!),
                          const SizedBox(height: 10),
                          _buildPasswordField(),
                          if (_passwordError != null)
                            _buildErrorText(_passwordError!),
                        ],
                      ),
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
                      onPressed: _isLoading ? null : _signUp,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "SIGN UP",
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an Account?",
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LogIn()),
                      );
                    },
                    child: const Text(
                      "LOG IN",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'Fredoka', color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(fontFamily: 'Fredoka', color: Colors.grey),
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
