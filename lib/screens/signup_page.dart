import 'package:flutter/gestures.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/services/api_service.dart'; 

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Ditambahkan untuk show/hide password

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Nama tidak boleh kosong');
      return false;
    }
    if (_emailController.text.trim().isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text.trim())) {
      Fluttertoast.showToast(msg: 'Masukkan email yang valid');
      return false;
    }
    if (_passwordController.text.trim().length < 6) {
      Fluttertoast.showToast(msg: 'Kata sandi minimal 6 karakter');
      return false;
    }
    return true;
  }

  void prosesRegistrasi() async {
    if (!_validateInputs()) return;

    setState(() { _isLoading = true; });

    try {
      final response = await ApiService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response['statusCode'] == 201) {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Pendaftaran berhasil! Silakan login.',
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.pop(context); // Kembali ke halaman login setelah berhasil
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? 'Pendaftaran gagal');
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(msg: 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = const Color(0xFF4399CD);
    final lightBlueGradient = const LinearGradient(
      colors: [Color(0xFF5EA1D6), Color(0xFF2F7DBD)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  'assets/images/logo.png', // Pastikan path asset ini benar
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Daftar Akun',
                      style: TextStyle(color: blueColor, fontFamily: "Poppins", fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildTextField(
                      label: 'Nama',
                      controller: _nameController,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      label: 'Kata Sandi',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol Daftar
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _isLoading ? null : prosesRegistrasi,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: lightBlueGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Color(0xFF2F7DBD), offset: Offset(0, 4), blurRadius: 4)],
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text(
                                'DAFTAR',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Poppins", fontWeight: FontWeight.w600, letterSpacing: 1.2),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- PERUBAHAN DARI TextButton MENJADI RichText ---
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600], fontSize: 14, fontFamily: "Poppins"),
                        children: <TextSpan>[
                          const TextSpan(text: 'Sudah punya akun? '),
                          TextSpan(
                            text: 'Masuk',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Kembali ke halaman login
                                Navigator.of(context).pop();
                              },
                          ),
                        ],
                      ),
                    ),
                    // -------------------------------------------------
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk TextField agar lebih rapi
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}